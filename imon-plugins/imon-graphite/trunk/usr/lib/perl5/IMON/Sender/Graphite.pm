package IMON::Sender::Graphite;

use strict;
use warnings;
use IO::Socket;
use base 'IMON::Sender::Base';

use constant DEFAULT_CARBON_SERVER => '127.0.0.1';
use constant DEFAULT_CARBON_PORT   => 2003;

$| = 1;

sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params);

    map { $self->{$_} = $self->{cfg}->{$_} }
      qw( carbon_server carbon_port namespace );

    my $server = $self->{carbon_server} || DEFAULT_CARBON_SERVER;
    my $port   = $self->{carbon_port}   || DEFAULT_CARBON_PORT;

    $self->{sock} = IO::Socket::INET->new(
        PeerAddr => $server,
        PeerPort => $port,
        Proto    => 'tcp'
    );
    if (!($self->{sock})) {
        $self->{error} = "Socket connect failed, Check Carbon agent connection at $server/$port\n";
    }
}

sub send_data {
    my $self = shift;

    while (1) {
        foreach my $t ( @{ $self->{transport} } ) {
            map { $self->send_to_graphite($_); } $t->pull_data();
        }
        sleep 1;
    }
}

sub send_to_graphite {
    my ( $self, $data ) = @_;

    my ( $valid_data, $ds_parent );

    # if namespace overrides are specified in the config use that 
    if ( $self->{namespace} ) {
        $ds_parent = join(
            ".",
            map {
                if ( $data->{$_} ) { $self->clean_field( $data->{$_} ) }
              } @{ $self->{namespace} }
        );
    }
    else {
        # use env.<pivot_label>.<pivot_val>.<default_pivot> format
        $ds_parent =
          $data->{env} . "."
          . (
            defined( $data->{pivot_label} )
            ? (
                defined( $data->{pivot_value} )
                ? $self->clean_field( $data->{pivot_label} ) . "."
                  . $self->clean_field( $data->{pivot_value} )
                : $self->clean_field( $data->{pivot_label} )
              )
            : "default"
          )
          . "."
          . (
            defined( $data->{default_pivot} )
            ? $self->clean_field( $data->{default_pivot} )
            : $self->clean_field( $data->{Hostname} )
          );

    }
    my $sep = $data->{sep};
    my $h   = {};
    foreach my $k ( keys %{$data} ) {
        next
          if $k =~
/(?:EventType|Type|Source|SenderIP|Hostname|env|prog_id|SenderPort|pivot_key|pivot_value|pivot_label|default_pivot|sep)$|^context\./;
        if ( $k =~ /^(.+?)$sep(.*)$/ ) {
            $h->{$k} = $data->{$k};
        }
        $valid_data++ if ( defined $data->{$k} );
    }

    if ($valid_data) {
        $self->write_to_socket( $ds_parent, $h );
    }
    else {
        print "No data found to update: \"$ds_parent\"\n";
    }

}

sub write_to_socket {
    my ( $self, $parent, $data ) = @_;

    my $time = time;
    foreach my $k ( keys %{$data} ) {
        my $key = $self->clean_field($k);
        my $msg = "$parent\.$key " . $data->{$k} . " $time";
        print "Sending event( $msg ) to Graphite\n";
        $self->{sock}->send( "$msg\n" );
    }
}

# clean the fields
sub clean_field {
    my ( $self, $name ) = @_;

    $name =~ s/\.+/_/g; # convert '.' to _ as Grahipte namespace is '.' separated
    $name =~ s/<=/le_/;
    $name =~ s/>=/ge_/;
    $name =~ s/</lt_/;
    $name =~ s/>/gt_/;
    $name =~ s/::/_/g;
    $name =~ s/[:,]/_/;

    return $name;
}

1;

# vim: set ts=4 sw=2 expandtab:

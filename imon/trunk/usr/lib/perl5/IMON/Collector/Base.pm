#
# $Id: Base.pm 5791 2012-03-09 06:01:11Z rengith.j $

package IMON::Collector::Base;
use strict;
use warnings;

sub new {
    my ( $c, %params ) = @_;

    my $class = ref($c) || $c;

    my $self = {};

    bless $self, $class;
    $self->init(%params);

    return $self;
}

sub init {
    my ($self, %params) = @_;

    my $cfg = $params{cfg};

    map { $self->{$_} = $cfg->{$_}; } qw/name ip port env event_type/;

    $self->{Type} = "Collected"; # Type defaults to 'Collected'
}

# override this method
sub collect {
	my $self = shift;
}

sub error {
    my ( $self ) = @_;

    return $self->{error};
}

sub add_transport {
    my ($self, $transport) = @_;

    @{$self->{transport}} = ref($transport) eq 'ARRAY' ? @{$transport} : ( $transport );
}

sub push_to_transport {
    my ( $self,$e ) = @_;

    return if (grep { !$e->{$_} } qw(Type Source Hostname));

    $_->push_data($e) foreach (@{$self->{transport}});
}

# to set Type protocol
# set to "Collected::$val" if $val is passed
# else set to 'Collected'
sub set_type {
    my ( $self, $val ) = @_;

    $self->{Type} = (defined $val) ? "Collected::$val" : "Collected";
}

1;
# vim: set ts=4 sw=2 expandtab:

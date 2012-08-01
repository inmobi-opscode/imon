#
# $Id$

package IMON::Transport::REDIS;

use strict;
use warnings;
use Redis;
use base 'IMON::Transport::Base';

use constant DEFAULT_REDIS_SERVER => '127.0.0.1';
use constant DEFAULT_REDIS_PORT => 6379 ;
use constant DEFAULT_SEPERATOR => '.' ;
use constant DEFAULT_MSG_SEPERATOR => '; ' ;

sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params);
    map { $self->{$_} = $self->{cfg}->{$_} } qw( redis_server redis_port channel sep msg_sep );

    $self->{channel} ||= [ "env", "pivot", "Hostname" ];
    $self->{sep}     ||= DEFAULT_SEPERATOR;
    $self->{msg_sep} ||= DEFAULT_MSG_SEPERATOR;
    
    $self->init_redis(%params);

}

sub init_redis {
    my ( $self, %params ) = @_;

    $self->{redis_server} = $params{redis_server} || DEFAULT_REDIS_SERVER;
    $self->{redis_port}   = $params{redis_port} || DEFAULT_REDIS_PORT;

    $self->{redis} = Redis->new( server => "$self->{redis_server}:$self->{redis_port}" );
}

# publish data 
sub push_data {
    my ($self, $data) = @_;

    my ( $redis, $pivot, $channel, $msg );
    $redis = $self->{redis};
    $pivot = join($self->{sep}, map { $data->{$_} if defined($data->{$_}); } qw( pivot_label pivot_value ));

    $channel = join($self->{sep}, map { $_ eq 'pivot' ? $self->clean_field($pivot) : $data->{$_} } @{$self->{channel}} );

    foreach ( qw(EventType SenderIP Hostname env prog_id SenderPort pivot_key pivot_value pivot_label default_pivot) ) {
        delete($data->{$_}) if defined($data->{$_});
    }
    $msg = $self->stringify($data, $self->{msg_sep});
    #print "publishing message to the channel '$channel'\n";
    $redis->publish($channel,$msg);
}

sub stringify {
    my ($self, $data, $sep) = @_;

    return join($sep, map { $self->clean_field($_) . ": " . $data->{$_} } keys %{$data});
}

sub clean_field {
    my ($self, $field) = @_;

    $field =~ s/[^A-Za-z0-9_.-]+/_/g;

    return $field;
}

1;
# vim: set ts=4 sw=2 expandtab:

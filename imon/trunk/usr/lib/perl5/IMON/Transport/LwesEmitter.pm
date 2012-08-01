#
# $Id: LwesEmitter.pm 4653 2012-01-02 09:22:21Z rengith.j $

package IMON::Transport::LwesEmitter;

use LWES;
use LWES::EventParser;
use base 'IMON::Transport::Base';

use constant DEFAULT_EVENT_TTL => 16;

sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params);

    # mandatory config parameters, set error and return if not defined
    foreach (qw( addr port event_name )) {
        if (defined($params{cfg}->{$_})) {
            $self->{$_} = $params{cfg}->{$_}
        }else {
            $self->{error} = "LwesEmitter Transport parameter '$_' missing";
            return;
        }
    }
    $self->{ttl} = $params{cfg}->{ttl} || DEFAULT_EVENT_TTL;
    $self->{emitter} = LWES::create_emitter($self->{addr}, "0", $self->{port}, $self->{ttl}, 60);
}

sub push_data {
    my ($self, $e) = @_;

    my $event = LWES::create_event(undef, $self->{event_name});
    foreach my $k(%{$e}) {
        LWES::set_string($event, "$k", "$e->{$k}") if (defined $e->{$k});
    }

    print "LwesEmitter: Sending event to $self->{addr} on port $self->{port}\n";
    LWES::emit($self->{emitter}, $event);
    LWES::destroy_event($event);
}

# destroy emitter and db
sub DESTROY {
    my $self = shift;

    LWES::destroy_emitter($self->{emitter}) if ($self->{emitter});
}

1;
# vim: set ts=4 sw=2 expandtab:

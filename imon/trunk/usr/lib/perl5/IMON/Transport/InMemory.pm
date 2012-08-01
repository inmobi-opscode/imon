#
# $Id: InMemory.pm 7843 2012-05-07 09:51:28Z rengith.j $

package IMON::Transport::InMemory;

use Thread::Queue;
use base 'IMON::Transport::Base';

$|=1;

sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params);

    $self->{queue} = Thread::Queue->new();

    # defines enqueue subroutine
    # no queue limit applies if there is no threshold param in the config
    if (defined $params{cfg}->{threshold}) {
        $self->{threshold} = $params{cfg}->{threshold};
        $self->{enqueue_sub} = \&enqueue_event_threshold;
    }else {
        # this subroutine enqueues events without any modifications in the q
        $self->{enqueue_sub} = \&enqueue_event;
    }
}

# enqueue data to thread-queue
sub push_data {
    my ($self, $e) = @_;

    &{$self->{enqueue_sub}}($self, $e);
}

# dequeue data from thread-queue
sub pull_data {
    my $self = shift;

    my $q = $self->{queue};
    my $pending = $q->pending();
    return $pending ? $q->dequeue_nb($pending) : ();
}

sub enqueue_event {
    my ($self, $e) = @_;

    $self->{queue}->enqueue($e);
}

# enqueue event with threshold check
# discard the earliest event from queue if the pending mumber of items reaches threshold
sub enqueue_event_threshold {
    my ($self, $e) = @_;

    my $q = $self->{queue};
    my $pending = $q->pending();

    # discard(dequeue) earliest event if pending events reaches threshold
    if ( $pending >= $self->{threshold} ) {
        print "Threshold ($self->{threshold}) reached, discarding earliest event from the queue\n";
        $q->dequeue_nb();
    }

    $q->enqueue($e);
}

1;
# vim: set ts=4 sw=2 expandtab:

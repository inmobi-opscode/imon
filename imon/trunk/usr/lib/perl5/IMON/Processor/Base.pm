#
# $Id: Base.pm 4878 2012-01-23 11:50:55Z rengith.j $

package IMON::Processor::Base;

use strict;
use warnings;

sub new {
   	my ( $obj, %params ) = @_;

	my $class = ref($obj) || $obj;

	my $self = {};

   	bless $self, $class;
   	$self->init(%params);
   	return $self;
}

sub init {
	my ($self, %params) = @_;	
	
    $self->{cfg}   = $params{cfg};
}

# need to override
sub process {
	my $self = shift;
}

# set $SIG{ALRM}
sub set_alarm {
    my $self = shift;

    # place holder, should override this in the derived class
}

# set $SIG{ALRM} and notify at every 'interval' seconds to execute the coderef set by SIGALRM
sub set_alarm_and_notify {
    my $self = shift;

    $self->set_alarm();

    my $handle = threads->self();
    # notify_thread: create a thread which sends ALRM signal to parent (ie: this thread) at sepcific intervals
    my $notify_thread = sub { while (1) { sleep $self->{interval}; $handle->kill('SIGALRM'); } };
    my $notify_h = threads->create($notify_thread);
    $notify_h->detach();
}

sub signal_safe_call {
    my ($self, $compute_sub, @args) = @_;

    my $sub = $SIG{ALRM};
    my $alarm = undef;
    $SIG{ALRM} = sub { $alarm = 1; };
    &{$compute_sub}(@args);
    &{$sub} if $alarm;
    $SIG{ALRM} = $sub;

}

sub error {
    my $self = shift;

    return $self->{error};
}

sub add_transport {
    my ($self, %transport) = @_;

    @{$self->{transport}->{in}} = ref($transport{in}) eq 'ARRAY' ? @{$transport{in}} : ( $transport{in} );
    @{$self->{transport}->{out}} = ref($transport{out}) eq 'ARRAY' ? @{$transport{out}} : ( $transport{out} );
}

sub push_to_transport {
    my ( $self, $e ) = @_;

    return if (grep { !$e->{$_} } qw(Type Source Hostname));

    $_->push_data($e) foreach (@{$self->{transport}->{out}});
}

1;
# vim: set ts=4 sw=2 expandtab:

#
# $Id: POE.pm 5753 2012-03-07 12:28:35Z rengith.j $

=head1 NAME

 IMON::Utils::POE - wrapper over POE to provide iMon sepcific eventloop/parallel IO functionality

=head1 SYNOPSYS

 use IMON::Utils::POE;

 my $poe = IMON::Utils::POE->new();

 # create 10 sessions which runs in parallel
 foreach (1 .. 10) {
    my $interval = 120; # defaults is 60 sec
    my @args = qw( param1 param2 param3 ); # arguments to my_sub

    $poe->create_session( interval => $interval, 
                          coderef  => \&my_sub, 
                          args     => \@args
                        );
    if (my $err = $poe->error) {
        print "create_session failed with error $err, exiting\n";
        exit; 
    }
 }

 $poe->run(); # returns only after all the sessions have ended

 sub my_sub {
   my @args = @_;
   print "sample sub\n";
   # code goes here
 }

=head1 AUTHOR
 
 Rengith Jerome <rengith.j@inmobi.com>
=cut
package IMON::Utils::POE;
use strict;
use warnings;
use POE;

use constant DEFAULT_INTERVAL => 60;

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

    # placeholder.. will be used in case any configs need to be initialized  
}

#
# create a poe session to invoke coderef with arguments at regular intervals(sleep)
# sleep and coderef are mandatory parameters
# Note: run method must be invoked after creating all the poe sessions
sub create_session {
    my ($self, %params) = @_;

    my ($interval, $coderef, $args_ref) = map { $params{$_} } qw( interval coderef args );

    if (!defined $coderef) {
        $self->{error} = "Unable to create poe session, coderef is a mandatory parameter";
        return;
    }

    if (defined $args_ref && ref($args_ref) ne 'ARRAY') {
        $self->{error} = "'args' param must be an arrayref";
        return;
    } 
    my @args = defined $args_ref ? @{$args_ref} : ();
    $interval ||= DEFAULT_INTERVAL;

    POE::Session->create(
        inline_states => {
                _start => sub {
                        $_[KERNEL]->yield("next")
                },
                next => sub {
                        &{$coderef}(@args);
                        $_[KERNEL]->delay(next => $interval);
                },
        },
    );
}

#
# run invokes the event dispatcher method of poe
# This should be invoked after creating all the poe sessions
# It will not return until all sessions have ended
sub run {
  my $self = shift;

  POE::Kernel->run();
}

# error interface
sub error {
    my $self = shift;

    return $self->{error};
}

1;
# vim: set sw=2 ts=4 expandtab:

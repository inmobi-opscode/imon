#
# $Id: Info.pm 7353 2012-04-23 04:51:26Z shanker.balan $
#
$|=1;

package IMON::Collector::SNMP::Info;

use strict;
use warnings;
use Time::HiRes qw( gettimeofday tv_interval );
use SNMP::Info;
use IMON::Utils::POE;

use base 'IMON::Collector::SNMP';

sub collect {
  my ($self) = @_;

  my $poe = IMON::Utils::POE->new();

  # create poe session for all the devices, which invokes snmp_get_all periodically
  foreach my $device ($self->valid_devices()) {
    my $sleep = $self->interval($device);
    $poe->create_session( interval => $sleep, 
                          coderef  => \&snmp_get_all, 
                          args     => [ $self, $device ]
                      );
  }
  # invoking the event dispatcher
  # will not return until all the sessions have ended
  $poe->run();
}

sub init {
  my ($self, %params) = @_;

  $self->SUPER::init(%params);

  foreach my $device ($self->devices) {
    $self->{info_obj}->{$device} = $self->init_snmp_info(undef, $device);
  }

  printf("Collector init complete with %d valid devices\n", scalar($self->valid_devices()) );
}

sub snmp_get_all {
  my ($self, $device) = @_;

  print "Collecting information for device $device\n";
  my ($info, $all);
  my %snmp_options = $self->get_device_snmp_options($device);
  my $desthost = $snmp_options{DestHost};

  if (defined($self->{info_obj}->{$device})) {
    $info = $self->{info_obj}->{$device};
  } else {
    printf("Attempting reinit for %s\n", $device);
    $info = SNMP::Info->new(%snmp_options);
    $self->{info_obj}->{$device} = $info;
  }

  if (!defined($info)) {
    printf("Can't connect to device %s\n", $device);
    return;
  }

  if (!defined($info->sysDescr() )) {
    # Uh Oh. Better luck in next run?
    printf("%s: ERROR %s. Please check community string and ACL\n", $device, $info->error() );
    return;
  }

  my $t0 = [gettimeofday];

  $all   = $info->all();

  if (!defined($all)) {
    printf("Failed to run all() for device %s: %s\n", $device, $info->error() );
    return;
  }
  my $interfaces = $info->interfaces();

  foreach my $iid (sort keys %$interfaces) {
    unless ($all->{i_up}->{$iid} eq 'up') {
      next;
    }
    my $e = $self->create_event();
    $e->{device}      = $device;

    # TODO: We actually have a list of keys that we need to push to transport.
    foreach my $key (keys %$all) {
      $e->{$key} = $all->{$key}->{$iid};
    }
    $self->push_to_transport($e);
  }
  $info->clear_cache();

  my $t1 = [gettimeofday];
  my $elapsed = tv_interval $t0, $t1;
  printf("%s: Collect (%s) completed in %.3f (s)\n", $device, $desthost, $elapsed);
}

1;

# vim: set sw=2 ts=2 expandtab:

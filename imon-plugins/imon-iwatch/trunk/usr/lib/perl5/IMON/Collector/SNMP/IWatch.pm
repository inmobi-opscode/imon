#
# $Id: IWatch.pm 7058 2012-04-13 10:35:39Z shanker.balan $
#
# IWatch Collector
# - Gathers OS stats from a host running Net-SNMP
# Todo
# - Handle indexes for UDP, TCP, IP
# - Handle hrSWRunName
# - Batter handling for hrDeviceIndex
$|=1;

package IMON::Collector::SNMP::IWatch;

use strict;
use warnings;
use Time::HiRes qw( gettimeofday tv_interval );
use IMON::Utils::POE;

use base 'IMON::Collector::SNMP';

use Data::Dumper;

my %stat_types = (
  sys   => 'sys',
  hr    => 'hostResource',
  ss    => 'systemStats',
  ip    => 'ip',
  icmp  => 'icmp',
  tcp   => 'tcp',
  udp   => 'udp',
  snmp  => 'snmp',
  mem   => 'memory',
  version => 'version',
);

sub init {
  my ($self, %params) = @_;
  $self->SUPER::init(%params);

  foreach my $device ($self->devices) {
    $self->{info_obj}->{$device} = $self->init_snmp_info('Inmobi::OS', $device);
  }

  printf("Collector init complete with %d valid devices\n", scalar($self->valid_devices()) ); 
}

sub collect {
  my ($self) = @_;
  my $poe = IMON::Utils::POE->new();

  foreach my $device ($self->valid_devices()) {
    my $sleep = $self->interval($device);
    $poe->create_session(
      interval => $sleep,
      coderef  => \&snmp_get_all,
      args     => [ $self, $device ]
    );
  }
  $poe->run();
}

sub snmp_get_all {
  my ($self, $device) = @_;
  my $info = $self->{info_obj}->{$device};
  my $stats->{sys} = $info->stats('sys') || undef;

  if ( !defined($stats->{sys}->{sysObjectID}) ) {
    printf("%s: WARN: sysObjectID missing. Skipped...\n", $device);
    return;
  }

  if ($stats->{sys}->{sysObjectID} ne 'linux') {
    printf("%s: WARN: %s devices are not supported. Skipped...\n",
      $device, $stats->{sys}->{sysObjectID});
    return;
  }

  foreach my $type (keys %stat_types) {
    if ( defined($stats->{$type} = $info->stats($type)) ) {
      my %e = ( stat_type => $stat_types{$type},
                %{$self->create_event($device, $stats->{sys})},
                %{$stats->{$type}});
      $self->push_to_transport(\%e);
    } else {
      printf("%s: WARN: systemStats missing\n", $device);
    }
  }

  my $indexstats = $info->all;

  my %indexmap = (
    laIndex  => 'loadAvg',
    hrStorageIndex => 'storage',
    hrDeviceIndex => 'device',
    diskIOIndex => 'diskio',
  );
  my %indexkeys = (
    laIndex  => [
      'laNames', 'laLoad', 'laConfig', 'laLoadInt', 'laLoadFloat', 'laErrorFlag', 'laErrMessage'
    ],
    hrStorageIndex => [
      'hrStorageType', 'hrStorageDescr', 'hrStorageAllocationUnits', 'hrStorageSize',
      'hrStorageUsed'
    ],
    hrDeviceIndex => [
      'hrDeviceType', 'hrDeviceDescr', 'hrDeviceStatus', 'hrDeviceType', 'hrDeviceDescr',
      'hrDeviceStatus', 'hrDeviceErrors', 'hrProcessorFrwID', 'hrProcessorLoad'
    ],
    hrFSIndex => [
      'hrFSMountPoint', 'hrFSType', 'hrFSAccess', 'hrFSBootable', 'hrFSRemoteMountPoint',
      'hrFSStorageIndex'
    ],
    diskIOIndex => [
      'diskIODevice', 'diskIONRead', 'diskIONWritten', 'diskIOReads', 'diskIOWrites',
      'diskIONReadX', 'diskIONWrittenX'
    ],
  );

  # laIndex
  foreach my $i (keys %{$indexstats->{laIndex}}) {
    my $e = $self->create_event($device, $stats->{sys});
    $e->{stat_type} = $indexmap{laIndex};
    foreach my $s (@{$indexkeys{laIndex}}) {
      $e->{$s} = $indexstats->{$s}->{$i};
    }
    $self->push_to_transport($e);
  }

  # hrStorageIndex
  foreach my $i (keys %{$indexstats->{hrStorageIndex}}) {
    my $e = $self->create_event($device, $stats->{sys});
    $e->{stat_type} = $indexmap{hrStorageIndex};
    foreach my $s (@{$indexkeys{hrStorageIndex}}) {
      $e->{$s} = $indexstats->{$s}->{$i};
    }
    $self->push_to_transport($e);
  }

  # hrFSIndex
  foreach my $i (keys %{$indexstats->{hrFSIndex}}) {
    my $e = $self->create_event($device, $stats->{sys});
    $e->{stat_type} = $indexmap{hrFSIndex};
    foreach my $s (@{$indexkeys{hrFSIndex}}) {
      $e->{$s} = $indexstats->{$s}->{$i};
    }
    $self->push_to_transport($e);
  }

  # diskIOIndex
  foreach my $i (keys %{$indexstats->{diskIOIndex}}) {
    # We dont want loop/ram disks
    next if $indexstats->{diskIODevice}->{$i} =~ /^(ram|loop|sr|fd)\d+/;
    my $e = $self->create_event($device, $stats->{sys});
    $e->{stat_type} = $indexmap{diskIOIndex};
    foreach my $s (@{$indexkeys{diskIOIndex}}) {
      $e->{$s} = $indexstats->{$s}->{$i};
    }
    $self->push_to_transport($e);
  }
}

sub create_event {
  my ($self, $device, $stats) = @_;
  my $source = $self->{cfg}->{source}         || "IWatch";
  my $event_type = $self->{cfg}->{event_type} || "IWatch"; 
  my $env = $self->{cfg}->{env}               || "iwatch";

  my %event = (
    Device    => $device,
    Hostname  => $device,
    Source    => $source,
    Type      => $event_type,
    env       => $env,
    sysObjectID => $stats->{sysObjectID},
    sysName   => $stats->{sysName},
  );
  return \%event;
}

1;
# vim: set ts=2 sw=2 expandtab:

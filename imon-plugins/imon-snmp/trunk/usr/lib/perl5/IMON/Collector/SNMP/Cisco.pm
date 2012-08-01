#
# $Id$
#

package IMON::Collector::SNMP::Cisco;

use strict;
use warnings;
use Time::HiRes qw( gettimeofday tv_interval );
use IMON::Utils::POE;

use base 'IMON::Collector::SNMP';

use Data::Dumper;

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
    $self->{info_obj}->{$device} = $self->init_snmp_info('Inmobi::Cisco', $device);
  }

  printf("Collector init complete with %d valid devices\n", scalar($self->valid_devices()) );
}

sub snmp_get_all {
  my ($self, $device) = @_;

  my $info = $self->{info_obj}->{$device};
  $info->clear_cache();

  die "Unable to collect from $device. Object does not exist\n" unless $info;

  if (!defined($info->sysDescr() )) {
    # Uh Oh. Better luck in next run?
    printf("%s: ERROR %s. Please check community string and ACL\n", $device, $info->error() );
    return;
  }

  my $t0 = [gettimeofday];

  my $all = $info->all();

  my $t1 = [gettimeofday];

  my $elapsed = tv_interval $t0, $t1;

  printf("%s: Collect completed in %.6f (s)\n", $device, $elapsed);

  my $standby_state = $info->standby_state || 'active';
  print "$device is marked $standby_state\n";

  foreach my $cpuid ( keys %{$all->{cpmCPUTotalPhysicalIndex}} ) {
    my $e = $self->create_event();
    $e->{'device'} = $device;
    $e->{standby_state} = $standby_state;
    $e->{'cpmCPUTotalPhysicalIndex'}   = $cpuid;
    $e->{'cpmCPUTotal5sec'}    = $all->{cpmCPUTotal5sec}->{$cpuid};
    $e->{'cpmCPUTotal1min'}    = $all->{cpmCPUTotal1min}->{$cpuid};
    $e->{'cpmCPUTotal5min'}    = $all->{cpmCPUTotal5min}->{$cpuid};
    $self->push_to_transport($e);
  }

  foreach my $id (keys %{$all->{ciscoMemoryPoolName}}) {
    my $e = $self->create_event();
    $e->{'device'} = $device;
    $e->{standby_state} = $standby_state;
    $e->{ciscoMemoryPoolName}       = lc($all->{ciscoMemoryPoolName}->{$id});
    $e->{ciscoMemoryPoolAlternate}  = $all->{ciscoMemoryPoolAlternate}->{$id};
    $e->{ciscoMemoryPoolUsed}       = $all->{ciscoMemoryPoolUsed}->{$id};
    $e->{ciscoMemoryPoolFree}       = $all->{ciscoMemoryPoolFree}->{$id};
    $e->{ciscoMemoryPoolLargestFree}= $all->{ciscoMemoryPoolLargestFree}->{$id};
    $self->push_to_transport($e);
  }

  if ($all->{cfwBufferStatValue}) {
    my @blocks;
    foreach my $id (keys %{$all->{cfwBufferStatValue}}) {
      push @blocks, (split(/\./,$id, 2))[0];
    }

    foreach my $b (@blocks) {
      my $e = $self->create_event();
      $e->{device}  = $device;
      $e->{standby_state} = $standby_state;
      $e->{cfwBufferBlockSize}  = $b;
      $e->{cfwBufferStatMax}  = $all->{cfwBufferStatValue}->{"$b.3"};
      $e->{cfwBufferStatLow}  = $all->{cfwBufferStatValue}->{"$b.5"};
      $e->{cfwBufferStatFree}  = $all->{cfwBufferStatValue}->{"$b.8"};
      $self->push_to_transport($e);
    }
  }

  if ($all->{cufwConnSetupRate1}) {
    my %pmap = ( 6 => 'udp', 7 => 'tcp' );
    foreach my $p ( keys %{$all->{cufwConnSetupRate1}} ) {
      next unless $pmap{$p};
      my $e = $self->create_event();
      $e->{device}  = $device;
      $e->{standby_state} = $standby_state;
      $e->{cufwConnStatProto}     = $pmap{$p};
      $e->{cufwConnSetupRate1}    = $all->{cufwConnSetupRate1}->{$p};
      $e->{cufwConnSetupRate5}    = $all->{cufwConnSetupRate5}->{$p};
      $self->push_to_transport($e);
    }
  }

  if ($all->{cfwConnectionStatCount}) {
    my @proto;
    my %pmap  = ( 37 => 'icmp', 38 => 'tcp', 39 => 'udp', 40 => 'ip' );

    foreach my $id (keys %{$all->{cfwConnectionStatCount}}) {
      push ( @proto, (split(/\./, $id))[0] );
    }
      
    foreach my $p (@proto) {
      next unless $pmap{$p};
      my $e = $self->create_event();
      $e->{device}  = $device;
      $e->{standby_state} = $standby_state;
      $e->{cfwConnStatProto}  = $pmap{$p};
      $e->{cfwConnStatCur}    = $all->{cfwConnectionStatValue}->{"$p.6"};
      $e->{cfwConnStatMax}    = $all->{cfwConnectionStatValue}->{"$p.7"};
      $self->push_to_transport($e);
    }
  }

  if ($all->{ciscoEnvMonFanStatusDescr}) {
    foreach my $fan ( keys %{$all->{ciscoEnvMonFanStatusDescr}} ) {
      my $e = $self->create_event();
      $e->{device}  = $device;
      $e->{standby_state} = $standby_state;
      $e->{ciscoEnvMonFanStatusDescr} = $all->{ciscoEnvMonFanStatusDescr}->{$fan};
      $e->{ciscoEnvMonFanState} = $all->{ciscoEnvMonFanState}->{$fan};
      $self->push_to_transport($e);
    }
  }

  if ($all->{ciscoEnvMonVoltageStatusDescr}) {
    foreach my $id ( keys %{$all->{ciscoEnvMonVoltageStatusDescr}} ) {
      my $e = $self->create_event();
      $e->{device}  = $device;
      $e->{standby_state} = $standby_state;
      $e->{ciscoEnvMonVoltageStatusDescr} = $all->{ciscoEnvMonVoltageStatusDescr}->{$id};
      $e->{ciscoEnvMonVoltageStatusValue} = $all->{ciscoEnvMonVoltageStatusValue}->{$id};
      $e->{ciscoEnvMonVoltageThresholdLow} = $all->{ciscoEnvMonVoltageThresholdLow}->{$id};
      $e->{ciscoEnvMonVoltageThresholdHigh} = $all->{ciscoEnvMonVoltageThresholdHigh}->{$id};
      $e->{ciscoEnvMonVoltageState} = $all->{ciscoEnvMonVoltageState}->{$id};
      $self->push_to_transport($e);
    }
  }

  if ($all->{ciscoEnvMonTemperatureStatusDescr}) {
    foreach my $id ( keys %{$all->{ciscoEnvMonTemperatureStatusDescr}} ) {
      my $e = $self->create_event();
      $e->{device}  = $device;
      $e->{standby_state} = $standby_state;
      $e->{ciscoEnvMonTemperatureStatusDescr} = $all->{ciscoEnvMonTemperatureStatusDescr}->{$id};
      $e->{ciscoEnvMonTemperatureStatusValue} = $all->{ciscoEnvMonTemperatureStatusValue}->{$id};
      $e->{ciscoEnvMonTemperatureThreshold} = $all->{ciscoEnvMonTemperatureThreshold}->{$id};
      $e->{ciscoEnvMonTemperatureState} = $all->{ciscoEnvMonTemperatureState}->{$id};
      $self->push_to_transport($e);
    }
  } else {
    warn "$device: ciscoEnvMonTemperatureStatusDescr missing";
  }
}

1;

# vim: set sw=2 ts=2 expandtab:

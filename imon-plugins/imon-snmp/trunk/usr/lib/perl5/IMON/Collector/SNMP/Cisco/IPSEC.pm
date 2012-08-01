#
# $Id$
#

package IMON::Collector::SNMP::Cisco::IPSEC;

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
    $self->{info_obj}->{$device} = $self->init_snmp_info('Inmobi::Cisco::IPSEC', $device);
  }

  printf("Collector init complete with %d valid devices\n", scalar($self->valid_devices()) );
}

sub snmp_get_all {
  my ($self, $device) = @_;

  my $info = $self->{info_obj}->{$device};
  $info->clear_cache();

  die "Unable to collect from $device. Object does not exist\n" unless $info;

  my $t0 = [gettimeofday];

  my $all = $info->all();

  my $t1 = [gettimeofday];

  my $elapsed = tv_interval $t0, $t1;

  printf("%s: Collect completed in %.6f (s)\n", $device, $elapsed);

  my $standby_state = $info->standby_state || 'active';

  print "$device is marked $standby_state\n";

  if (my $ike_global_stats = $info->ike_global_stats()) {
    my $e = $self->create_event();
    $e->{device}      = $device;
    $e->{event_type}  = "ike";
    $e->{standby_state} = $standby_state;
    foreach my $k (keys %$ike_global_stats) {
      $e->{$k} = $ike_global_stats->{$k};
    }
    $self->push_to_transport($e);
  }

  if (my $ipsec_global_stats = $info->ipsec_global_stats()) {
    my $e = $self->create_event();
    $e->{standby_state} = $standby_state;
    $e->{device}      = $device;
    $e->{event_type}  = "ipsec";
    foreach my $k (keys %$ipsec_global_stats) {
      $e->{$k} = $ipsec_global_stats->{$k};
    }
    $self->push_to_transport($e);
  }

  foreach my $id (keys %{$all->{cikeTunLocalValue}}) {
    my $e = $self->create_event();
    $e->{standby_state} = $standby_state;
    $e->{device}      = $device;
    $e->{cikeTunLocalValue} = $all->{cikeTunLocalValue}->{$id};
    $e->{cikeTunLocalAddr}  = $all->{cikeTunLocalAddr}->{$id};
    $e->{cikeTunLocalName}  = $all->{cikeTunLocalName}->{$id};
    $e->{cikeTunRemoteValue}= $all->{cikeTunRemoteValue}->{$id};
    $e->{cikeTunRemoteAddr} = $all->{cikeTunRemoteAddr}->{$id};
    $e->{cikeTunRemoteName} = $all->{cikeTunRemoteName}->{$id};
    $e->{cikeTunLifeTime}   = $all->{cikeTunLifeTime}->{$id};
    $e->{cikeTunInOctets}   = $all->{cikeTunInOctets}->{$id};
    $e->{cikeTunInPkts}     = $all->{cikeTunInPkts}->{$id};
    $e->{cikeTunInDropPkts} = $all->{cikeTunInDropPkts}->{$id};
    $e->{cikeTunInNotifys}  = $all->{cikeTunInNotifys}->{$id};
    $e->{cikeTunOutOctets}  = $all->{cikeTunOutOctets}->{$id};
    $e->{cikeTunOutPkts}    = $all->{cikeTunOutPkts}->{$id};
    $e->{cikeTunOutDropPkts}= $all->{cikeTunOutDropPkts}->{$id};
    $e->{cikeTunOutNotifys} = $all->{cikeTunOutNotifys}->{$id};
    $e->{cikeTunStatus}     = $all->{cikeTunStatus}->{$id};
    $self->push_to_transport($e);
  }

  foreach my $tid ( keys %{$all->{cipSecTunIkeTunnelIndex}} ) {
    my $e = $self->create_event();
    $e->{device}        = $device;
    $e->{standby_state} = $standby_state;
    $e->{cipSecTunStatus}         = $all->{cipSecTunStatus}->{$tid};
    $e->{cipSecTunIkeTunnelIndex} = $all->{cipSecTunIkeTunnelIndex}->{$tid};
    $e->{cipSecTunInPkts}         = $all->{cipSecTunInPkts}->{$tid};
    $e->{cipSecTunOutPkts}        = $all->{cipSecTunOutPkts}->{$tid};
    $e->{cipSecTunInOctets}       = $all->{cipSecTunInOctets}->{$tid};
    $e->{cipSecTunOutOctets}      = $all->{cipSecTunOutOctets}->{$tid};
    $e->{cipSecTunHcInOctets}     = $all->{cipSecTunHcInOctets}->{$tid};
    $e->{cipSecTunHcOutOctets}    = $all->{cipSecTunHcOutOctets}->{$tid};
    $e->{cipSecTunInDecrypts}     = $all->{cipSecTunInDecrypts}->{$tid};
    $e->{cipSecTunOutEncrypts}    = $all->{cipSecTunOutEncrypts}->{$tid};
    $e->{cipSecTunInDropPkts}       = $all->{cipSecTunInDropPkts}->{$tid};
    $e->{cipSecTunOutDropPkts}      = $all->{cipSecTunOutDropPkts}->{$tid};
    $e->{cipSecTunInDecompOctets}   = $all->{cipSecTunInDecompOctets}->{$tid};
    $e->{cipSecTunOutUncompOctets}  = $all->{cipSecTunOutUncompOctets}->{$tid};
    $e->{cipSecTunHcInDecompOctets}   = $all->{cipSecTunHcInDecompOctets}->{$tid};
    $e->{cipSecTunHcOutUncompOctets}  = $all->{cipSecTunHcOutUncompOctets}->{$tid};
    $e->{cipSecTunInDecryptFails}   = $all->{cipSecTunInDecryptFails}->{$tid};
    $e->{cipSecTunOutEncryptFails}  = $all->{cipSecTunOutEncryptFails}->{$tid};
    $e->{cipSecTunInAuths}          = $all->{cipSecTunInAuths}->{$tid};
    $e->{cipSecTunInAuthFails}      = $all->{cipSecTunInAuthFails}->{$tid};
    $e->{cipSecTunKeyType}          = $all->{cipSecTunKeyType}->{$tid};
    $e->{cipSecTunIkeTunnelAlive}   = $all->{cipSecTunIkeTunnelAlive}->{$tid};
    $e->{cipSecTunEncapMode}        = $all->{cipSecTunEncapMode}->{$tid};
    $e->{cipSecTunLifeTime}         = $all->{cipSecTunLifeTime}->{$tid};
    $e->{cipSecTunLifeSize}         = $all->{cipSecTunLifeSize}->{$tid};
    $e->{cipSecTunActiveTime}       = $all->{cipSecTunActiveTime}->{$tid};
    $e->{cipSecTunLocalAddr}        = $all->{cipSecTunLocalAddr}->{$tid};
    $e->{cipSecTunRemoteAddr}       = $all->{cipSecTunRemoteAddr}->{$tid};
    $e->{cipSecEndPtLocalAddr1}     = $all->{cipSecEndPtLocalAddr1}->{"$tid.1"};
    $e->{cipSecEndPtLocalAddr2}     = $all->{cipSecEndPtLocalAddr2}->{"$tid.1"};
    $e->{cipSecEndPtRemoteAddr1}    = $all->{cipSecEndPtRemoteAddr1}->{"$tid.1"};
    $e->{cipSecEndPtRemoteAddr2}    = $all->{cipSecEndPtRemoteAddr2}->{"$tid.1"};
    $self->push_to_transport($e);
  }

}

1;

# vim: set sw=2 ts=2 expandtab:

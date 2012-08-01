# $Id$

package SNMP::Info::Inmobi::Cisco::IPSEC;

use strict;
use Exporter;
use SNMP::Info::Inmobi::Cisco;

use Data::Dumper;

@SNMP::Info::Inmobi::Cisco::IPSEC::ISA = qw/SNMP::Info::Inmobi::Cisco Exporter/;
@SNMP::Info::Inmobi::Cisco::IPSEC::EXPORT_OK = qw//;

use vars qw/$VERSION %GLOBALS %MIBS %FUNCS %MUNGE/;

$VERSION = '2.06';

%MIBS = (
  %SNMP::Info::Inmobi::Cisco::MIBS,
  'CISCO-IPSEC-FLOW-MONITOR-MIB'  => 'cikeGlobalActiveTunnels',
);

%GLOBALS = (
  %SNMP::Info::Inmobi::Cisco::Globals,
  # CISCO-IPSEC-FLOW-MONITOR-MIB
  'cikeGlobalActiveTunnels'   => 'cikeGlobalActiveTunnels',
  'cikeGlobalInOctets'    => 'cikeGlobalInOctets',
  'cikeGlobalInPkts'      => 'cikeGlobalInPkts',
  'cikeGlobalInDropPkts'  => 'cikeGlobalInDropPkts',
  'cikeGlobalInNotifys'   => 'cikeGlobalInNotifys',
  'cikeGlobalOutOctets'   => 'cikeGlobalOutOctets',
  'cikeGlobalOutPkts'     => 'cikeGlobalOutPkts',
  'cikeGlobalOutDropPkts' => 'cikeGlobalOutDropPkts',
  'cikeGlobalOutNotifys'  => 'cikeGlobalOutNotifys',
  'cikeGlobalInitTunnels' => 'cikeGlobalInitTunnels',
  'cikeGlobalInitTunnelFails' => 'cikeGlobalInitTunnelFails',
  'cikeGlobalRespTunnelFails' => 'cikeGlobalRespTunnelFails',
  'cikeGlobalSysCapFails'     => 'cikeGlobalSysCapFails',
  'cikeGlobalAuthFails'       => 'cikeGlobalAuthFails',
  'cikeGlobalDecryptFails'    => 'cikeGlobalDecryptFails',
  'cikeGlobalHashValidFails'  => 'cikeGlobalHashValidFails',
  'cikeGlobalNoSaFails'       => 'cikeGlobalNoSaFails',

  'cipSecGlobalActiveTunnels' => 'cipSecGlobalActiveTunnels',
  'cipSecGlobalInOctets'  => 'cipSecGlobalInOctets',
  'cipSecGlobalHcInOctets'  => 'cipSecGlobalHcInOctets',
  'cipSecGlobalInDecompOctets'  => 'cipSecGlobalInDecompOctets',
  'cipSecGlobalHcInDecompOctets'  => 'cipSecGlobalHcInDecompOctets',
  'cipSecGlobalInPkts'  => 'cipSecGlobalInPkts',
  'cipSecGlobalInDrops' => 'cipSecGlobalInDrops',
  'cipSecGlobalInReplayDrops' => 'cipSecGlobalInReplayDrops',
  'cipSecGlobalInAuths' => 'cipSecGlobalInAuths',
  'cipSecGlobalInAuthFails' => 'cipSecGlobalInAuthFails',
  'cipSecGlobalInDecrypts'  => 'cipSecGlobalInDecrypts',
  'cipSecGlobalInDecryptFails'  => 'cipSecGlobalInDecryptFails',
  'cipSecGlobalOutOctets'   => 'cipSecGlobalOutOctets',
  'cipSecGlobalHcOutOctets' => 'cipSecGlobalHcOutOctets',
  'cipSecGlobalOutUncompOctets' => 'cipSecGlobalOutUncompOctets',
  'cipSecGlobalHcOutUncompOctets' => 'cipSecGlobalHcOutUncompOctets',
  'cipSecGlobalOutPkts' => 'cipSecGlobalOutPkts',
  'cipSecGlobalOutDrops'  => 'cipSecGlobalOutDrops',
  'cipSecGlobalOutAuths'  => 'cipSecGlobalOutAuths',
  'cipSecGlobalOutAuthFails'  => 'cipSecGlobalOutAuthFails',
  'cipSecGlobalOutEncrypts' => 'cipSecGlobalOutEncrypts',
  'cipSecGlobalOutEncryptFails' => 'cipSecGlobalOutEncryptFails',
  'cipSecGlobalProtocolUseFails'  => 'cipSecGlobalProtocolUseFails',
  'cipSecGlobalNoSaFails' => 'cipSecGlobalNoSaFails',
  'cipSecGlobalSysCapFails' => 'cipSecGlobalSysCapFails',
);

%FUNCS = (
  %SNMP::Info::Inmobi::Cisco::FUNCS,

  # CISCO-IPSEC-FLOW-MONITOR-MIB
  'cipSecTunIkeTunnelIndex' => 'cipSecTunIkeTunnelIndex',
  'cipSecTunIkeTunnelAlive' => 'cipSecTunIkeTunnelAlive',
  'cipSecTunLocalAddr'      => 'cipSecTunLocalAddr',
  'cipSecTunRemoteAddr'     => 'cipSecTunRemoteAddr',
  'cipSecTunKeyType'        => 'cipSecTunKeyType',
  'cipSecTunEncapMode'      => 'cipSecTunEncapMode',
  'cipSecTunLifeSize'       => 'cipSecTunLifeSize',
  'cipSecTunLifeTime'       => 'cipSecTunLifeTime',
  'cipSecTunActiveTime'     => 'cipSecTunActiveTime',
  'cipSecTunInOctets'       => 'cipSecTunInOctets',
  'cipSecTunOutOctets'      => 'cipSecTunOutOctets',
  'cipSecTunHcInOctets'     => 'cipSecTunHcInOctets',
  'cipSecTunHcOutOctets'    => 'cipSecTunHcOutOctets',
  'cipSecTunInDecompOctets' => 'cipSecTunInDecompOctets',
  'cipSecTunOutUncompOctets'  => 'cipSecTunOutUncompOctets',
  'cipSecTunHcInDecompOctets' => 'cipSecTunHcInDecompOctets',
  'cipSecTunHcOutUncompOctets'  => 'cipSecTunHcOutUncompOctets',
  'cipSecTunInPkts'       => 'cipSecTunInPkts',
  'cipSecTunOutPkts'      => 'cipSecTunOutPkts',
  'cipSecTunInDropPkts'   => 'cipSecTunInDropPkts',
  'cipSecTunOutDropPkts'  => 'cipSecTunOutDropPkts',
  'cipSecTunInAuths'      => 'cipSecTunInAuths',
  'cipSecTunInAuthFails'  => 'cipSecTunInAuthFails',
  'cipSecTunInDecrypts'   => 'cipSecTunInDecrypts',
  'cipSecTunOutEncrypts'  => 'cipSecTunOutEncrypts',
  'cipSecTunOutEncryptFails'=> 'cipSecTunOutEncryptFails',
  'cipSecTunInDecrypts'     => 'cipSecTunInDecrypts',
  'cipSecTunInDecryptFails' => 'cipSecTunInDecryptFails',
  'cipSecTunStatus'       => 'cipSecTunStatus',
  'cipSecEndPtLocalName'  => 'cipSecEndPtLocalName',
  'cipSecEndPtRemoteName' => 'cipSecEndPtRemoteName',
  'cipSecEndPtLocalType'  => 'cipSecEndPtLocalType',
  'cipSecEndPtRemoteType' => 'cipSecEndPtRemoteType',
  'cipSecEndPtLocalAddr1'   => 'cipSecEndPtLocalAddr1',
  'cipSecEndPtRemoteAddr1'  => 'cipSecEndPtRemoteAddr1',
  'cipSecEndPtLocalAddr2'   => 'cipSecEndPtLocalAddr2',
  'cipSecEndPtRemoteAddr2'  => 'cipSecEndPtRemoteAddr2',

  # CISCO-IPSEC-FLOW-MONITOR-MIB
  'cikeTunLocalValue' => 'cikeTunLocalValue',
  'cikeTunLocalAddr'  => 'cikeTunLocalAddr',
  'cikeTunLocalName'  => 'cikeTunLocalName',
  'cikeTunRemoteValue'  => 'cikeTunRemoteValue',
  'cikeTunRemoteAddr' => 'cikeTunRemoteAddr',
  'cikeTunRemoteName' => 'cikeTunRemoteName',
  'cikeTunLifeTime'   => 'cikeTunLifeTime',
  'cikeTunInOctets'   => 'cikeTunInOctets',
  'cikeTunInPkts'     => 'cikeTunInPkts',
  'cikeTunInDropPkts' => 'cikeTunInDropPkts',
  'cikeTunInNotifys'  => 'cikeTunInNotifys',
  'cikeTunOutOctets'  => 'cikeTunOutOctets',
  'cikeTunOutPkts'    => 'cikeTunOutPkts',
  'cikeTunOutDropPkts'=> 'cikeTunOutDropPkts',
  'cikeTunOutNotifys' => 'cikeTunOutNotifys',
  'cikeTunStatus'     => 'cikeTunStatus',
);

%MUNGE = (
  'cipSecTunRemoteAddr'   => \&SNMP::Info::munge_ip,
  'cipSecTunLocalAddr'    => \&SNMP::Info::munge_ip,
  'cipSecEndPtLocalAddr1' => \&SNMP::Info::munge_ip,
  'cipSecEndPtLocalAddr2' => \&SNMP::Info::munge_ip,
  'cipSecEndPtRemoteAddr1'  => \&SNMP::Info::munge_ip,
  'cipSecEndPtRemoteAddr2'  => \&SNMP::Info::munge_ip,
  'cikeTunLocalAddr'      => \&SNMP::Info::munge_ip,
  'cikeTunRemoteAddr'     => \&SNMP::Info::munge_ip,
);

sub ike_global_stats {
  my $self = shift;
  my $stats = {};

  $stats->{cikeGlobalActiveTunnels} = $self->cikeGlobalActiveTunnels;
  $stats->{cikeGlobalInOctets}      = $self->cikeGlobalInOctets;
  $stats->{cikeGlobalInPkts}        = $self->cikeGlobalInPkts;
  $stats->{cikeGlobalInDropPkts}    = $self->cikeGlobalInDropPkts;
  $stats->{cikeGlobalInNotifys}     = $self->cikeGlobalInNotifys;
  $stats->{cikeGlobalOutOctets}     = $self->cikeGlobalOutOctets;
  $stats->{cikeGlobalOutPkts}       = $self->cikeGlobalOutPkts;
  $stats->{cikeGlobalOutDropPkts}   = $self->cikeGlobalOutDropPkts;
  $stats->{cikeGlobalOutNotifys}    = $self->cikeGlobalOutNotifys;
  $stats->{cikeGlobalInitTunnels}   = $self->cikeGlobalInitTunnels;
  $stats->{cikeGlobalInitTunnelFails} = $self->cikeGlobalInitTunnelFails;
  $stats->{cikeGlobalRespTunnelFails} = $self->cikeGlobalRespTunnelFails;
  $stats->{cikeGlobalSysCapFails}   = $self->cikeGlobalSysCapFails;
  $stats->{cikeGlobalAuthFails}     = $self->cikeGlobalAuthFails;
  $stats->{cikeGlobalDecryptFails}  = $self->cikeGlobalDecryptFails;
  $stats->{cikeGlobalHashValidFails}  = $self->cikeGlobalHashValidFails;
  $stats->{cikeGlobalNoSaFails}     = $self->cikeGlobalNoSaFails;

  return $stats;
}

sub ipsec_global_stats {
  my $self = shift;
  my $stats = {};
  $stats->{cipSecGlobalActiveTunnels}   = $self->cipSecGlobalActiveTunnels;
  $stats->{cipSecGlobalInOctets}        = $self->cipSecGlobalInOctets;
  $stats->{cipSecGlobalHcInOctets}      = $self->cipSecGlobalHcInOctets;
  $stats->{cipSecGlobalInDecompOctets}  = $self->cipSecGlobalInDecompOctets;
  $stats->{cipSecGlobalHcInDecompOctets}  = $self->cipSecGlobalHcInDecompOctets;
  $stats->{cipSecGlobalInPkts}          = $self->cipSecGlobalInPkts;
  $stats->{cipSecGlobalInDrops}         = $self->cipSecGlobalInDrops;
  $stats->{cipSecGlobalInReplayDrops}   = $self->cipSecGlobalInReplayDrops;
  $stats->{cipSecGlobalInAuths}         = $self->cipSecGlobalInAuths;
  $stats->{cipSecGlobalInAuthFails}     = $self->cipSecGlobalInAuthFails;
  $stats->{cipSecGlobalInDecrypts}      = $self->cipSecGlobalInDecrypts;
  $stats->{cipSecGlobalInDecryptFails}  = $self->cipSecGlobalInDecryptFails;
  $stats->{cipSecGlobalOutOctets}       = $self->cipSecGlobalOutOctets;
  $stats->{cipSecGlobalHcOutOctets}     = $self->cipSecGlobalHcOutOctets;
  $stats->{cipSecGlobalOutUncompOctets} = $self->cipSecGlobalOutUncompOctets;
  $stats->{cipSecGlobalHcOutUncompOctets} = $self->cipSecGlobalHcOutUncompOctets;
  $stats->{cipSecGlobalOutPkts}         = $self->cipSecGlobalOutPkts;
  $stats->{cipSecGlobalOutDrops}        = $self->cipSecGlobalOutDrops;
  $stats->{cipSecGlobalOutAuths}        = $self->cipSecGlobalOutAuths;
  $stats->{cipSecGlobalOutAuthFails}    = $self->cipSecGlobalOutAuthFails;
  $stats->{cipSecGlobalOutEncrypts}     = $self->cipSecGlobalOutEncrypts;
  $stats->{cipSecGlobalOutEncryptFails} = $self->cipSecGlobalOutEncryptFails;
  $stats->{cipSecGlobalProtocolUseFails}= $self->cipSecGlobalProtocolUseFails;
  $stats->{cipSecGlobalNoSaFails}       = $self->cipSecGlobalNoSaFails;
  $stats->{cipSecGlobalSysCapFails}     = $self->cipSecGlobalSysCapFails;
  
  return $stats;
}

1;

# vim: set ts=2 sw=2 expandtab:

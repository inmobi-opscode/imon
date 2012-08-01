# $Id$

package SNMP::Info::Inmobi::Cisco::Firewall;

use strict;
use Exporter;
use SNMP::Info::Inmobi::Cisco;

use Data::Dumper;

@SNMP::Info::Inmobi::Cisco::Firewall::ISA = qw/SNMP::Info::Inmobi::Cisco Exporter/;
@SNMP::Info::Inmobi::Cisco::Firewall::EXPORT_OK = qw//;

use vars qw/$VERSION %GLOBALS %MIBS %FUNCS %MUNGE/;

$VERSION = '2.06';

%MIBS = (
  'CISCO-FIREWALL-MIB'            => 'cfwHardwareInformation',
  'CISCO-UNIFIED-FIREWALL-MIB'    => 'cufwConnGlobalNumActive',
);

%GLOBALS = (
);

%FUNCS = (
  # CISCO-FIREWALL-MIB
  'cfwHardwareInformation'        => 'cfwHardwareInformation',
  'cfwHardwareStatusValue'        => 'cfwHardwareStatusValue',
  'cfwHardwareStatusDetail'       => 'cfwHardwareStatusDetail',
  'cfwBufferStatInformation'      => 'cfwBufferStatInformation',
  'cfwBufferStatValue'            => 'cfwBufferStatValue',
  'cfwConnectionStatDescription'  => 'cfwConnectionStatDescription',
  'cfwConnectionStatCount'        => 'cfwConnectionStatCount',
  'cfwConnectionStatValue'        => 'cfwConnectionStatValue',

  # CISCO-UNIFIED-FIREWALL-MIB
  'cufwConnSetupRate1' => 'cufwConnSetupRate1',
  'cufwConnSetupRate5' => 'cufwConnSetupRate5',
);

%MUNGE = (
);

sub cufw_global_stats {
  my $self = shift;
  my $stats = {};

  $stats->{cufwConnGlobalNumAttempted}    = $self->cufwConnGlobalNumAttempted();
  $stats->{cufwConnGlobalNumSetupsAborted}  = $self->cufwConnGlobalNumSetupsAborted();
  $stats->{cufwConnGlobalNumPolicyDeclined} = $self->cufwConnGlobalNumPolicyDeclined();
  $stats->{cufwConnGlobalNumResDeclined}  = $self->cufwConnGlobalNumResDeclined();
  $stats->{cufwConnGlobalNumHalfOpen}     = $self->cufwConnGlobalNumHalfOpen;
  $stats->{cufwConnGlobalNumActive}       = $self->cufwConnGlobalNumActive();
  $stats->{cufwConnGlobalNumExpired}      = $self->cufwConnGlobalNumExpired;
  $stats->{cufwConnGlobalNumAborted}      = $self->cufwConnGlobalNumAborted;
  $stats->{cufwConnGlobalNumEmbryonic}    = $self->cufwConnGlobalNumEmbryonic;
  $stats->{cufwConnGlobalConnSetupRate1}  = $self->cufwConnGlobalConnSetupRate1();
  $stats->{cufwConnGlobalConnSetupRate5}  = $self->cufwConnGlobalConnSetupRate5();
  $stats->{cufwConnGlobalNumRemoteAccess} = $self->cufwConnGlobalNumRemoteAccess;

  return $stats;
}

1;

# vim: set ts=2 sw=2 expandtab:

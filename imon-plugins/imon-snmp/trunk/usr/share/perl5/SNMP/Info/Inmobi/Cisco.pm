# $Id$

package SNMP::Info::Inmobi::Cisco;

use strict;
use Exporter;
use SNMP::Info::Inmobi;
use SNMP::Info::Inmobi::Cisco::Firewall;
use SNMP::Info::Inmobi::Cisco::HSRP;
use SNMP::Info::Inmobi::Cisco::ENVMON;

use Data::Dumper;

@SNMP::Info::Inmobi::Cisco::ISA = qw/
  SNMP::Info::Inmobi
  SNMP::Info::Inmobi::Cisco::HSRP
  SNMP::Info::Inmobi::Cisco::ENVMON
  Exporter/;
@SNMP::Info::Inmobi::Cisco::EXPORT_OK = qw//;

use vars qw/$VERSION %MIBS %FUNCS %GLOBALS %MUNGE/;

$VERSION = '2.06';

%MIBS = (
  %SNMP::Info::Inmobi::MIBS,
  %SNMP::Info::Inmobi::Cisco::HSRP::MIBS,
  %SNMP::Info::Inmobi::Cisco::ENVMON::MIBS,
  %SNMP::Info::Inmobi::Cisco::Firewall::MIBS,
  'CISCO-PROCESS-MIB'     => 'cpmCPUTotal5sec',
  'CISCO-MEMORY-POOL-MIB' => 'ciscoMemoryPoolName',
);

%FUNCS = (
  %SNMP::Info::Inmobi::Cisco::ENVMON::FUNCS,

  # CISCO-MEMORY-POOL-MIB
  'ciscoMemoryPoolName'       => 'ciscoMemoryPoolName',
  'ciscoMemoryPoolAlternate'  => 'ciscoMemoryPoolAlternate',
  'ciscoMemoryPoolValid'      => 'ciscoMemoryPoolValid',
  'ciscoMemoryPoolUsed'       => 'ciscoMemoryPoolUsed',
  'ciscoMemoryPoolFree'       => 'ciscoMemoryPoolFree',
  'ciscoMemoryPoolLargestFree'=> 'ciscoMemoryPoolLargestFree',

  # CISCO-PROCESS-MIB
  'cpmCPUTotalPhysicalIndex' => 'cpmCPUTotalPhysicalIndex',
  'cpmCPUTotal5sec'  => 'cpmCPUTotal5sec',
  'cpmCPUTotal1min'  => 'cpmCPUTotal1min',
  'cpmCPUTotal5min'  => 'cpmCPUTotal5min',
);

%GLOBALS = (
  %SNMP::Info::Inmobi::Cisco::ENVMON::GLOBALS,
);

%MUNGE = (
  %SNMP::Info::Inmobi::Cisco::ENVMON::MUNGE,
);

sub vendor {
  return 'cisco';
}

sub standby_state {
  my $self = shift;
  my $state = undef;

  print "Getting standby_state...\n";

  # ASA case
  if ($self->sysDescr =~ /Cisco Adaptive Security Appliance/) {
    if (defined(my $cfw_hwinfo = $self->cfwHardwareInformation)) {
      if (defined(my $cfw_status = $self->cfwHardwareStatusValue)) {
        foreach my $unit (keys %$cfw_hwinfo) {
          if ($cfw_hwinfo->{$unit} =~ /\(this device\)/) {
            $state = $cfw_status->{$unit};
            last;
          }
        }
      }
    }
  } else {
    # Non ASA case
    if (defined(my $hsrp_state = $self->cHsrpGrpStandbyState())) {
      foreach (keys %$hsrp_state) {
        $state = $hsrp_state->{$_} if defined $hsrp_state->{$_};
        last;
      }
    }
  }
  return $state;
}

sub munge_cfw_network_protocol {
  my $oid = shift;
  my $name;

  # See CISCO-FIREWALL-TC.my::CFWNetworkProtocol
  my %e_class = (
    1   => 'none',
    2   => 'other',
    3   => 'ip',
    4   => 'icmp',
    5   => 'gre',
    6   => 'udp',
    7   => 'tcp',
  );
  if ( ( defined($oid) ) and ( exists( $e_class{$oid} ) ) ) {
    $name = $e_class{$oid};
  }
  return $name if defined($name);
  return $oid;
}

1;

# vim: set ts=2 sw=2 expandtab:

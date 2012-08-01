#
# $Id: OS.pm 7053 2012-04-13 10:31:45Z shanker.balan $
#

package SNMP::Info::Inmobi::OS;

use strict;
use Exporter;
use SNMP::Info::Inmobi;

use Data::Dumper;

@SNMP::Info::Inmobi::OS::ISA = qw/
  SNMP::Info::Inmobi
  Exporter/;

@SNMP::Info::Inmobi::OS::EXPORT_OK = qw//;

use vars qw/$VERSION %MIBS %FUNCS %GLOBALS %MUNGE/; 

$VERSION = '2.06';

%MIBS = (
  %SNMP::Info::Inmobi::MIBS,
  'NET-SNMP-TC'     => 'linux',
  'IF-MIB'          => 'ifNumber',
  'UCD-SNMP-MIB'    => 'memIndex',
  'UCD-DISKIO-MIB'  => 'diskIOIndex',
  'IP-MIB'          => 'ipForwarding',
  'IP-FORWARD-MIB'  => 'ipCidrRouteDest',
  'RFC1213-MIB'     => 'sysDescr',
  'HOST-RESOURCES-TYPES'  => 'hrStorageType',
  'HOST-RESOURCES-MIB'  => 'hrSystemNumUsers',
  'DISMAN-EVENT-MIB' => 'mteEventNotification',
);

%FUNCS = (
  %SNMP::Info::FUNCS,
  laIndex => 'laIndex',
  laNames => 'laNames',
  laLoad  => 'laLoad',
  laConfig  => 'laConfig',
  laLoadInt => 'laLoadInt',
  laLoadFloat => 'laLoadFloat',
  laErrorFlag => 'laErrorFlag',
  laErrMessage  => 'laErrMessage',

  hrStorageIndex  => 'hrStorageIndex',
  hrStorageType   => 'hrStorageType',
  hrStorageDescr  => 'hrStorageDescr',
  hrStorageAllocationUnits  => 'hrStorageAllocationUnits',
  hrStorageSize => 'hrStorageSize',
  hrStorageUsed => 'hrStorageUsed',

  # Todo
  hrDeviceIndex => 'hrDeviceIndex',
  hrDeviceType  => 'hrDeviceType',
  hrDeviceDescr => 'hrDeviceDescr',
  hrDeviceStatus  => 'hrDeviceStatus',
  hrDeviceErrors  => 'hrDeviceErrors',
  hrProcessorLoad => 'hrProcessorLoad',
  hrNetworkIfIndex  => 'hrNetworkIfIndex',

  hrFSIndex => 'hrFSIndex',
  hrFSMountPoint  => 'hrFSMountPoint',
  hrFSType  => 'hrFSType',
  hrFSAccess  => 'hrFSAccess',
  hrFSBootable  => 'hrFSBootable',
  hrFSRemoteMountPoint => 'hrFSRemoteMountPoint',
  hrFSStorageIndex  => 'hrFSStorageIndex',

  # Todo
  hrSWRunName => 'hrSWRunName',
  hrSWRunParameters => 'hrSWRunParameters',
  hrSWRunType => 'hrSWRunType',
  hrSWRunStatus => 'hrSWRunStatus',
  hrSWRunPerfCPU  => 'hrSWRunPerfCPU',
  hrSWRunPerfMem  => 'hrSWRunPerfMem',

  diskIOIndex => 'diskIOIndex',
  diskIODevice  => 'diskIODevice',
  diskIONRead => 'diskIONRead',
  diskIONWritten  => 'diskIONWritten',
  diskIOReads => 'diskIOReads',
  diskIOWrites => 'diskIOWrites',
  diskIONReadX => 'diskIONReadX',
  diskIONWrittenX => 'diskIONWrittenX',

  # IP-MIB
  ipAdEntAddr => 'ipAdEntAddr',
  ipAdEntIfIndex  => 'ipAdEntIfIndex',
  ipAdEntNetMask  => 'ipAdEntNetMask',
  ipAdEntBcastAddr  => 'ipAdEntBcastAddr',
  ipRouteDest => 'ipRouteDest',
  ipRouteIfIndex  => 'ipRouteIfIndex',
  ipRouteMetric1  => 'ipRouteMetric1',
  ipRouteNextHop  => 'ipRouteNextHop',
  ipRouteType => 'ipRouteType',
  ipRouteProto  => 'ipRouteProto',
  ipRouteMask => 'ipRouteMask',
  ipRouteInfo => 'ipRouteInfo',
  ipNetToMediaIfIndex => 'ipNetToMediaIfIndex',
  ipNetToMediaPhysAddress => 'ipNetToMediaPhysAddress',
  ipNetToMediaNetAddress  => 'ipNetToMediaNetAddress',
  ipNetToMediaType  => 'ipNetToMediaType',

  tcpConnState  => 'tcpConnState',
  tcpConnLocalAddress => 'tcpConnLocalAddress',
  tcpConnLocalPort  => 'tcpConnLocalPort',
  tcpConnRemAddress => 'tcpConnRemAddress',
  tcpConnRemPort  => 'tcpConnRemPort',
  tcpConnectionState => 'tcpConnectionState',
  tcpConnectionProcess => 'tcpConnectionProcess',
  tcpListenerProcess => 'tcpListenerProcess',

  # UDP-MIB
  udpLocalAddress => 'udpLocalAddress',
  udpLocalPort  => 'udpLocalPort',
  udpEndpointProcess => 'udpEndpointProcess',
);

%GLOBALS = (
);

%MUNGE = (
  # Inherit all the built in munging
  %SNMP::Info::MUNGE,
  'sysObjectID'   => \&SNMP::Info::munge_e_type,
  'hrStorageType' => \&SNMP::Info::munge_e_type,
  'hrDeviceType'  => \&SNMP::Info::munge_e_type,
  'hrFSType'      => \&SNMP::Info::munge_e_type,
  'hrSystemDate'  => \&SNMP::Info::munge_bits,
  'ipNetToMediaPhysAddress' => \&SNMP::Info::munge_mac,
);

my %keys = (
  # SNMPv2-MIB
  sys => [
    'sysDescr', 'sysObjectID', 'sysUpTime', 'sysContact', 'sysName', 'sysLocation', 'sysServices'
  ],
  # hostResource
  hr => [
    'hrSystemUptime', 'hrSystemDate', 'hrSystemInitialLoadDevice', 'hrSystemInitialLoadParameters',
    'hrSystemNumUsers', 'hrSystemProcesses', 'hrSystemMaxProcesses', 'hrMemorySize'
  ],
  # systemStats
  ss => [
    'ssIndex', 'ssErrorName', 'ssSwapIn', 'ssSwapOut', 'ssIOSent', 'ssIOReceive',
    'ssSysInterrupts', 'ssSysContext', 'ssCpuUser', 'ssCpuSystem', 'ssCpuIdle',
    'ssCpuRawUser', 'ssCpuRawNice', 'ssCpuRawSystem', 'ssCpuRawIdle', 'ssCpuRawWait',
    'ssCpuRawKernel', 'ssCpuRawInterrupt', 'ssIORawSent', 'ssIORawReceived',
    'ssRawInterrupts', 'ssRawContexts', 'ssCpuRawSoftIRQ', 'ssRawSwapIn', 'ssRawSwapOut'
  ],
  # IP-MIB
  ip => [
    'ipForwarding', 'ipInReceives', 'ipInHdrErrors', 'ipDefaultTTL', 'ipInHdrErrors',
    'ipInAddrErrors', 'ipForwDatagrams', 'ipInUnknownProtos', 'ipInDiscards',
    'ipInDelivers', 'ipOutRequests', 'ipOutDiscards', 'ipOutNoRoutes', 'ipReasmTimeout',
    'ipReasmReqds', 'ipReasmOKs', 'ipReasmFails', 'ipFragOKs', 'ipFragFails',
    'ipFragCreates', 'ipRoutingDiscards' 
  ],
  icmp  => [
    'icmpInMsgs', 'icmpInErrors', 'icmpInDestUnreachs', 'icmpInTimeExcds',
    'icmpInParmProbs', 'icmpInSrcQuenchs', 'icmpInRedirects', 'icmpInEchos', 'icmpInEchoReps',
    'icmpInTimestamps', 'icmpInTimestampReps', 'icmpInAddrMasks', 'icmpInAddrMaskReps',
    'icmpOutMsgs', 'icmpOutErrors', 'icmpOutDestUnreachs', 'icmpOutTimeExcds',
    'icmpOutParmProbs', 'icmpOutSrcQuenchs', 'icmpOutRedirects', 'icmpOutEchos', 'icmpOutEchoReps',
    'icmpOutTimestamps', 'icmpOutTimestampReps', 'icmpOutAddrMasks', 'icmpOutAddrMaskReps'
  ],
  tcp => [
    'tcpRtoAlgorithm', 'tcpRtoMin', 'tcpRtoMax', 'tcpMaxConn', 'tcpActiveOpens', 'tcpPassiveOpens',
    'tcpAttemptFails', 'tcpEstabResets', 'tcpCurrEstab', 'tcpInSegs', 'tcpOutSegs', 'tcpRetransSegs',
    'tcpInErrs', 'tcpOutRsts',
  ],
  udp => [
    'udpInDatagrams', 'udpNoPorts', 'udpInErrors', 'udpOutDatagrams'
  ],
  # SNMPv2-MIB
  snmp => [
    'snmpInPkts', 'snmpOutPkts', 'snmpInBadVersions', 'snmpInBadCommunityNames',
    'snmpInBadCommunityUses', 'snmpInASNParseErrs', 'snmpInTooBigs', 'snmpInNoSuchNames',
    'snmpInBadValues', 'snmpInReadOnlys', 'snmpInGenErrs', 'snmpInTotalReqVars',
    'snmpInTotalSetVars', 'snmpInGetRequests', 'snmpInGetNexts', 'snmpInSetRequests',
    'snmpInGetResponses', 'snmpInTraps', 'snmpOutTooBigs', 'snmpOutNoSuchNames', 'snmpOutBadValues',
    'snmpOutGenErrs', 'snmpOutGetRequests', 'snmpOutGetNexts', 'snmpOutSetRequests',
    'snmpOutGetResponses', 'snmpOutTraps', 'snmpEnableAuthenTraps', 'snmpSilentDrops',
    'snmpProxyDrops', 'snmperrIndex', 'snmperrNames', 'snmperrErrorFlag', 'snmperrErrMessage',
  ],
  # UCD-SNMP-MIB
  mem => [
    'memIndex', 'memErrorName', 'memTotalSwap', 'memAvailSwap', 'memTotalReal', 'memAvailReal',
    'memTotalFree', 'memMinimumSwap', 'memBuffer', 'memCached', 'memSwapError', 'memSwapErrorMsg',
  ],
  version => [
    'versionIndex', 'versionTag', 'versionDate', 'versionCDate', 'versionIdent'
  ],
);

sub stats {
  my ($self, $type) = @_;
  my $stats = {};
  
  return unless defined $type;
  return unless defined $keys{$type};

  foreach my $s (sort @{$keys{$type}}) {
    $stats->{$s} = $self->$s;
  }

  return $stats;
}

sub get_all_stats {
}

1;

# vim: set ts=2 sw=2 expandtab:

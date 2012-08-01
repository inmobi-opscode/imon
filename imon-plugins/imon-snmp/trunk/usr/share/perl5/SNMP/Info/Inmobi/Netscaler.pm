# $Id: Netscaler.pm 4890 2012-01-23 16:05:03Z twikiuser $

package SNMP::Info::Inmobi::Netscaler;

use strict;
use Exporter;
use SNMP::Info;
use SNMP::Info::Inmobi;

@SNMP::Info::Inmobi::Netscaler::ISA = qw/SNMP::Info Exporter/;
@SNMP::Info::Inmobi::Netscaler::EXPORT_OK = qw//;

use vars qw/$VERSION %MIBS %FUNCS %GLOBALS %MUNGE/;

$VERSION = '2.06';

%MIBS = (
  'NS-ROOT-MIB' => 'sysBuildVersion',
);

%FUNCS = (
  # vsvrCurServicesDown
  vsvrActiveActiveState => 'vsvrActiveActiveState', # ActiveActiveState
  vsvrClientConnOpenRate => 'vsvrClientConnOpenRate', # OCTET STRING
  vsvrCurClntConnections => 'vsvrCurClntConnections', # Gauge32
  vsvrCurServicesDown => 'vsvrCurServicesDown', # Gauge32
  vsvrCurServicesOutOfSvc => 'vsvrCurServicesOutOfSvc', # Gauge32
  vsvrCurServicesTransToOutOfSvc => 'vsvrCurServicesTransToOutOfSvc', # Gauge32
  vsvrCurServicesUnKnown => 'vsvrCurServicesUnKnown', # Gauge32
  vsvrCurServicesUp => 'vsvrCurServicesUp', # Gauge32
  vsvrCurSrvrConnections => 'vsvrCurSrvrConnections', # Gauge32
  vsvrCurSslVpnUsers => 'vsvrCurSslVpnUsers', # Gauge32
  vsvrEntityType => 'vsvrEntityType', # VServerType
  vsvrFullName => 'vsvrFullName', # OCTET STRING
  vsvrHealth => 'vsvrHealth', # Integer32
  vsvrIp6Address => 'vsvrIp6Address', # Ipv6Address
  vsvrIpAddress => 'vsvrIpAddress', # IpAddress
  vsvrName => 'vsvrName', # OCTET STRING
  vsvrPort => 'vsvrPort', # Integer32
  vsvrRequestRate => 'vsvrRequestRate', # OCTET STRING
  vsvrRxBytesRate => 'vsvrRxBytesRate', # OCTET STRING
  vsvrState => 'vsvrState', # EntityState
  vsvrSurgeCount => 'vsvrSurgeCount', # Counter32
  vsvrSynfloodRate => 'vsvrSynfloodRate', # OCTET STRING
  vsvrTicksSinceLastStateChange => 'vsvrTicksSinceLastStateChange', # TimeTicks
  vsvrTotHits => 'vsvrTotHits', # Counter64
  vsvrTotMiss => 'vsvrTotMiss', # Counter64
  vsvrTotSpillOvers => 'vsvrTotSpillOvers', # Counter32
  vsvrTotalClients => 'vsvrTotalClients', # Counter64
  vsvrTotalPktsRecvd => 'vsvrTotalPktsRecvd', # Counter64
  vsvrTotalPktsSent => 'vsvrTotalPktsSent', # Counter64
  vsvrTotalRequestBytes => 'vsvrTotalRequestBytes', # Counter64
  vsvrTotalRequests => 'vsvrTotalRequests', # Counter64
  vsvrTotalResponseBytes => 'vsvrTotalResponseBytes', # Counter64
  vsvrTotalResponses => 'vsvrTotalResponses', # Counter64
  vsvrTotalServers => 'vsvrTotalServers', # Counter64
  vsvrTotalServicesBound => 'vsvrTotalServicesBound', # Gauge32
  vsvrTotalSynsRecvd => 'vsvrTotalSynsRecvd', # Counter64
  vsvrTxBytesRate => 'vsvrTxBytesRate', # OCTET STRING
  vsvrType => 'vsvrType', # EntityProtocolType

  # serviceEntry
  svcActiveConn => 'svcActiveConn', # Gauge32
  svcActiveTransactions => 'svcActiveTransactions', # Gauge32
  svcAvgSvrTTFB => 'svcAvgSvrTTFB', # Gauge32
  svcAvgTransactionTime => 'svcAvgTransactionTime', # TimeTicks
  svcCurClntConnections => 'svcCurClntConnections', # Gauge32
  svcEstablishedConn => 'svcEstablishedConn', # Counter32
  svcGslbSiteName => 'svcGslbSiteName', # OCTET STRING
  svcInetAddress => 'svcInetAddress', # InetAddress
  svcInetAddressType => 'svcInetAddressType', # InetAddressType
  svcIpAddress => 'svcIpAddress', # IpAddress
  svcMaxClients => 'svcMaxClients', # Integer32
  svcMaxReqPerConn => 'svcMaxReqPerConn', # Integer32
  svcPort => 'svcPort', # Integer32
  svcRequestRate => 'svcRequestRate', # OCTET STRING
  svcRxBytesRate => 'svcRxBytesRate', # OCTET STRING
  svcServiceFullName => 'svcServiceFullName', # OCTET STRING
  svcServiceName => 'svcServiceName', # OCTET STRING
  svcServiceType => 'svcServiceType', # EntityProtocolType
  svcState => 'svcState', # EntityState
  svcSurgeCount => 'svcSurgeCount', # Counter32
  svcSynfloodRate => 'svcSynfloodRate', # OCTET STRING
  svcTicksSinceLastStateChange => 'svcTicksSinceLastStateChange', # TimeTicks
  svcTotalClients => 'svcTotalClients', # Counter64
  svcTotalPktsRecvd => 'svcTotalPktsRecvd', # Counter64
  svcTotalPktsSent => 'svcTotalPktsSent', # Counter64
  svcTotalRequestBytes => 'svcTotalRequestBytes', # Counter64
  svcTotalRequests => 'svcTotalRequests', # Counter64
  svcTotalResponseBytes => 'svcTotalResponseBytes', # Counter64
  svcTotalResponses => 'svcTotalResponses', # Counter64
  svcTotalServers => 'svcTotalServers', # Counter64
  svcTotalSynsRecvd => 'svcTotalSynsRecvd', # Counter64
  svcTxBytesRate => 'svcTxBytesRate', # OCTET STRING
  svcdosQDepth => 'svcdosQDepth', # Counter32
  svctotalJsTransactions => 'svctotalJsTransactions', # Counter64

  # serverEntry
  serverDelay => 'serverDelay', # Integer32
  serverFullName => 'serverFullName', # OCTET STRING
  serverInetAddress => 'serverInetAddress', # InetAddress
  serverInetAddressType => 'serverInetAddressType', # InetAddressType
  serverIpAddress => 'serverIpAddress', # IpAddress
  serverName => 'serverName', # OCTET STRING
  serverState => 'serverState', # EntityState

  # monitorMemberEntry
  alarmProbeFailedRetries => 'alarmProbeFailedRetries', # Integer32
  destinationIP => 'destinationIP', # IpAddress
  destinationInetAddress => 'destinationInetAddress', # InetAddress
  destinationInetAddressType => 'destinationInetAddressType', # InetAddressType
  destinationPort => 'destinationPort', # Integer32
  drtmActiveMonitors => 'drtmActiveMonitors', # Integer32
  drtmCumResponseTimeout => 'drtmCumResponseTimeout', # Gauge32
  drtmDeviation => 'drtmDeviation', # Integer32
  monitorDowntime => 'monitorDowntime', # Integer32
  monitorInterval => 'monitorInterval', # Integer32
  monitorName => 'monitorName', # OCTET STRING
  monitorResponseTimeout => 'monitorResponseTimeout', # Integer32
  monitorRetrys => 'monitorRetrys', # Integer32
  monitorType => 'monitorType', # MonitorType
  responseTimeoutThreshold => 'responseTimeoutThreshold', # Integer32

  # monServiceMemberEntry
  alarmMonrespto => 'alarmMonrespto', # Gauge32
  drtmLearningProbes => 'drtmLearningProbes', # Gauge32
  drtmRTO => 'drtmRTO', # Gauge32
  monServiceName => 'monServiceName', # OCTET STRING
  monitorCurFailedCount => 'monitorCurFailedCount', # Gauge32
  monitorFailed => 'monitorFailed', # Counter32
  monitorFailedCode => 'monitorFailedCode', # Counter32
  monitorFailedCon => 'monitorFailedCon', # Counter32
  monitorFailedFTP => 'monitorFailedFTP', # Counter32
  monitorFailedId => 'monitorFailedId', # Counter32
  monitorFailedPort => 'monitorFailedPort', # Counter32
  monitorFailedResponse => 'monitorFailedResponse', # Counter32
  monitorFailedSend => 'monitorFailedSend', # Counter32
  monitorFailedStr => 'monitorFailedStr', # Counter32
  monitorFailedTimeout => 'monitorFailedTimeout', # Counter32
  monitorMaxClient => 'monitorMaxClient', # Counter32
  monitorProbes => 'monitorProbes', # Counter32
  monitorProbesNoChange => 'monitorProbesNoChange', # Counter32
  monitorRTO => 'monitorRTO', # Gauge32
  monitorResponseTimeoutThreshExceed => 'monitorResponseTimeoutThreshExceed', # Counter32
  monitorState => 'monitorState', # MonitorState
  monitorWeight => 'monitorWeight', # Integer32

  # vserverServiceEntry
  servicePersistentHits => 'servicePersistentHits', # Counter64
  serviceWeight => 'serviceWeight', # Integer32
  vserverFullName => 'vserverFullName', # OCTET STRING
  vsvrServiceEntityType => 'vsvrServiceEntityType', # SvcEntityType
  vsvrServiceFullName => 'vsvrServiceFullName', # OCTET STRING
  vsvrServiceHits => 'vsvrServiceHits', # Counter64
  vsvrServiceName => 'vsvrServiceName', # OCTET STRING

  # lbvserverEntry
  lbvsvrActiveConn => 'lbvsvrActiveConn', # Gauge32
  lbvsvrAvgSvrTTFB => 'lbvsvrAvgSvrTTFB', # Gauge32
  lbvsvrLBMethod => 'lbvsvrLBMethod', # LbPolicy
  lbvsvrPersistanceType => 'lbvsvrPersistanceType', # PersistanceType
  lbvsvrPersistenceTimeOut => 'lbvsvrPersistenceTimeOut', # Integer32

  # nsCPUEntry
  nsCPUname => 'nsCPUname', # OCTET STRING
  nsCPUusage => 'nsCPUusage', # Gauge32

  # nsSysHealthEntry
  sysHealthCounterName => 'sysHealthCounterName', # OCTET STRING
  sysHealthCounterValue => 'sysHealthCounterValue', # Integer32

  # nsSysHealthDiskEntry
  sysHealthDiskAvail => 'sysHealthDiskAvail', # Gauge32
  sysHealthDiskName => 'sysHealthDiskName', # OCTET STRING
  sysHealthDiskPerusage => 'sysHealthDiskPerusage', # Gauge32
  sysHealthDiskSize => 'sysHealthDiskSize', # Gauge32
  sysHealthDiskUsed => 'sysHealthDiskUsed', # Gauge32

  # vlanEntry
  vlanBridgeGroup => 'vlanBridgeGroup', # Integer32
  vlanId => 'vlanId', # Integer32
  vlanMemberInterfaces => 'vlanMemberInterfaces', # OCTET STRING
  vlanTaggedInterfaces => 'vlanTaggedInterfaces', # OCTET STRING
  vlanTotBroadcastPkts => 'vlanTotBroadcastPkts', # Counter64
  vlanTotDroppedPkts => 'vlanTotDroppedPkts', # Counter64
  vlanTotRxBytes => 'vlanTotRxBytes', # Counter64
  vlanTotRxPkts => 'vlanTotRxPkts', # Counter64
  vlanTotTxBytes => 'vlanTotTxBytes', # Counter64
  vlanTotTxPkts => 'vlanTotTxPkts', # Counter64

  # nsIfStatsEntry
  ifErrCongestedPktsDrops => 'ifErrCongestedPktsDrops', # Counter64
  ifErrCongestionLimitPktDrops => 'ifErrCongestionLimitPktDrops', # Counter64
  ifErrDroppedRxPkts => 'ifErrDroppedRxPkts', # Counter64
  ifErrDroppedTxPkts => 'ifErrDroppedTxPkts', # Counter64
  ifErrDuplexMismatch => 'ifErrDuplexMismatch', # Counter32
  ifErrLinkHangs => 'ifErrLinkHangs', # Counter32
  ifErrPktRx => 'ifErrPktRx', # Counter64
  ifErrPktTx => 'ifErrPktTx', # Counter64
  ifErrRxFCS => 'ifErrRxFCS', # Counter64
  ifErrRxFIFO => 'ifErrRxFIFO', # Counter64
  ifErrRxNoBuffs => 'ifErrRxNoBuffs', # Counter64
  ifErrTxDeferred => 'ifErrTxDeferred', # Counter64
  ifErrTxFIFO => 'ifErrTxFIFO', # Counter64
  ifErrTxHeartBeat => 'ifErrTxHeartBeat', # Counter64
  ifErrTxNoNSB => 'ifErrTxNoNSB', # Counter64
  ifErrTxOverflow => 'ifErrTxOverflow', # Counter64
  ifLinkReinits => 'ifLinkReinits', # Counter32
  ifMedia => 'ifMedia', # OCTET STRING
  ifMinThroughput => 'ifMinThroughput', # Integer32
  ifName => 'ifName', # OCTET STRING
  ifRxAlignmentErrors => 'ifRxAlignmentErrors', # Counter64
  ifRxAvgBandwidthUsage => 'ifRxAvgBandwidthUsage', # Gauge32
  ifRxAvgPacketRate => 'ifRxAvgPacketRate', # Gauge32
  ifRxCRCErrors => 'ifRxCRCErrors', # Counter64
  ifRxFrameErrors => 'ifRxFrameErrors', # Counter64
  ifThroughput => 'ifThroughput', # Gauge32
  ifTotNetScalerPkts => 'ifTotNetScalerPkts', # Counter64
  ifTotRxBytes => 'ifTotRxBytes', # Counter64
  ifTotRxMbits => 'ifTotRxMbits', # Counter64
  ifTotRxPkts => 'ifTotRxPkts', # Counter64
  ifTotRxXoffPause => 'ifTotRxXoffPause', # Counter64
  ifTotRxXonPause => 'ifTotRxXonPause', # Counter64
  ifTotTxBytes => 'ifTotTxBytes', # Counter64
  ifTotTxMbits => 'ifTotTxMbits', # Counter64
  ifTotTxPkts => 'ifTotTxPkts', # Counter64
  ifTotXoffSent => 'ifTotXoffSent', # Counter64
  ifTotXoffStateEntered => 'ifTotXoffStateEntered', # Counter64
  ifTotXonSent => 'ifTotXonSent', # Counter64
  ifTxAvgBandwidthUsage => 'ifTxAvgBandwidthUsage', # Gauge32
  ifTxAvgPacketRate => 'ifTxAvgPacketRate', # Gauge32
  ifTxCarrierError => 'ifTxCarrierError', # Counter64
  ifTxCollisions => 'ifTxCollisions', # Counter64
  ifTxExcessCollisions => 'ifTxExcessCollisions', # Counter64
  ifTxLateCollisions => 'ifTxLateCollisions', # Counter64
  ifTxMultiCollisionErrors => 'ifTxMultiCollisionErrors', # Counter64
  ifnicErrDisables => 'ifnicErrDisables', # Counter32
  ifnicRxStalls => 'ifnicRxStalls', # Counter32
  ifnicStsStalls => 'ifnicStsStalls', # Counter32
  ifnicTxStalls => 'ifnicTxStalls', # Counter32


);

%GLOBALS = (

  # nsResourceGroup
  cpuSpeedMHz => 'cpuSpeedMHz', # Integer32
  memSizeMB => 'memSizeMB', # Integer32
  numCPUs => 'numCPUs', # Integer32
  numPEs => 'numPEs', # Integer32
  numSSLCards => 'numSSLCards', # Integer32
  resCpuUsage => 'resCpuUsage', # Gauge32
  resMemUsage => 'resMemUsage', # Gauge32

  # nsIpStatsGroup
  ipTotAddrLookup => 'ipTotAddrLookup', # Counter64
  ipTotAddrLookupFail => 'ipTotAddrLookupFail', # Counter64
  ipTotBadChecksums => 'ipTotBadChecksums', # Counter64
  ipTotBadMacAddrs => 'ipTotBadMacAddrs', # Counter64
  ipTotBadTransport => 'ipTotBadTransport', # Counter64
  ipTotBadlens => 'ipTotBadlens', # Counter64
  ipTotDupFragments => 'ipTotDupFragments', # Counter64
  ipTotFixHeaderFail => 'ipTotFixHeaderFail', # Counter64
  ipTotFragPktsGen => 'ipTotFragPktsGen', # Counter64
  ipTotFragments => 'ipTotFragments', # Counter64
  ipTotInvalidHeaderSz => 'ipTotInvalidHeaderSz', # Counter64
  ipTotInvalidPacketSize => 'ipTotInvalidPacketSize', # Counter64
  ipTotLandattacks => 'ipTotLandattacks', # Counter64
  ipTotMaxClients => 'ipTotMaxClients', # Counter64
  ipTotOutOfOrderFrag => 'ipTotOutOfOrderFrag', # Counter64
  ipTotReassemblyAttempt => 'ipTotReassemblyAttempt', # Counter64
  ipTotRxBytes => 'ipTotRxBytes', # Counter64
  ipTotRxMbits => 'ipTotRxMbits', # Counter64
  ipTotRxPkts => 'ipTotRxPkts', # Counter64
  ipTotSuccReassembly => 'ipTotSuccReassembly', # Counter64
  ipTotTCPfragmentsFwd => 'ipTotTCPfragmentsFwd', # Counter64
  ipTotTooBig => 'ipTotTooBig', # Counter64
  ipTotTruncatedPackets => 'ipTotTruncatedPackets', # Counter64
  ipTotTtlExpired => 'ipTotTtlExpired', # Counter64
  ipTotTxBytes => 'ipTotTxBytes', # Counter64
  ipTotTxMbits => 'ipTotTxMbits', # Counter64
  ipTotTxPkts => 'ipTotTxPkts', # Counter64
  ipTotUDPfragmentsFwd => 'ipTotUDPfragmentsFwd', # Counter64
  ipTotUnknownDstRcvd => 'ipTotUnknownDstRcvd', # Counter64
  ipTotUnknownSvcs => 'ipTotUnknownSvcs', # Counter64
  ipTotUnsuccReassembly => 'ipTotUnsuccReassembly', # Counter64
  ipTotVIPDown => 'ipTotVIPDown', # Counter64
  ipTotZeroFragmentLen => 'ipTotZeroFragmentLen', # Counter64
  ipTotZeroNextHop => 'ipTotZeroNextHop', # Counter64
  nonIpTotTruncatedPackets => 'nonIpTotTruncatedPackets', # Counter64

  # nsIcmpStatsGroup
  icmpCurRateThreshold => 'icmpCurRateThreshold', # Integer32
  icmpTotBadChecksum => 'icmpTotBadChecksum', # Counter64
  icmpTotBadPMTUIpChecksum => 'icmpTotBadPMTUIpChecksum', # Counter64
  icmpTotBigNextMTU => 'icmpTotBigNextMTU', # Counter64
  icmpTotDstIpLookup => 'icmpTotDstIpLookup', # Counter64
  icmpTotInvalidBodyLen => 'icmpTotInvalidBodyLen', # Counter64
  icmpTotInvalidNextMTUval => 'icmpTotInvalidNextMTUval', # Counter64
  icmpTotInvalidProtocol => 'icmpTotInvalidProtocol', # Counter64
  icmpTotInvalidTcpSeqno => 'icmpTotInvalidTcpSeqno', # Counter64
  icmpTotNeedFragRx => 'icmpTotNeedFragRx', # Counter64
  icmpTotNoTcpConn => 'icmpTotNoTcpConn', # Counter64
  icmpTotNoUdpConn => 'icmpTotNoUdpConn', # Counter64
  icmpTotNonFirstIpFrag => 'icmpTotNonFirstIpFrag', # Counter64
  icmpTotPMTUDiscoveryDisabled => 'icmpTotPMTUDiscoveryDisabled', # Counter64
  icmpTotPMTUnoLink => 'icmpTotPMTUnoLink', # Counter64
  icmpTotPktsDropped => 'icmpTotPktsDropped', # Counter64
  icmpTotPortUnreachableRx => 'icmpTotPortUnreachableRx', # Counter64
  icmpTotPortUnreachableTx => 'icmpTotPortUnreachableTx', # Counter64
  icmpTotRxBytes => 'icmpTotRxBytes', # Counter64
  icmpTotRxEcho => 'icmpTotRxEcho', # Counter64
  icmpTotRxEchoReply => 'icmpTotRxEchoReply', # Counter64
  icmpTotRxPkts => 'icmpTotRxPkts', # Counter64
  icmpTotThresholdExceeds => 'icmpTotThresholdExceeds', # Counter64
  icmpTotTxBytes => 'icmpTotTxBytes', # Counter64
  icmpTotTxEchoReply => 'icmpTotTxEchoReply', # Counter64
  icmpTotTxPkts => 'icmpTotTxPkts', # Counter64

  # nsUdpStatsGroup
  udpBadChecksum => 'udpBadChecksum', # Counter64
  udpCurRateThreshold => 'udpCurRateThreshold', # Counter32
  udpCurRateThresholdExceeds => 'udpCurRateThresholdExceeds', # Counter64
  udpTotRxBytes => 'udpTotRxBytes', # Counter64
  udpTotRxPkts => 'udpTotRxPkts', # Counter64
  udpTotTxBytes => 'udpTotTxBytes', # Counter64
  udpTotTxPkts => 'udpTotTxPkts', # Counter64
  udpTotUnknownSvcPkts => 'udpTotUnknownSvcPkts', # Counter64

  # nsTcpStatsGroup
  pcbTotZombieCall => 'pcbTotZombieCall', # Counter64
  tcpActiveServerConn => 'tcpActiveServerConn', # Gauge32
  tcpCurClientConn => 'tcpCurClientConn', # Gauge32
  tcpCurClientConnClosing => 'tcpCurClientConnClosing', # Gauge32
  tcpCurClientConnEstablished => 'tcpCurClientConnEstablished', # Gauge32
  tcpCurClientConnOpening => 'tcpCurClientConnOpening', # Gauge32
  tcpCurPhysicalServers => 'tcpCurPhysicalServers', # Gauge32
  tcpCurServerConn => 'tcpCurServerConn', # Gauge32
  tcpCurServerConnClosing => 'tcpCurServerConnClosing', # Gauge32
  tcpCurServerConnEstablished => 'tcpCurServerConnEstablished', # Gauge32
  tcpCurServerConnOpening => 'tcpCurServerConnOpening', # Gauge32
  tcpErrAnyPortFail => 'tcpErrAnyPortFail', # Counter64
  tcpErrBadCheckSum => 'tcpErrBadCheckSum', # Counter64
  tcpErrBadStateConn => 'tcpErrBadStateConn', # Counter64
  tcpErrCltHole => 'tcpErrCltHole', # Counter64
  tcpErrCltOutOfOrder => 'tcpErrCltOutOfOrder', # Counter64
  tcpErrCltRetrasmit => 'tcpErrCltRetrasmit', # Counter64
  tcpErrCookiePktMssReject => 'tcpErrCookiePktMssReject', # Counter64
  tcpErrCookiePktSeqDrop => 'tcpErrCookiePktSeqDrop', # Counter64
  tcpErrCookiePktSeqReject => 'tcpErrCookiePktSeqReject', # Counter64
  tcpErrCookiePktSigReject => 'tcpErrCookiePktSigReject', # Counter64
  tcpErrDataAfterFin => 'tcpErrDataAfterFin', # Counter64
  tcpErrFastRetransmissions => 'tcpErrFastRetransmissions', # Counter64
  tcpErrFifthRetransmissions => 'tcpErrFifthRetransmissions', # Counter64
  tcpErrFinDup => 'tcpErrFinDup', # Counter64
  tcpErrFinGiveUp => 'tcpErrFinGiveUp', # Counter64
  tcpErrFinRetry => 'tcpErrFinRetry', # Counter64
  tcpErrFirstRetransmissions => 'tcpErrFirstRetransmissions', # Counter64
  tcpErrForthRetransmissions => 'tcpErrForthRetransmissions', # Counter64
  tcpErrFullRetrasmit => 'tcpErrFullRetrasmit', # Counter64
  tcpErrIpPortFail => 'tcpErrIpPortFail', # Counter64
  tcpErrOutOfWindowPkts => 'tcpErrOutOfWindowPkts', # Counter64
  tcpErrPartialRetrasmit => 'tcpErrPartialRetrasmit', # Counter64
  tcpErrRetransmit => 'tcpErrRetransmit', # Counter64
  tcpErrRetransmitGiveUp => 'tcpErrRetransmitGiveUp', # Counter64
  tcpErrRst => 'tcpErrRst', # Counter64
  tcpErrRstInTimewait => 'tcpErrRstInTimewait', # Counter64
  tcpErrRstNonEst => 'tcpErrRstNonEst', # Counter64
  tcpErrRstOutOfWindow => 'tcpErrRstOutOfWindow', # Counter64
  tcpErrRstThreshold => 'tcpErrRstThreshold', # Counter64
  tcpErrSecondRetransmissions => 'tcpErrSecondRetransmissions', # Counter64
  tcpErrSentRst => 'tcpErrSentRst', # Counter64
  tcpErrSeventhRetransmissions => 'tcpErrSeventhRetransmissions', # Counter64
  tcpErrSixthRetransmissions => 'tcpErrSixthRetransmissions', # Counter64
  tcpErrStrayPkt => 'tcpErrStrayPkt', # Counter64
  tcpErrSvrHole => 'tcpErrSvrHole', # Counter64
  tcpErrSvrOutOfOrder => 'tcpErrSvrOutOfOrder', # Counter64
  tcpErrSvrRetrasmit => 'tcpErrSvrRetrasmit', # Counter64
  tcpErrSynDroppedCongestion => 'tcpErrSynDroppedCongestion', # Counter64
  tcpErrSynGiveUp => 'tcpErrSynGiveUp', # Counter64
  tcpErrSynInEst => 'tcpErrSynInEst', # Counter64
  tcpErrSynInSynRcvd => 'tcpErrSynInSynRcvd', # Counter64
  tcpErrSynRetry => 'tcpErrSynRetry', # Counter64
  tcpErrSynSentBadAck => 'tcpErrSynSentBadAck', # Counter64
  tcpErrThirdRetransmissions => 'tcpErrThirdRetransmissions', # Counter64
  tcpReuseHit => 'tcpReuseHit', # Gauge32
  tcpSpareConn => 'tcpSpareConn', # Gauge32
  tcpSurgeQueueLen => 'tcpSurgeQueueLen', # Gauge32
  tcpTotClientConnClosed => 'tcpTotClientConnClosed', # Counter64
  tcpTotClientConnOpenRate => 'tcpTotClientConnOpenRate', # OCTET STRING
  tcpTotClientConnOpened => 'tcpTotClientConnOpened', # Counter64
  tcpTotCltFin => 'tcpTotCltFin', # Counter64
  tcpTotFinWaitClosed => 'tcpTotFinWaitClosed', # Counter64
  tcpTotRxBytes => 'tcpTotRxBytes', # Counter64
  tcpTotRxPkts => 'tcpTotRxPkts', # Counter64
  tcpTotServerConnClosed => 'tcpTotServerConnClosed', # Counter64
  tcpTotServerConnOpened => 'tcpTotServerConnOpened', # Counter64
  tcpTotSvrFin => 'tcpTotSvrFin', # Counter64
  tcpTotSyn => 'tcpTotSyn', # Counter64
  tcpTotSynFlush => 'tcpTotSynFlush', # Counter64
  tcpTotSynHeld => 'tcpTotSynHeld', # Counter64
  tcpTotSynProbe => 'tcpTotSynProbe', # Counter64
  tcpTotTxBytes => 'tcpTotTxBytes', # Counter64
  tcpTotTxPkts => 'tcpTotTxPkts', # Counter64
  tcpTotZombieActiveHalfCloseCltConnFlushed => 'tcpTotZombieActiveHalfCloseCltConnFlushed', # Counter64
  tcpTotZombieActiveHalfCloseSvrConnFlushed => 'tcpTotZombieActiveHalfCloseSvrConnFlushed', # Counter64
  tcpTotZombieCltConnFlushed => 'tcpTotZombieCltConnFlushed', # Counter64
  tcpTotZombieHalfOpenCltConnFlushed => 'tcpTotZombieHalfOpenCltConnFlushed', # Counter64
  tcpTotZombieHalfOpenSvrConnFlushed => 'tcpTotZombieHalfOpenSvrConnFlushed', # Counter64
  tcpTotZombiePassiveHalfCloseCltConnFlushed => 'tcpTotZombiePassiveHalfCloseCltConnFlushed', # Counter64
  tcpTotZombiePassiveHalfCloseSrvConnFlushed => 'tcpTotZombiePassiveHalfCloseSrvConnFlushed', # Counter64
  tcpTotZombieSvrConnFlushed => 'tcpTotZombieSvrConnFlushed', # Counter64
  tcpWaitToData => 'tcpWaitToData', # Counter64
  tcpWaitToSyn => 'tcpWaitToSyn', # Counter64

  # nsHttpStatsGroup
  httpErrIncompleteHeaders => 'httpErrIncompleteHeaders', # Counter64
  httpErrIncompleteRequests => 'httpErrIncompleteRequests', # Counter64
  httpErrIncompleteResponses => 'httpErrIncompleteResponses', # Counter64
  httpErrLargeChunk => 'httpErrLargeChunk', # Counter64
  httpErrLargeContent => 'httpErrLargeContent', # Counter64
  httpErrLargeCtlen => 'httpErrLargeCtlen', # Counter64
  httpErrNoreuseMultipart => 'httpErrNoreuseMultipart', # Counter64
  httpErrServerBusy => 'httpErrServerBusy', # Counter64
  httpTot10Requests => 'httpTot10Requests', # Counter64
  httpTot10Responses => 'httpTot10Responses', # Counter64
  httpTot11Requests => 'httpTot11Requests', # Counter64
  httpTot11Responses => 'httpTot11Responses', # Counter64
  httpTotChunkedRequests => 'httpTotChunkedRequests', # Counter64
  httpTotChunkedResponses => 'httpTotChunkedResponses', # Counter64
  httpTotClenRequests => 'httpTotClenRequests', # Counter64
  httpTotClenResponses => 'httpTotClenResponses', # Counter64
  httpTotGets => 'httpTotGets', # Counter64
  httpTotNoClenChunkResponses => 'httpTotNoClenChunkResponses', # Counter64
  httpTotOthers => 'httpTotOthers', # Counter64
  httpTotPosts => 'httpTotPosts', # Counter64
  httpTotRequests => 'httpTotRequests', # Counter64
  httpTotResponses => 'httpTotResponses', # Counter64
  httpTotRxRequestBytes => 'httpTotRxRequestBytes', # Counter64
  httpTotRxResponseBytes => 'httpTotRxResponseBytes', # Counter64
  httpTotTxRequestBytes => 'httpTotTxRequestBytes', # Counter64
  httpTotTxResponseBytes => 'httpTotTxResponseBytes', # Counter64

  # nsCacheStatsGroup
  cache64MaxMemoryKB => 'cache64MaxMemoryKB', # Counter64
  cacheBytesServed => 'cacheBytesServed', # Counter64
  cacheCompressedBytesServed => 'cacheCompressedBytesServed', # Counter64
  cacheCurHits => 'cacheCurHits', # Gauge32
  cacheCurMisses => 'cacheCurMisses', # Gauge32
  cacheErrMemAlloc => 'cacheErrMemAlloc', # Counter64
  cacheLargestResponseReceived => 'cacheLargestResponseReceived', # Counter32
  cacheMaxMemoryActiveKB => 'cacheMaxMemoryActiveKB', # Counter64
  cacheMaxMemoryKB => 'cacheMaxMemoryKB', # Counter64
  cacheNumCached => 'cacheNumCached', # Counter32
  cacheNumMarker => 'cacheNumMarker', # Counter32
  cachePercent304Hits => 'cachePercent304Hits', # Counter32
  cachePercentByteHit => 'cachePercentByteHit', # Counter32
  cachePercentHit => 'cachePercentHit', # Counter32
  cachePercentOriginBandwidthSaved => 'cachePercentOriginBandwidthSaved', # Counter32
  cachePercentParameterized304Hits => 'cachePercentParameterized304Hits', # Counter32
  cachePercentPetHits => 'cachePercentPetHits', # Counter32
  cachePercentStoreAbleMiss => 'cachePercentStoreAbleMiss', # Counter32
  cachePercentSuccessfulRevalidation => 'cachePercentSuccessfulRevalidation', # Counter32
  cacheRecentPercent304Hits => 'cacheRecentPercent304Hits', # Counter32
  cacheRecentPercentByteHit => 'cacheRecentPercentByteHit', # Counter32
  cacheRecentPercentHit => 'cacheRecentPercentHit', # Counter32
  cacheRecentPercentOriginBandwidthSaved => 'cacheRecentPercentOriginBandwidthSaved', # Counter32
  cacheRecentPercentParameterizedHits => 'cacheRecentPercentParameterizedHits', # Counter32
  cacheRecentPercentStoreAbleMiss => 'cacheRecentPercentStoreAbleMiss', # Counter32
  cacheRecentPercentSuccessfulRevalidation => 'cacheRecentPercentSuccessfulRevalidation', # Counter32
  cacheTot304Hits => 'cacheTot304Hits', # Counter64
  cacheTotExpireAtLastByte => 'cacheTotExpireAtLastByte', # Counter64
  cacheTotFlashcacheHits => 'cacheTotFlashcacheHits', # Counter64
  cacheTotFlashcacheMisses => 'cacheTotFlashcacheMisses', # Counter64
  cacheTotFullToConditionalRequest => 'cacheTotFullToConditionalRequest', # Counter64
  cacheTotHits => 'cacheTotHits', # Counter64
  cacheTotInvalidationRequests => 'cacheTotInvalidationRequests', # Counter64
  cacheTotMisses => 'cacheTotMisses', # Counter64
  cacheTotNon304Hits => 'cacheTotNon304Hits', # Counter64
  cacheTotNonParameterizedInvalidationRequests => 'cacheTotNonParameterizedInvalidationRequests', # Counter64
  cacheTotNonStoreAbleMisses => 'cacheTotNonStoreAbleMisses', # Counter64
  cacheTotParameterized304Hits => 'cacheTotParameterized304Hits', # Counter64
  cacheTotParameterizedHits => 'cacheTotParameterizedHits', # Counter64
  cacheTotParameterizedInvalidationRequests => 'cacheTotParameterizedInvalidationRequests', # Counter64
  cacheTotParameterizedNon304Hits => 'cacheTotParameterizedNon304Hits', # Counter64
  cacheTotParameterizedRequests => 'cacheTotParameterizedRequests', # Counter64
  cacheTotPetHits => 'cacheTotPetHits', # Counter64
  cacheTotPetRequests => 'cacheTotPetRequests', # Counter64
  cacheTotRequests => 'cacheTotRequests', # Counter64
  cacheTotResponseBytes => 'cacheTotResponseBytes', # Counter64
  cacheTotRevalidationMiss => 'cacheTotRevalidationMiss', # Counter64
  cacheTotStoreAbleMisses => 'cacheTotStoreAbleMisses', # Counter64
  cacheTotSuccessfulRevalidation => 'cacheTotSuccessfulRevalidation', # Counter64
  cacheUtilizedMemoryKB => 'cacheUtilizedMemoryKB', # Counter32

  # nsCompressionStatsGroup
  compHttpBandwidthSaving => 'compHttpBandwidthSaving', # Integer32
  compRatio => 'compRatio', # Gauge32
  compTcpBandwidthSaving => 'compTcpBandwidthSaving', # Integer32
  compTcpRatio => 'compTcpRatio', # Gauge32
  compTcpTotalEoi => 'compTcpTotalEoi', # Counter64
  compTcpTotalPush => 'compTcpTotalPush', # Counter64
  compTcpTotalQuantum => 'compTcpTotalQuantum', # Counter64
  compTcpTotalRxBytes => 'compTcpTotalRxBytes', # Counter64
  compTcpTotalRxPackets => 'compTcpTotalRxPackets', # Counter64
  compTcpTotalTimer => 'compTcpTotalTimer', # Counter64
  compTcpTotalTxBytes => 'compTcpTotalTxBytes', # Counter64
  compTcpTotalTxPackets => 'compTcpTotalTxPackets', # Counter64
  compTotalDataCompressionRatio => 'compTotalDataCompressionRatio', # Gauge32
  compTotalRequests => 'compTotalRequests', # Counter64
  compTotalRxBytes => 'compTotalRxBytes', # Counter64
  compTotalRxPackets => 'compTotalRxPackets', # Counter64
  compTotalTxBytes => 'compTotalTxBytes', # Counter64
  compTotalTxPackets => 'compTotalTxPackets', # Counter64
  deCompTcpBandwidthSaving => 'deCompTcpBandwidthSaving', # Integer32
  deCompTcpErrData => 'deCompTcpErrData', # Counter64
  deCompTcpErrLessData => 'deCompTcpErrLessData', # Counter64
  deCompTcpErrMemory => 'deCompTcpErrMemory', # Counter64
  deCompTcpErrMoreData => 'deCompTcpErrMoreData', # Counter64
  deCompTcpErrUnknown => 'deCompTcpErrUnknown', # Counter64
  deCompTcpRatio => 'deCompTcpRatio', # Gauge32
  deCompTcpRxBytes => 'deCompTcpRxBytes', # Counter64
  deCompTcpRxPackets => 'deCompTcpRxPackets', # Counter64
  deCompTcpTxBytes => 'deCompTcpTxBytes', # Counter64
  deCompTcpTxPackets => 'deCompTcpTxPackets', # Counter64
  delBwSaving => 'delBwSaving', # Integer32
  delCmpRatio => 'delCmpRatio', # Gauge32
  delCompBaseServed => 'delCompBaseServed', # Counter64
  delCompBaseTcpTxBytes => 'delCompBaseTcpTxBytes', # Counter64
  delCompDone => 'delCompDone', # Counter64
  delCompErrBFileWHdrFailed => 'delCompErrBFileWHdrFailed', # Counter64
  delCompErrBypassed => 'delCompErrBypassed', # Counter64
  delCompErrNostoreMiss => 'delCompErrNostoreMiss', # Counter64
  delCompErrReqinfoAllocfail => 'delCompErrReqinfoAllocfail', # Counter64
  delCompErrReqinfoToobig => 'delCompErrReqinfoToobig', # Counter64
  delCompErrSessallocFail => 'delCompErrSessallocFail', # Counter64
  delCompFirstAccess => 'delCompFirstAccess', # Counter64
  delCompTcpRxBytes => 'delCompTcpRxBytes', # Counter64
  delCompTcpRxPackets => 'delCompTcpRxPackets', # Counter64
  delCompTcpTxBytes => 'delCompTcpTxBytes', # Counter64
  delCompTcpTxPackets => 'delCompTcpTxPackets', # Counter64
  delCompTotalRequests => 'delCompTotalRequests', # Counter64

  # serviceGlobalStatsGroup
  serverCount => 'serverCount', # Integer32
  svcCount => 'svcCount', # Integer32
  svcgroupCount => 'svcgroupCount', # Integer32
  svcgroupmemCount => 'svcgroupmemCount', # Integer32

);

%MUNGE = (
  'destinationInetAddress' => \&SNMP::Info::munge_ip,
  'vsvrIp6Address' => \&SNMP::Info::munge_ip,
  'svcInetAddress' => \&SNMP::Info::munge_ip,
  'serverInetAddress' => \&SNMP::Info::munge_ip,
);

sub ns_resource_stats {
  my $self = shift;
  my $stats = {};

  $stats->{cpuSpeedMHz} = $self->cpuSpeedMHz; # Integer32
  $stats->{memSizeMB} = $self->memSizeMB; # Integer32
  $stats->{numCPUs} = $self->numCPUs; # Integer32
  $stats->{numPEs} = $self->numPEs; # Integer32
  $stats->{numSSLCards} = $self->numSSLCards; # Integer32
  $stats->{resCpuUsage} = $self->resCpuUsage; # Gauge32
  $stats->{resMemUsage} = $self->resMemUsage; # Gauge32

  return $stats;
}

sub ns_ip_stats {
  my $self = shift;
  my $stats = {};

  $stats->{ipTotAddrLookup} = $self->ipTotAddrLookup; # Counter64
  $stats->{ipTotAddrLookupFail} = $self->ipTotAddrLookupFail; # Counter64
  $stats->{ipTotBadChecksums} = $self->ipTotBadChecksums; # Counter64
  $stats->{ipTotBadMacAddrs} = $self->ipTotBadMacAddrs; # Counter64
  $stats->{ipTotBadTransport} = $self->ipTotBadTransport; # Counter64
  $stats->{ipTotBadlens} = $self->ipTotBadlens; # Counter64
  $stats->{ipTotDupFragments} = $self->ipTotDupFragments; # Counter64
  $stats->{ipTotFixHeaderFail} = $self->ipTotFixHeaderFail; # Counter64
  $stats->{ipTotFragPktsGen} = $self->ipTotFragPktsGen; # Counter64
  $stats->{ipTotFragments} = $self->ipTotFragments; # Counter64
  $stats->{ipTotInvalidHeaderSz} = $self->ipTotInvalidHeaderSz; # Counter64
  $stats->{ipTotInvalidPacketSize} = $self->ipTotInvalidPacketSize; # Counter64
  $stats->{ipTotLandattacks} = $self->ipTotLandattacks; # Counter64
  $stats->{ipTotMaxClients} = $self->ipTotMaxClients; # Counter64
  $stats->{ipTotOutOfOrderFrag} = $self->ipTotOutOfOrderFrag; # Counter64
  $stats->{ipTotReassemblyAttempt} = $self->ipTotReassemblyAttempt; # Counter64
  $stats->{ipTotRxBytes} = $self->ipTotRxBytes; # Counter64
  $stats->{ipTotRxMbits} = $self->ipTotRxMbits; # Counter64
  $stats->{ipTotRxPkts} = $self->ipTotRxPkts; # Counter64
  $stats->{ipTotSuccReassembly} = $self->ipTotSuccReassembly; # Counter64
  $stats->{ipTotTCPfragmentsFwd} = $self->ipTotTCPfragmentsFwd; # Counter64
  $stats->{ipTotTooBig} = $self->ipTotTooBig; # Counter64
  $stats->{ipTotTruncatedPackets} = $self->ipTotTruncatedPackets; # Counter64
  $stats->{ipTotTtlExpired} = $self->ipTotTtlExpired; # Counter64
  $stats->{ipTotTxBytes} = $self->ipTotTxBytes; # Counter64
  $stats->{ipTotTxMbits} = $self->ipTotTxMbits; # Counter64
  $stats->{ipTotTxPkts} = $self->ipTotTxPkts; # Counter64
  $stats->{ipTotUDPfragmentsFwd} = $self->ipTotUDPfragmentsFwd; # Counter64
  $stats->{ipTotUnknownDstRcvd} = $self->ipTotUnknownDstRcvd; # Counter64
  $stats->{ipTotUnknownSvcs} = $self->ipTotUnknownSvcs; # Counter64
  $stats->{ipTotUnsuccReassembly} = $self->ipTotUnsuccReassembly; # Counter64
  $stats->{ipTotVIPDown} = $self->ipTotVIPDown; # Counter64
  $stats->{ipTotZeroFragmentLen} = $self->ipTotZeroFragmentLen; # Counter64
  $stats->{ipTotZeroNextHop} = $self->ipTotZeroNextHop; # Counter64
  $stats->{nonIpTotTruncatedPackets} = $self->nonIpTotTruncatedPackets; # Counter64

  return $stats;
}

sub ns_icmp_stats {
  my $self = shift;
  my $stats = {};

  $stats->{icmpCurRateThreshold} = $self->icmpCurRateThreshold; # Integer32
  $stats->{icmpTotBadChecksum} = $self->icmpTotBadChecksum; # Counter64
  $stats->{icmpTotBadPMTUIpChecksum} = $self->icmpTotBadPMTUIpChecksum; # Counter64
  $stats->{icmpTotBigNextMTU} = $self->icmpTotBigNextMTU; # Counter64
  $stats->{icmpTotDstIpLookup} = $self->icmpTotDstIpLookup; # Counter64
  $stats->{icmpTotInvalidBodyLen} = $self->icmpTotInvalidBodyLen; # Counter64
  $stats->{icmpTotInvalidNextMTUval} = $self->icmpTotInvalidNextMTUval; # Counter64
  $stats->{icmpTotInvalidProtocol} = $self->icmpTotInvalidProtocol; # Counter64
  $stats->{icmpTotInvalidTcpSeqno} = $self->icmpTotInvalidTcpSeqno; # Counter64
  $stats->{icmpTotNeedFragRx} = $self->icmpTotNeedFragRx; # Counter64
  $stats->{icmpTotNoTcpConn} = $self->icmpTotNoTcpConn; # Counter64
  $stats->{icmpTotNoUdpConn} = $self->icmpTotNoUdpConn; # Counter64
  $stats->{icmpTotNonFirstIpFrag} = $self->icmpTotNonFirstIpFrag; # Counter64
  $stats->{icmpTotPMTUDiscoveryDisabled} = $self->icmpTotPMTUDiscoveryDisabled; # Counter64
  $stats->{icmpTotPMTUnoLink} = $self->icmpTotPMTUnoLink; # Counter64
  $stats->{icmpTotPktsDropped} = $self->icmpTotPktsDropped; # Counter64
  $stats->{icmpTotPortUnreachableRx} = $self->icmpTotPortUnreachableRx; # Counter64
  $stats->{icmpTotPortUnreachableTx} = $self->icmpTotPortUnreachableTx; # Counter64
  $stats->{icmpTotRxBytes} = $self->icmpTotRxBytes; # Counter64
  $stats->{icmpTotRxEcho} = $self->icmpTotRxEcho; # Counter64
  $stats->{icmpTotRxEchoReply} = $self->icmpTotRxEchoReply; # Counter64
  $stats->{icmpTotRxPkts} = $self->icmpTotRxPkts; # Counter64
  $stats->{icmpTotThresholdExceeds} = $self->icmpTotThresholdExceeds; # Counter64
  $stats->{icmpTotTxBytes} = $self->icmpTotTxBytes; # Counter64
  $stats->{icmpTotTxEchoReply} = $self->icmpTotTxEchoReply; # Counter64
  $stats->{icmpTotTxPkts} = $self->icmpTotTxPkts; # Counter64

  return $stats;
}

sub ns_udp_stats {
  my $self = shift;
  my $stats = {};

  $stats->{udpBadChecksum} = $self->udpBadChecksum; # Counter64
  $stats->{udpCurRateThreshold} = $self->udpCurRateThreshold; # Counter32
  $stats->{udpCurRateThresholdExceeds} = $self->udpCurRateThresholdExceeds; # Counter64
  $stats->{udpTotRxBytes} = $self->udpTotRxBytes; # Counter64
  $stats->{udpTotRxPkts} = $self->udpTotRxPkts; # Counter64
  $stats->{udpTotTxBytes} = $self->udpTotTxBytes; # Counter64
  $stats->{udpTotTxPkts} = $self->udpTotTxPkts; # Counter64
  $stats->{udpTotUnknownSvcPkts} = $self->udpTotUnknownSvcPkts; # Counter64

  return $stats;
}
sub ns_tcp_stats {
  my $self = shift;
  my $stats = {};

  $stats->{pcbTotZombieCall} = $self->pcbTotZombieCall; # Counter64
  $stats->{tcpActiveServerConn} = $self->tcpActiveServerConn; # Gauge32
  $stats->{tcpCurClientConn} = $self->tcpCurClientConn; # Gauge32
  $stats->{tcpCurClientConnClosing} = $self->tcpCurClientConnClosing; # Gauge32
  $stats->{tcpCurClientConnEstablished} = $self->tcpCurClientConnEstablished; # Gauge32
  $stats->{tcpCurClientConnOpening} = $self->tcpCurClientConnOpening; # Gauge32
  $stats->{tcpCurPhysicalServers} = $self->tcpCurPhysicalServers; # Gauge32
  $stats->{tcpCurServerConn} = $self->tcpCurServerConn; # Gauge32
  $stats->{tcpCurServerConnClosing} = $self->tcpCurServerConnClosing; # Gauge32
  $stats->{tcpCurServerConnEstablished} = $self->tcpCurServerConnEstablished; # Gauge32
  $stats->{tcpCurServerConnOpening} = $self->tcpCurServerConnOpening; # Gauge32
  $stats->{tcpErrAnyPortFail} = $self->tcpErrAnyPortFail; # Counter64
  $stats->{tcpErrBadCheckSum} = $self->tcpErrBadCheckSum; # Counter64
  $stats->{tcpErrBadStateConn} = $self->tcpErrBadStateConn; # Counter64
  $stats->{tcpErrCltHole} = $self->tcpErrCltHole; # Counter64
  $stats->{tcpErrCltOutOfOrder} = $self->tcpErrCltOutOfOrder; # Counter64
  $stats->{tcpErrCltRetrasmit} = $self->tcpErrCltRetrasmit; # Counter64
  $stats->{tcpErrCookiePktMssReject} = $self->tcpErrCookiePktMssReject; # Counter64
  $stats->{tcpErrCookiePktSeqDrop} = $self->tcpErrCookiePktSeqDrop; # Counter64
  $stats->{tcpErrCookiePktSeqReject} = $self->tcpErrCookiePktSeqReject; # Counter64
  $stats->{tcpErrCookiePktSigReject} = $self->tcpErrCookiePktSigReject; # Counter64
  $stats->{tcpErrDataAfterFin} = $self->tcpErrDataAfterFin; # Counter64
  $stats->{tcpErrFastRetransmissions} = $self->tcpErrFastRetransmissions; # Counter64
  $stats->{tcpErrFifthRetransmissions} = $self->tcpErrFifthRetransmissions; # Counter64
  $stats->{tcpErrFinDup} = $self->tcpErrFinDup; # Counter64
  $stats->{tcpErrFinGiveUp} = $self->tcpErrFinGiveUp; # Counter64
  $stats->{tcpErrFinRetry} = $self->tcpErrFinRetry; # Counter64
  $stats->{tcpErrFirstRetransmissions} = $self->tcpErrFirstRetransmissions; # Counter64
  $stats->{tcpErrForthRetransmissions} = $self->tcpErrForthRetransmissions; # Counter64
  $stats->{tcpErrFullRetrasmit} = $self->tcpErrFullRetrasmit; # Counter64
  $stats->{tcpErrIpPortFail} = $self->tcpErrIpPortFail; # Counter64
  $stats->{tcpErrOutOfWindowPkts} = $self->tcpErrOutOfWindowPkts; # Counter64
  $stats->{tcpErrPartialRetrasmit} = $self->tcpErrPartialRetrasmit; # Counter64
  $stats->{tcpErrRetransmit} = $self->tcpErrRetransmit; # Counter64
  $stats->{tcpErrRetransmitGiveUp} = $self->tcpErrRetransmitGiveUp; # Counter64
  $stats->{tcpErrRst} = $self->tcpErrRst; # Counter64
  $stats->{tcpErrRstInTimewait} = $self->tcpErrRstInTimewait; # Counter64
  $stats->{tcpErrRstNonEst} = $self->tcpErrRstNonEst; # Counter64
  $stats->{tcpErrRstOutOfWindow} = $self->tcpErrRstOutOfWindow; # Counter64
  $stats->{tcpErrRstThreshold} = $self->tcpErrRstThreshold; # Counter64
  $stats->{tcpErrSecondRetransmissions} = $self->tcpErrSecondRetransmissions; # Counter64
  $stats->{tcpErrSentRst} = $self->tcpErrSentRst; # Counter64
  $stats->{tcpErrSeventhRetransmissions} = $self->tcpErrSeventhRetransmissions; # Counter64
  $stats->{tcpErrSixthRetransmissions} = $self->tcpErrSixthRetransmissions; # Counter64
  $stats->{tcpErrStrayPkt} = $self->tcpErrStrayPkt; # Counter64
  $stats->{tcpErrSvrHole} = $self->tcpErrSvrHole; # Counter64
  $stats->{tcpErrSvrOutOfOrder} = $self->tcpErrSvrOutOfOrder; # Counter64
  $stats->{tcpErrSvrRetrasmit} = $self->tcpErrSvrRetrasmit; # Counter64
  $stats->{tcpErrSynDroppedCongestion} = $self->tcpErrSynDroppedCongestion; # Counter64
  $stats->{tcpErrSynGiveUp} = $self->tcpErrSynGiveUp; # Counter64
  $stats->{tcpErrSynInEst} = $self->tcpErrSynInEst; # Counter64
  $stats->{tcpErrSynInSynRcvd} = $self->tcpErrSynInSynRcvd; # Counter64
  $stats->{tcpErrSynRetry} = $self->tcpErrSynRetry; # Counter64
  $stats->{tcpErrSynSentBadAck} = $self->tcpErrSynSentBadAck; # Counter64
  $stats->{tcpErrThirdRetransmissions} = $self->tcpErrThirdRetransmissions; # Counter64
  $stats->{tcpReuseHit} = $self->tcpReuseHit; # Gauge32
  $stats->{tcpSpareConn} = $self->tcpSpareConn; # Gauge32
  $stats->{tcpSurgeQueueLen} = $self->tcpSurgeQueueLen; # Gauge32
  $stats->{tcpTotClientConnClosed} = $self->tcpTotClientConnClosed; # Counter64
  $stats->{tcpTotClientConnOpenRate} = $self->tcpTotClientConnOpenRate; # OCTET STRING
  $stats->{tcpTotClientConnOpened} = $self->tcpTotClientConnOpened; # Counter64
  $stats->{tcpTotCltFin} = $self->tcpTotCltFin; # Counter64
  $stats->{tcpTotFinWaitClosed} = $self->tcpTotFinWaitClosed; # Counter64
  $stats->{tcpTotRxBytes} = $self->tcpTotRxBytes; # Counter64
  $stats->{tcpTotRxPkts} = $self->tcpTotRxPkts; # Counter64
  $stats->{tcpTotServerConnClosed} = $self->tcpTotServerConnClosed; # Counter64
  $stats->{tcpTotServerConnOpened} = $self->tcpTotServerConnOpened; # Counter64
  $stats->{tcpTotSvrFin} = $self->tcpTotSvrFin; # Counter64
  $stats->{tcpTotSyn} = $self->tcpTotSyn; # Counter64
  $stats->{tcpTotSynFlush} = $self->tcpTotSynFlush; # Counter64
  $stats->{tcpTotSynHeld} = $self->tcpTotSynHeld; # Counter64
  $stats->{tcpTotSynProbe} = $self->tcpTotSynProbe; # Counter64
  $stats->{tcpTotTxBytes} = $self->tcpTotTxBytes; # Counter64
  $stats->{tcpTotTxPkts} = $self->tcpTotTxPkts; # Counter64
  $stats->{tcpTotZombieActiveHalfCloseCltConnFlushed} = $self->tcpTotZombieActiveHalfCloseCltConnFlushed; # Counter64
  $stats->{tcpTotZombieActiveHalfCloseSvrConnFlushed} = $self->tcpTotZombieActiveHalfCloseSvrConnFlushed; # Counter64
  $stats->{tcpTotZombieCltConnFlushed} = $self->tcpTotZombieCltConnFlushed; # Counter64
  $stats->{tcpTotZombieHalfOpenCltConnFlushed} = $self->tcpTotZombieHalfOpenCltConnFlushed; # Counter64
  $stats->{tcpTotZombieHalfOpenSvrConnFlushed} = $self->tcpTotZombieHalfOpenSvrConnFlushed; # Counter64
  $stats->{tcpTotZombiePassiveHalfCloseCltConnFlushed} = $self->tcpTotZombiePassiveHalfCloseCltConnFlushed; # Counter64
  $stats->{tcpTotZombiePassiveHalfCloseSrvConnFlushed} = $self->tcpTotZombiePassiveHalfCloseSrvConnFlushed; # Counter64
  $stats->{tcpTotZombieSvrConnFlushed} = $self->tcpTotZombieSvrConnFlushed; # Counter64
  $stats->{tcpWaitToData} = $self->tcpWaitToData; # Counter64
  $stats->{tcpWaitToSyn} = $self->tcpWaitToSyn; # Counter64

  return $stats;
}

sub ns_http_stats {
  my $self = shift;
  my $stats = {};

  $stats->{httpErrIncompleteHeaders} = $self->httpErrIncompleteHeaders; # Counter64
  $stats->{httpErrIncompleteRequests} = $self->httpErrIncompleteRequests; # Counter64
  $stats->{httpErrIncompleteResponses} = $self->httpErrIncompleteResponses; # Counter64
  $stats->{httpErrLargeChunk} = $self->httpErrLargeChunk; # Counter64
  $stats->{httpErrLargeContent} = $self->httpErrLargeContent; # Counter64
  $stats->{httpErrLargeCtlen} = $self->httpErrLargeCtlen; # Counter64
  $stats->{httpErrNoreuseMultipart} = $self->httpErrNoreuseMultipart; # Counter64
  $stats->{httpErrServerBusy} = $self->httpErrServerBusy; # Counter64
  $stats->{httpTot10Requests} = $self->httpTot10Requests; # Counter64
  $stats->{httpTot10Responses} = $self->httpTot10Responses; # Counter64
  $stats->{httpTot11Requests} = $self->httpTot11Requests; # Counter64
  $stats->{httpTot11Responses} = $self->httpTot11Responses; # Counter64
  $stats->{httpTotChunkedRequests} = $self->httpTotChunkedRequests; # Counter64
  $stats->{httpTotChunkedResponses} = $self->httpTotChunkedResponses; # Counter64
  $stats->{httpTotClenRequests} = $self->httpTotClenRequests; # Counter64
  $stats->{httpTotClenResponses} = $self->httpTotClenResponses; # Counter64
  $stats->{httpTotGets} = $self->httpTotGets; # Counter64
  $stats->{httpTotNoClenChunkResponses} = $self->httpTotNoClenChunkResponses; # Counter64
  $stats->{httpTotOthers} = $self->httpTotOthers; # Counter64
  $stats->{httpTotPosts} = $self->httpTotPosts; # Counter64
  $stats->{httpTotRequests} = $self->httpTotRequests; # Counter64
  $stats->{httpTotResponses} = $self->httpTotResponses; # Counter64
  $stats->{httpTotRxRequestBytes} = $self->httpTotRxRequestBytes; # Counter64
  $stats->{httpTotRxResponseBytes} = $self->httpTotRxResponseBytes; # Counter64
  $stats->{httpTotTxRequestBytes} = $self->httpTotTxRequestBytes; # Counter64
  $stats->{httpTotTxResponseBytes} = $self->httpTotTxResponseBytes; # Counter64

  return $stats;
}

sub ns_cache_stats {
  my $self = shift;
  my $stats = {};
  $stats->{cache64MaxMemoryKB} = $self->cache64MaxMemoryKB; # Counter64
  $stats->{cacheBytesServed} = $self->cacheBytesServed; # Counter64
  $stats->{cacheCompressedBytesServed} = $self->cacheCompressedBytesServed; # Counter64
  $stats->{cacheCurHits} = $self->cacheCurHits; # Gauge32
  $stats->{cacheCurMisses} = $self->cacheCurMisses; # Gauge32
  $stats->{cacheErrMemAlloc} = $self->cacheErrMemAlloc; # Counter64
  $stats->{cacheLargestResponseReceived} = $self->cacheLargestResponseReceived; # Counter32
  $stats->{cacheMaxMemoryActiveKB} = $self->cacheMaxMemoryActiveKB; # Counter64
  $stats->{cacheMaxMemoryKB} = $self->cacheMaxMemoryKB; # Counter64
  $stats->{cacheNumCached} = $self->cacheNumCached; # Counter32
  $stats->{cacheNumMarker} = $self->cacheNumMarker; # Counter32
  $stats->{cachePercent304Hits} = $self->cachePercent304Hits; # Counter32
  $stats->{cachePercentByteHit} = $self->cachePercentByteHit; # Counter32
  $stats->{cachePercentHit} = $self->cachePercentHit; # Counter32
  $stats->{cachePercentOriginBandwidthSaved} = $self->cachePercentOriginBandwidthSaved; # Counter32
  $stats->{cachePercentParameterized304Hits} = $self->cachePercentParameterized304Hits; # Counter32
  $stats->{cachePercentPetHits} = $self->cachePercentPetHits; # Counter32
  $stats->{cachePercentStoreAbleMiss} = $self->cachePercentStoreAbleMiss; # Counter32
  $stats->{cachePercentSuccessfulRevalidation} = $self->cachePercentSuccessfulRevalidation; # Counter32
  $stats->{cacheRecentPercent304Hits} = $self->cacheRecentPercent304Hits; # Counter32
  $stats->{cacheRecentPercentByteHit} = $self->cacheRecentPercentByteHit; # Counter32
  $stats->{cacheRecentPercentHit} = $self->cacheRecentPercentHit; # Counter32
  $stats->{cacheRecentPercentOriginBandwidthSaved} = $self->cacheRecentPercentOriginBandwidthSaved; # Counter32
  $stats->{cacheRecentPercentParameterizedHits} = $self->cacheRecentPercentParameterizedHits; # Counter32
  $stats->{cacheRecentPercentStoreAbleMiss} = $self->cacheRecentPercentStoreAbleMiss; # Counter32
  $stats->{cacheRecentPercentSuccessfulRevalidation} = $self->cacheRecentPercentSuccessfulRevalidation; # Counter32
  $stats->{cacheTot304Hits} = $self->cacheTot304Hits; # Counter64
  $stats->{cacheTotExpireAtLastByte} = $self->cacheTotExpireAtLastByte; # Counter64
  $stats->{cacheTotFlashcacheHits} = $self->cacheTotFlashcacheHits; # Counter64
  $stats->{cacheTotFlashcacheMisses} = $self->cacheTotFlashcacheMisses; # Counter64
  $stats->{cacheTotFullToConditionalRequest} = $self->cacheTotFullToConditionalRequest; # Counter64
  $stats->{cacheTotHits} = $self->cacheTotHits; # Counter64
  $stats->{cacheTotInvalidationRequests} = $self->cacheTotInvalidationRequests; # Counter64
  $stats->{cacheTotMisses} = $self->cacheTotMisses; # Counter64
  $stats->{cacheTotNon304Hits} = $self->cacheTotNon304Hits; # Counter64
  $stats->{cacheTotNonParameterizedInvalidationRequests} = $self->cacheTotNonParameterizedInvalidationRequests; # Counter64
  $stats->{cacheTotNonStoreAbleMisses} = $self->cacheTotNonStoreAbleMisses; # Counter64
  $stats->{cacheTotParameterized304Hits} = $self->cacheTotParameterized304Hits; # Counter64
  $stats->{cacheTotParameterizedHits} = $self->cacheTotParameterizedHits; # Counter64
  $stats->{cacheTotParameterizedInvalidationRequests} = $self->cacheTotParameterizedInvalidationRequests; # Counter64
  $stats->{cacheTotParameterizedNon304Hits} = $self->cacheTotParameterizedNon304Hits; # Counter64
  $stats->{cacheTotParameterizedRequests} = $self->cacheTotParameterizedRequests; # Counter64
  $stats->{cacheTotPetHits} = $self->cacheTotPetHits; # Counter64
  $stats->{cacheTotPetRequests} = $self->cacheTotPetRequests; # Counter64
  $stats->{cacheTotRequests} = $self->cacheTotRequests; # Counter64
  $stats->{cacheTotResponseBytes} = $self->cacheTotResponseBytes; # Counter64
  $stats->{cacheTotRevalidationMiss} = $self->cacheTotRevalidationMiss; # Counter64
  $stats->{cacheTotStoreAbleMisses} = $self->cacheTotStoreAbleMisses; # Counter64
  $stats->{cacheTotSuccessfulRevalidation} = $self->cacheTotSuccessfulRevalidation; # Counter64
  $stats->{cacheUtilizedMemoryKB} = $self->cacheUtilizedMemoryKB; # Counter32

  return $stats;
}

sub ns_compression_stats {
  my $self = shift;
  my $stats = {};
  $stats->{compHttpBandwidthSaving} = $self->compHttpBandwidthSaving; # Integer32
  $stats->{compRatio} = $self->compRatio; # Gauge32
  $stats->{compTcpBandwidthSaving} = $self->compTcpBandwidthSaving; # Integer32
  $stats->{compTcpRatio} = $self->compTcpRatio; # Gauge32
  $stats->{compTcpTotalEoi} = $self->compTcpTotalEoi; # Counter64
  $stats->{compTcpTotalPush} = $self->compTcpTotalPush; # Counter64
  $stats->{compTcpTotalQuantum} = $self->compTcpTotalQuantum; # Counter64
  $stats->{compTcpTotalRxBytes} = $self->compTcpTotalRxBytes; # Counter64
  $stats->{compTcpTotalRxPackets} = $self->compTcpTotalRxPackets; # Counter64
  $stats->{compTcpTotalTimer} = $self->compTcpTotalTimer; # Counter64
  $stats->{compTcpTotalTxBytes} = $self->compTcpTotalTxBytes; # Counter64
  $stats->{compTcpTotalTxPackets} = $self->compTcpTotalTxPackets; # Counter64
  $stats->{compTotalDataCompressionRatio} = $self->compTotalDataCompressionRatio; # Gauge32
  $stats->{compTotalRequests} = $self->compTotalRequests; # Counter64
  $stats->{compTotalRxBytes} = $self->compTotalRxBytes; # Counter64
  $stats->{compTotalRxPackets} = $self->compTotalRxPackets; # Counter64
  $stats->{compTotalTxBytes} = $self->compTotalTxBytes; # Counter64
  $stats->{compTotalTxPackets} = $self->compTotalTxPackets; # Counter64
  $stats->{deCompTcpBandwidthSaving} = $self->deCompTcpBandwidthSaving; # Integer32
  $stats->{deCompTcpErrData} = $self->deCompTcpErrData; # Counter64
  $stats->{deCompTcpErrLessData} = $self->deCompTcpErrLessData; # Counter64
  $stats->{deCompTcpErrMemory} = $self->deCompTcpErrMemory; # Counter64
  $stats->{deCompTcpErrMoreData} = $self->deCompTcpErrMoreData; # Counter64
  $stats->{deCompTcpErrUnknown} = $self->deCompTcpErrUnknown; # Counter64
  $stats->{deCompTcpRatio} = $self->deCompTcpRatio; # Gauge32
  $stats->{deCompTcpRxBytes} = $self->deCompTcpRxBytes; # Counter64
  $stats->{deCompTcpRxPackets} = $self->deCompTcpRxPackets; # Counter64
  $stats->{deCompTcpTxBytes} = $self->deCompTcpTxBytes; # Counter64
  $stats->{deCompTcpTxPackets} = $self->deCompTcpTxPackets; # Counter64
  $stats->{delBwSaving} = $self->delBwSaving; # Integer32
  $stats->{delCmpRatio} = $self->delCmpRatio; # Gauge32
  $stats->{delCompBaseServed} = $self->delCompBaseServed; # Counter64
  $stats->{delCompBaseTcpTxBytes} = $self->delCompBaseTcpTxBytes; # Counter64
  $stats->{delCompDone} = $self->delCompDone; # Counter64
  $stats->{delCompErrBFileWHdrFailed} = $self->delCompErrBFileWHdrFailed; # Counter64
  $stats->{delCompErrBypassed} = $self->delCompErrBypassed; # Counter64
  $stats->{delCompErrNostoreMiss} = $self->delCompErrNostoreMiss; # Counter64
  $stats->{delCompErrReqinfoAllocfail} = $self->delCompErrReqinfoAllocfail; # Counter64
  $stats->{delCompErrReqinfoToobig} = $self->delCompErrReqinfoToobig; # Counter64
  $stats->{delCompErrSessallocFail} = $self->delCompErrSessallocFail; # Counter64
  $stats->{delCompFirstAccess} = $self->delCompFirstAccess; # Counter64
  $stats->{delCompTcpRxBytes} = $self->delCompTcpRxBytes; # Counter64
  $stats->{delCompTcpRxPackets} = $self->delCompTcpRxPackets; # Counter64
  $stats->{delCompTcpTxBytes} = $self->delCompTcpTxBytes; # Counter64
  $stats->{delCompTcpTxPackets} = $self->delCompTcpTxPackets; # Counter64
  $stats->{delCompTotalRequests} = $self->delCompTotalRequests; # Counter64

  return $stats;
}

sub ns_svc_global_stats {
  my $self = shift;
  my $stats = {};
  $stats->{serverCount} = $self->serverCount; # Integer32
  $stats->{svcCount} = $self->svcCount; # Integer32
  $stats->{svcgroupCount} = $self->svcgroupCount; # Integer32
  $stats->{svcgroupmemCount} = $self->svcgroupmemCount; # Integer32
  return $stats;
}

return 1;

# vim: set ts=2 sw=2 expandtab:

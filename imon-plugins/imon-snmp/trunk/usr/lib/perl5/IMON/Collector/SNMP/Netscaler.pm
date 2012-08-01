#
# $Id: Netscaler.pm 7257 2012-04-19 06:10:04Z shanker.balan $
#

package IMON::Collector::SNMP::Netscaler;

use strict;
use warnings;
use Time::HiRes qw( gettimeofday tv_interval );
use IMON::Utils::POE;

use Data::Dumper;

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
    $self->{info_obj}->{$device} = $self->init_snmp_info('Inmobi::Netscaler', $device);
  }

  printf("Collector init complete with %d valid devices\n", scalar($self->valid_devices()) );
}

sub snmp_get_all {
  my ($self, $device) = @_;

  my $info = $self->{info_obj}->{$device};

  $info->clear_cache();

  if (!defined($info->sysDescr() )) {
    # Uh Oh. Better luck in next run?
    printf("%s: ERROR %s. Please check community string and ACL\n", $device, $info->error() );
    return;
  }

  die "Unable to collect from $device. Object does not exist\n" unless $info;

  my $t0 = [gettimeofday];

  my $all = $info->all();

  my %events = (
    'system'  => $info->ns_resource_stats,        # nsResourceGroup
    'ip'      => $info->ns_ip_stats,              # nsIpStatsGroup
    'icmp'    => $info->ns_icmp_stats,            # nsIcmpStatsGroup
    'udp'     => $info->ns_udp_stats,             # nsUdpStatsGroup
    'tcp'     => $info->ns_tcp_stats,             # nsTcpStatsGroup
    'http'    => $info->ns_http_stats,            # nsHttpStatsGroup
    'cache'   => $info->ns_cache_stats,           # nsCacheStatsGroup
    'compression' => $info->ns_compression_stats, # nsCompressionStatsGroup
    'service' => $info->ns_svc_global_stats,      # serviceGlobalStatsGroup
  );

  foreach my $type (keys %events) {
    my $e = $self->create_event();
    $e->{device}      = $device;
    $e->{event_type}  = $type;
    foreach my $id (keys %{$events{$type}}) {
      $e->{$id} = $events{$type}{$id};
    }
    $self->push_to_transport($e);
  }

  # nsCPUEntry (DONE)
  foreach my $cpu (keys %{$all->{nsCPUname}}) {
    my $e = $self->create_event();
    $e->{device}      = $device;
    $e->{nsCPUname}   = $all->{nsCPUname}->{$cpu};
    $e->{nsCPUusage}  = $all->{nsCPUusage}->{$cpu};
    $self->push_to_transport($e);
  }

  # nsSysHealthEntry
  foreach my $c (keys %{$all->{sysHealthCounterName}}) {
    my $e = $self->create_event();
    $e->{device}      = $device;
    $e->{sysHealthCounterName}   = $all->{sysHealthCounterName}->{$c};
    $e->{sysHealthCounterValue}  = $all->{sysHealthCounterValue}->{$c};
    $self->push_to_transport($e);
  }

  # nsSysHealthDiskEntry
  foreach my $id (keys %{$all->{sysHealthDiskName}}) {
    my $e = $self->create_event();
    $e->{device}      = $device;
    $e->{sysHealthDiskAvail}  = $all->{sysHealthDiskAvail}->{$id};
    $e->{sysHealthDiskName}   = $all->{sysHealthDiskName}->{$id};
    $e->{sysHealthDiskPerusage} = $all->{sysHealthDiskPerusage}->{$id};
    $e->{sysHealthDiskSize}   = $all->{sysHealthDiskSize}->{$id};
    $e->{sysHealthDiskUsed}   = $all->{sysHealthDiskUsed}->{$id};
    $self->push_to_transport($e);
  }

  my @mons = qw(
    alarmMonrespto drtmLearningProbes drtmRTO monServiceName monitorCurFailedCount monitorFailed
    monitorFailedCode monitorFailedCon monitorFailedFTP monitorFailedId monitorFailedPort
    monitorFailedResponse monitorFailedSend monitorFailedStr monitorFailedTimeout monitorMaxClient
    monitorProbes monitorProbesNoChange monitorRTO monitorResponseTimeoutThreshExceed monitorState
    monitorWeight
  );

  my $monitorName     = $all->{monitorName};
  my $svcServiceName  = $all->{svcServiceName};

  # monServiceMemberEntry
  foreach my $svc_oid (keys %$svcServiceName) {
    foreach my $mon_oid (keys %$monitorName) {
      my $id = $svc_oid . "." . $mon_oid;
      if (exists $all->{monServiceName}->{$id}) {
        my $e = $self->create_event();

        $e->{device}            = $device;
        $e->{monitorName}       = $all->{monitorName}->{$mon_oid};

        foreach my $k (@mons) {
          $e->{$k} = $all->{$k}->{$id};
        }

        $self->push_to_transport($e);
      }
    }
  }

  my @svc = qw(
    svcActiveConn svcActiveTransactions svcAvgSvrTTFB svcAvgTransactionTime svcCurClntConnections
    svcEstablishedConn svcGslbSiteName svcInetAddress svcInetAddressType svcIpAddress
    svcMaxClients svcMaxReqPerConn svcPort svcRequestRate svcRxBytesRate svcServiceFullName
    svcServiceName svcServiceType svcState svcSurgeCount svcSynfloodRate
    svcTicksSinceLastStateChange svcTotalClients svcTotalPktsRecvd svcTotalPktsSent
    svcTotalRequestBytes svcTotalRequests svcTotalResponseBytes svcTotalResponses
    svcTotalServers svcTotalSynsRecvd svcTxBytesRate svcdosQDepth svctotalJsTransactions
  );

  # serviceEntry
  foreach my $id ( keys %{$all->{svcServiceName}} ) {
    my $e = $self->create_event();
    $e->{device} = $device;

    foreach my $k (@svc) {
      if (!defined($e->{$k} = $all->{$k}->{$id})) {
        warn "$k -> $id undef";
      }
    }

    $self->push_to_transport($e);
  }

  # vserverEntry
  my @vsvr = qw(
    vsvrActiveActiveState vsvrClientConnOpenRate vsvrCurClntConnections
    vsvrCurServicesDown vsvrCurServicesOutOfSvc vsvrCurServicesTransToOutOfSvc
    vsvrCurServicesUnKnown vsvrCurServicesUp vsvrCurSrvrConnections
    vsvrCurSslVpnUsers vsvrEntityType vsvrFullName vsvrHealth vsvrIp6Address vsvrIpAddress
    vsvrName vsvrPort vsvrRequestRate vsvrRxBytesRate vsvrState vsvrSurgeCount
    vsvrSynfloodRate vsvrTicksSinceLastStateChange vsvrTotHits vsvrTotMiss
    vsvrTotSpillOvers vsvrTotalClients vsvrTotalPktsRecvd vsvrTotalPktsSent
    vsvrTotalRequestBytes vsvrTotalRequests vsvrTotalResponseBytes vsvrTotalResponses
    vsvrTotalServers vsvrTotalServicesBound vsvrTotalSynsRecvd vsvrTxBytesRate vsvrType
  );

  foreach my $vid ( keys %{$all->{vsvrName}} ) {
    my $e = $self->create_event();
    $e->{device} = $device;

    foreach my $k (@vsvr) {
      if (!defined($e->{$k} = $all->{$k}->{$vid})) {
        warn "$k -> $vid undef";
      }
    }

    $self->push_to_transport($e);
  }

  my $t1 = [gettimeofday];

  my $elapsed = tv_interval $t0, $t1;

  printf("%s: Collect completed in %.6f (s)\n", $device, $elapsed);

}

1;

# vim: set sw=2 ts=2 expandtab:

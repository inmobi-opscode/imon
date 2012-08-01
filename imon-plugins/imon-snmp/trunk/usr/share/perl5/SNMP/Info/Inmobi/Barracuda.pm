#
# $Id: Barracuda.pm 4755 2012-01-11 05:24:15Z twikiuser $
#
#
# Provides a standard interface to Barracuda loadbalancer
#
package SNMP::Info::Inmobi::Barracuda;

use strict;
use Exporter;
use SNMP::Info::Inmobi;
use Data::Dumper;

@SNMP::Info::Inmobi::Barracuda::ISA = qw/SNMP::Info Exporter/;
@SNMP::Info::Inmobi::Barracuda::EXPORT_OK = qw//;

use vars qw/$VERSION %MIBS %FUNCS %GLOBALS %MUNGE/;

$VERSION = '2.06';

%MIBS = (
  'UCD-SNMP-MIB'  => 'memIndex',
  'Barracuda-REF' => 'zeroDotZero',
  'Barracuda-LB'  => 'systemActiveServices',
);

%GLOBALS = (
  # This should be UCD SNMP
  'b_mem_tot'     => 'memTotalReal',
  'b_mem_avail'   => 'memAvailReal',
  'b_mem_free'    => 'memTotalFree',
  'b_mem_buf'     => 'memBuffer',
  'b_mem_cached'  => 'memCached',
  # Barracuda-LB
  'b_sys_act_srv'           => '.1.3.6.1.4.1.20632.5.2',
  'b_sys_oper_srvrs'        => '.1.3.6.1.4.1.20632.5.3',
  'b_l4_tcp_conn'           => '.1.3.6.1.4.1.20632.5.6',
  'b_l7_http_req'           => '.1.3.6.1.4.1.20632.5.7',
  'b_rdp_sess'              => '.1.3.6.1.4.1.20632.5.8',
  'b_service_bandwidth'     => '.1.3.6.1.4.1.20632.5.9',
  'b_lb_bw'                 => '.1.3.6.1.4.1.20632.5.10',
  'b_real_server_bandwidth' => '.1.3.6.1.4.1.20632.5.11',
  'b_sys_status'      => '.1.3.6.1.4.1.20632.5.12',
  'b_load'            => '.1.3.6.1.4.1.20632.5.13',
  'b_cpu_temp'        => '.1.3.6.1.4.1.20632.5.14',
  'b_frmw_strg'       => '.1.3.6.1.4.1.20632.5.15',
  'b_mail_log_strg'   => '.1.3.6.1.4.1.20632.5.16',
  'b_sys_mode'        => '.1.3.6.1.4.1.20632.5.17',
  'b_l7_ftp_sess'     => '.1.3.6.1.4.1.20632.5.19',
  'b_l7_tcp_conn'     => '.1.3.6.1.4.1.20632.5.20',
);

%FUNCS = (
  'laIndex' => 'laIndex',
  'laNames' => 'laNames',
  'laLoad'  => 'laLoad',
  #'laConfig'  => 'laConfig',
  'laLoadInt' => 'laLoadInt',
  #'laLoadFloat' => 'laLoadFloat',
  #'memIndex'  => 'memIndex',
  'dskPercent'  => 'dskPercent',
);

%MUNGE = (
);

sub server_bandwidth {
  my $lb = shift;
  my $bw = $lb->b_server_bandwidth() || "";
  return undef unless defined($bw);
  return munge_connections($bw);
}

sub real_server_bandwidth {
  my $lb = shift;
  my $bw = $lb->b_real_server_bandwidth() || "";
  return undef unless defined($bw);
  return munge_connections($bw);
}

sub service_bandwidth {
  my $lb = shift;
  my $bw = $lb->b_service_bandwidth() || "";
  return undef unless defined($bw);
  return munge_connections($bw);
}

sub l7_tcp_conn {
  my $lb = shift;
  my $conn = $lb->b_l7_tcp_conn() || "";
  return undef unless defined ($conn);
  return munge_connections($conn);
}

sub rdp_sess {
  my $lb = shift;
  my $conn = $lb->b_rdp_sess() || "";
  return undef unless defined ($conn);
  return munge_connections($conn);
}

sub l7_http_req {
  my $lb = shift;
  my $conn = $lb->b_l7_http_req() || "";
  return undef unless defined ($conn);
  return munge_connections($conn);
}

sub l4_tcp_conn {
  my $lb = shift;
  my $conn = $lb->b_l4_tcp_conn() || "";
  return undef unless defined ($conn);
  return munge_connections($conn);
}

sub munge_connections {
  my $conn = shift;
  my $stats = {};

  return undef unless defined($conn);

  # XXX:
  # The output from 1.3.6.1.4.1.20632.5.9 (service bandwidth) OID is
  # inconsistent. Output includes malformed(?) entries like:
  #   http=56358
  #   roil_https=13
  # - Entries can also have multiple "_"
  # - Entries can have service names (https) instead of port numbers (443)
  # - Sometimes only the port is mentioned (http=56358)

  foreach my $entry ( split(/\s-\s/, $conn) ) {
    my ($vip_info, $vip_name, $vip_port, $v);

    if ( ($vip_name, $vip_port, $v) = $entry =~ /^(.*)_(.*)=(\d+)$/ ) {
      $stats->{lc($vip_name)}->{$vip_port} = $v;
    } else {
      # print $entry; #malformed entry?
    }
  }
  return $stats
}

return 1;

# vim: set ts=2 sw=2 expandtab:

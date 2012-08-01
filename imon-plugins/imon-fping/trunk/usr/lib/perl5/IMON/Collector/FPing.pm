# $Id: FPing.pm 5758 2012-03-07 17:47:45Z shanker.balan $
#
# IMON FPing Collector
#

$|=1;

package IMON::Collector::FPing;

use strict;
use warnings;
use Sys::Hostname;
use Socket;
use IMON::Utils::POE;

use Data::Dumper;

use base 'IMON::Collector::Base';

use constant FPING_BIN  => '/usr/bin/fping';
use constant DEFAULT_INTERVAL     => 60;
use constant SOURCE => 'FPING';
use constant HOSTNAME => hostname;

sub init {
  my ($self, %params) = @_;
  $self->SUPER::init(%params);
  $self->{cfg} = $params{cfg};
}

sub collect {
  my ($self) = @_;

  my $poe = IMON::Utils::POE->new();

  foreach my $device ($self->devices()) {
      my $sleep = $self->{cfg}->{interval} || DEFAULT_INTERVAL;
      $poe->create_session(
        interval => $sleep,
        coderef  => \&run_fping,
        args     => [ $self, $device ]
      );
      #print "$device: polling every $sleep (s)\n";
  }

  $poe->run();
}

# See Smokeping
sub run_fping {
  my ($self, $device) = @_;

  # I should test fping binary first no?
  my $fping   = $self->{cfg}->{fping} || FPING_BIN;
  my $tries   = $self->{cfg}->{tries} || 4;
  my @args    = ( $fping, "-q", "-A", "-c", $tries, $device );

  my $e = $self->create_event($device);

  #printf("%s: Running %s...\n", $device, "@args");

  my $out = `@args 2>&1`; $e->{exit_status} = $?;

  chomp ($out) if defined($out);

  printf("%s: (%d) %s\n", $device, $e->{exit_status}, $out);

  # see fping(8)
  if ($e->{exit_status} == 0) {  # reachable
    # 124.153.102.162 : xmt/rcv/%loss = 8/8/0%, min/avg/max = 21.2/24.1/28.1
    if ($out =~ /^(.*)\s:\s(.*)\s=\s(.*)%,\s(.*)\s=\s(.*)$/) {
      my $device_ip = $1;
      my @ploss_stats = split(/\//,$3);
      my @rtt_stats = split(/\//, $5);

      $e->{pkt_xmt}   = $ploss_stats[0];
      $e->{pkt_rcv}   = $ploss_stats[1];
      $e->{pkt_loss}  = $ploss_stats[2];
      $e->{rtt_min}   = $rtt_stats[0];
      $e->{rtt_avg}   = $rtt_stats[1];
      $e->{rtt_max}   = $rtt_stats[2];
      $e->{ip_address} = $device_ip;
      $e->{subnet}    = $self->get_subnet($device_ip);
    }
  } else {
    # 100% packet loss
    if ($out =~ /(.*)\s:\s(.*)\s=\s(.*)%/) {
      my $device_ip = $1;
      my @ploss_stats = split(/\//,$3);

      $e->{pkt_xmt}   = $ploss_stats[0];
      $e->{pkt_rcv}   = $ploss_stats[1];
      $e->{pkt_loss}  = $ploss_stats[2];
      $e->{ip_address} = $device_ip;
      $e->{subnet}    = $self->get_subnet($device_ip);
    }
  }
  #print Dumper $e;
  $self->push_to_transport($e);
}

sub create_event {
  my ($self, $device) = @_;
  my $e;
  $e->{device}    = $device;
  $e->{SenderIP}  = '127.0.0.1';
  $e->{Hostname}  = HOSTNAME;
  $e->{Source}    = $self->{cfg}->{source} || SOURCE;
  $e->{env}       = $self->{cfg}->{env};
  $e->{Type}      = $self->{cfg}->{event_type};
  $e->{pkt_xmt}   = 0;
  $e->{pkt_rcv}   = 0;
  $e->{pkt_loss}  = 0;
  $e->{rtt_min}   = 0;
  $e->{rtt_avg}   = 0;
  $e->{rtt_max}   = 0;
  return $e;
}

sub devices {
  my $self = shift;
  return @{$self->{cfg}->{devices}};
}

sub get_ip {
  my ($self, $device) = @_;
  my $packed_ip = gethostbyname($device);
  if (defined $packed_ip) {
    return inet_ntoa($packed_ip);
  }
  return;
}

sub get_subnet {
  my ($self, $ip) = @_;
  my @nets = split(/\./, $ip); pop @nets;
  return join(".", @nets) . ".0";
}

1;

# vim: set ts=2 sw=2 expandtab:

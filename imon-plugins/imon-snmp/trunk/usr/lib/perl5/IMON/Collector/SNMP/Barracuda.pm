#
# $Id: Barracuda.pm 5751 2012-03-07 12:10:41Z rengith.j $
#

package IMON::Collector::SNMP::Barracuda;

use strict;
use warnings;
use Socket;
use Time::HiRes qw( gettimeofday tv_interval );
use IMON::Utils::POE;

use Data::Dumper;

use base 'IMON::Collector::SNMP';

sub collect {
    my ($self) = @_;

  my $poe = IMON::Utils::POE->new();
  # create poe session for all the devices, which invokes snmp_collect periodically
  foreach my $device ($self->valid_devices()) {
    my $sleep = $self->interval($device) || 60;
    $poe->create_session( interval => $sleep,
                          coderef  => \&snmp_collect,
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
    $self->{info_obj}->{$device} = $self->init_snmp_info('Inmobi::Barracuda', $device);
  }

  printf("Collector init complete with %d valid devices\n", scalar($self->valid_devices()) );
}

sub snmp_collect {
  my ($self, $device) = @_;

  my $info = $self->{info_obj}->{$device};

  die "Unable to collect from $device. Object does not exist\n" unless $info;

  if ( my $svc_bw = $info->service_bandwidth() ) {
    if (!$svc_bw) {
      warn "$device: No data for service_bandwidth()\n";
    } else {
      foreach my $vip ( keys %$svc_bw ) {
        #print Dumper $svc_bw->{$vip};
        foreach my $port (keys %{$svc_bw->{$vip}}) {
          my $event   = $self->create_event();
          my $v       = $svc_bw->{$vip}->{$port} || 0; 
          $event->{'event_type'}  = 'service_bandwidth';
          $event->{'device'}      = $device;
          $event->{'vip'}         = $vip;
          $event->{'port'}        = $port;
          $event->{'svc_bw'}      = $v;
          $self->push_to_transport($event);
        }
      }
    }
  } else {
    warn "$device: Failed to collect service_bandwidth for $device\n";
  }
}

1;

# vim: set sw=2 ts=2 expandtab:

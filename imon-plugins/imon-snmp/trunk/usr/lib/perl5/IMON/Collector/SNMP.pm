#
# $Id: SNMP.pm 5751 2012-03-07 12:10:41Z rengith.j $
#

# Collector SNMP base package to provide basic functions to be used by higher
# level specific SNMP pollers

package IMON::Collector::SNMP;

use strict;
use warnings;

use Exporter;
use Sys::Hostname;
use Socket;
use Data::Dumper;

use base 'IMON::Collector::Base';

@IMON::Collector::SNMP::ISA       = qw/Exporter IMON::Collector::Base/;
@IMON::Collector::SNMP::EXPORT_OK = qw//;

use vars qw/$INTERVAL $COMMUNITY $PORT $VERSION $TIMEOUT @MIB_DIRS $RETRIES/;

$INTERVAL   = 60;
$COMMUNITY  = 'public';
$PORT       = 161;
$VERSION    = 2;
$TIMEOUT    = 3 * 1000000; # in micro-seconds
$RETRIES    = 3;
@MIB_DIRS   = qw( /usr/share/snmp/mibs );

my $hostname = hostname or die "Failed to get hostname(): $!\n";

sub init {
  my ($self, %params) = @_;

  $self->SUPER::init(%params);
  $self->{valid_devices} = [];
  $self->{cfg} = $params{cfg};

  # create sane defaults if non is specified in params
  my %default_snmp_options = (
    Version   => $self->{cfg}->{default}->{snmp_options}->{Version}   || $VERSION,
    Community => $self->{cfg}->{default}->{snmp_options}->{Community} || $COMMUNITY,
    Port      => $self->{cfg}->{default}->{snmp_options}->{Port}      || $PORT,
    MibDirs   => $self->{cfg}->{default}->{snmp_options}->{MibDirs}   || @MIB_DIRS,
    Timeout   => $self->{cfg}->{default}->{snmp_options}->{Timeout}   || $TIMEOUT,
    Retries   => $self->{cfg}->{default}->{snmp_options}->{Retries}   || $RETRIES,
    %{$self->{cfg}->{default}->{snmp_options}}
  );

  $self->{cfg}->{default}->{snmp_options} = \%default_snmp_options;

  foreach my $device (keys %{$self->{cfg}->{devices}}) {
    my %device_snmp_options;

    # inherit settings from default_snmp_options
    if (! defined $self->{cfg}->{devices}->{$device}->{snmp_options}) {
      %device_snmp_options = %default_snmp_options;
    } else {
      # merge missing bits from default_snmp_options with device_snmp_options
      %device_snmp_options = (
        %default_snmp_options,
        %{$self->{cfg}->{devices}->{$device}->{snmp_options}}
      );
    }

    # Assume DestHost == $device if none is set in device_snmp_opts
    $device_snmp_options{DestHost} ||= $device;

    $self->{cfg}->{devices}->{$device}->{snmp_options} = \%device_snmp_options;
    $self->{sender_ip} = $self->get_sender_ip;
  }

  return $self;
}

sub add_valid_device {
  my ($self, $device) = @_;
  push @{$self->{valid_devices}}, $device;
}

sub valid_devices {
  my $self = shift;
  return @{$self->{valid_devices}};
}

sub devices {
  my $self = shift;
  return keys %{$self->{cfg}->{devices}};
}

sub get_device_snmp_options {
  my ($self, $device) = @_;
  return %{$self->{cfg}->{devices}->{$device}->{snmp_options}};
}

sub get_device_snmp_option {
  my ($self, $device, $option) = @_;
  if ($self->{cfg}->{devices}->{$device}->{snmp_options}->{$option}) {
    return $self->{cfg}->{devices}->{$device}->{snmp_options}->{$option};
  }
  return; # nothng found?
}

sub init_snmp_info {
  my ($self, $rule, $device) = @_;

  my %snmp_options  = $self->get_device_snmp_options($device);
  my $class = "SNMP::Info";
  $class = "SNMP::Info::$rule" if $rule;

  # we need to test if the $class exist
  eval "require $class";
  die "Unable to load $class, Error: $@" if $@;

  my $snmp_info = $class->new(%snmp_options);

  if ( my $error = $snmp_info->error() ) {
    printf("%s: Error trying to init_device: %s\n", $device, $error);
    return;
  }
  
  $self->add_valid_device($device);

  return $snmp_info;
}

sub interval {
  my ($self, $device) = @_;
  my $interval = $self->{cfg}->{devices}->{$device}->{interval} || $self->{cfg}->{default}->{interval};
  return $interval if $interval;
  return $INTERVAL;
}

sub get_sender_ip {
  my $ip_address = '127.0.0.1';
  my $packed_ip = gethostbyname($hostname);

  return inet_ntoa($packed_ip) if $packed_ip;
  return $ip_address;
}

sub create_event {
  # Would like to merge in defaults at create_event time
  my $self = shift;
  my $e = {};

  $e->{Epoch} = time;
  $e->{SenderIP}   = $self->{sender_ip} || 'unknown';
  $e->{env}        = $self->{env}       || 'unknown';
  $e->{Source}     = $self->{name}      || 'unknown';
  $e->{Type}       = $self->{event_type} || 'unknown';
  $e->{Hostname}   = $hostname;

  return $e;
}

sub gen_imon_cfg {
  my ($self, $e) = @_;

  open(FILE, ">/tmp/imon.cfg");
  print FILE "#begin\n\n";
  foreach my $k (sort keys %$e) {
    print FILE sprintf("%s:\n  cf:\n    - Last\n", $k) if $self->is_valid_cfg($e->{$k});
  }
  print FILE "\nds_type:\n";
  foreach my $k (sort keys %$e) {
    print FILE sprintf("  %s: COUNTER\n", $k) if $self->is_valid_cfg($e->{$k});
  }
  print FILE "\nmap:\n";
  foreach my $k (sort keys %$e) {
    next unless $e->{$k} =~ /^[0-9]/;
    print FILE sprintf("  %s: %s\n", $k, $k) if (length($k) > 17 && $self->is_valid_cfg($e->{$k}));
  }
  print FILE "#end\n\n";
  close(FILE);
}

sub is_valid_cfg {
  my ($self, $v) = @_;
  return unless defined $v;
  return unless $v =~ /^[0-9]/;
  return 1;
}

1;

# vim: set ts=2 sw=2 expandtab:

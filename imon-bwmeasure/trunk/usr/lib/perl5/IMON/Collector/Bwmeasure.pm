#
# $Id: $
#

package IMON::Collector::Bwmeasure;

use strict;
use warnings;
use Time::HiRes qw( gettimeofday tv_interval );
use IMON::Utils::POE;
use base 'IMON::Collector::Base';
use Sys::Hostname;
$|=1;

my $my_hostname = hostname or die "Failed to get hostname(): $!\n";
my $iperf = "/usr/bin/iperf";

sub collect {
  my ($self) = @_;
  
  my $poe = IMON::Utils::POE->new();
  # create poe session for all the remote hosts, which invokes bwmeasure_get_all.
  my $sleep = $self->{cfg}->{poll_interval};
  foreach my $entry ($self->get_remote_dc_config()) {
    while (my ($remote_dc, $individual_dc_config) = each %{$entry}) {
      $poe->create_session( interval => $sleep, 
                            coderef  => \&bwmeasure_get_all, 
                            args     => [ $self, $remote_dc, \%$individual_dc_config ]
                        );
    }
  }
  # invoking the event dispatcher
  # will not return until all the sessions have ended
  $poe->run();
}

sub init {
  my ($self, %params) = @_;

  $self->SUPER::init(%params);
  $self->{cfg} = $params{cfg};
  
  if (!exists ($self->{cfg}->{protocol})) {
    $self->{cfg}->{protocol} = "tcp";
  }
  if (!exists ($self->{cfg}->{poll_interval})) {
    $self->{cfg}->{poll_interval} = 120;
  }
  if (!exists ($self->{cfg}->{timeout})) {
    $self->{cfg}->{timeout} = 100;
  }
  if (!exists ($self->{cfg}->{port})) {
    $self->{cfg}->{port} = 5001;
  }


  $self->{env} = $self->{cfg}->{env};

  if ($self->{cfg}->{protocol} eq "udp") {
    $self->{iperf_command} = "$iperf -p $self->{cfg}->{port} -f m -u";
  }
  else {
    $self->{iperf_command} = "$iperf -p $self->{cfg}->{port} -f m";
  }
  if (exists($self->{cfg}->{iperf_raw_args})) {
    $self->{iperf_command} = $self->{iperf_command}." ".$self->{cfg}->{iperf_raw_args};
  }
}

# Sub routine to find the remote hosts and datacenter to which we will connect 
# in order to calculate the bandwidth.
sub get_remote_dc_config {
  my ($self) = @_;
  my @dc_config_remote = @{$self->{cfg}->{dc_config}}; 
  my $i = 0;
  foreach my $entry (@dc_config_remote) {
    while (my ($datacenter, $individual_dc_config) = each %{$entry}) {
      # discard if it is this machine
      if ($my_hostname eq $individual_dc_config->{monmachine}) {
        splice (@dc_config_remote, $i, 1);
        # We will need the following later.
        $self->{cfg}->{mydc} = $datacenter;
      }
    }
    $i++;
  }
  return @dc_config_remote;
}

# sub routine whose coderef is passed to poe above.
sub bwmeasure_get_all {
  my ($self, $remote_dc, $individual_dc_config) = @_;
  # We run iperf client with a set data size (increasing from a lower to upper limit
  # defined by a step). The imon aggregator is used to find mean,max,min from the runs.
  # Units are in megs.
  my @bwarray = ();
  
  print "Collecting Bandwidth information between my host and $individual_dc_config->{monmachine} in $remote_dc\n";
  if (!exists ($individual_dc_config->{datasize_min})) {
    $individual_dc_config->{datasize_min} = 1;
  }  
  if (!exists ($individual_dc_config->{datasize_max})) {
    $individual_dc_config->{datasize_max} = 20;
  }  
  my $try = 0;
  for (my $i=$individual_dc_config->{datasize_min}; $i<=$individual_dc_config->{bandwidth_max}; $i=$i+$individual_dc_config->{datasize_step}) {
    my $cmd = $self->{iperf_command}." -c $individual_dc_config->{monmachine} -n ".$i."M";
    my @command_out = qx($cmd 2>&1);
    for my $line (@command_out) {
    # Match the last line of the output
      if ( $line =~ /^\[\ *[0-9]+\]\ \ .*\ ([0-9]+)\ Mbits\/sec/mx ) {
        #print "$1\n";
        push (@bwarray, $1);
      }
    }
    $try++;
  }
  
  foreach my $entry (@bwarray) {
    my $e = {};
    $e->{Hostname} = $my_hostname;
    $e->{Source} = $self->{cfg}->{name};
    $e->{Type} = $self->{Type};
    $e->{env} = $self->{env};
    $e->{sink} = $individual_dc_config->{monmachine};
    $e->{sourcedc} = $self->{cfg}->{mydc}; 
    $e->{sinkdc} = $remote_dc; 
    $e->{protocol} = $self->{cfg}->{protocol}; 
    $e->{bandwidth} = $entry;
    $e->{bandwidth_target} = $individual_dc_config->{bandwidth_max};
    $e->{try_iteration} = $try;
    $self->push_to_transport($e);
  }
}

1;

# vim: set sw=2 ts=2 expandtab:

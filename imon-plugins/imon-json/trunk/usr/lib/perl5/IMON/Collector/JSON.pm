#
# $Id: JSON.pm 6336 2012-03-29 04:25:41Z shanker.balan $
#
$|=1;

# JSON Collector

package IMON::Collector::JSON;

use strict;
use warnings;
use Exporter;
use JSON;
use Sys::Hostname;
use LWP::UserAgent;
use Hash::Flatten;
use Time::HiRes qw( gettimeofday tv_interval );

use IMON::Utils::POE;
use base 'IMON::Collector::Base';

sub collect {
  my ($self) = @_;

  my $poe = IMON::Utils::POE->new();

  foreach my $h (@{$self->{cfg}->{hosts}}) {
    my $sleep = $self->{interval} || 60;
    $poe->create_session( interval => $sleep,
      coderef  => \&fetch_json_stats,
      args     => [ $self, $h ] 
    );
  }
  $poe->run();
}

sub init {
  my ($self, %params) = @_;

  $self->SUPER::init(%params);
  $self->{cfg} = $params{cfg};
  $self->{ua} = LWP::UserAgent->new( %{$self->{cfg}->{options}} );
  $self->{hostname} = hostname or die "Failed to get hostname(): $!\n";

  return $self;
}

sub fetch_json_stats {
  my ($self,$host) = @_;
  my $ua = $self->{ua};
  my $url = $self->{cfg}->{url}; $url =~ s/^\///;
  my $port = $self->{cfg}->{port} ? $self->{cfg}->{port} : 80;
  my $protocol = 'http';
  $protocol = 'https' if $self->{cfg}->{ssl};

  my $get_url = sprintf("%s://%s:%d/%s", $protocol, $host, $port, $url);

  #print "Fetching $get_url...\n";

  my $t0 = [gettimeofday];
  my $response = $ua->get($get_url);
  my $t1 = [gettimeofday];

  if (!$response->is_success) {
    printf("%s: ERROR %s\n", $host, $response->status_line);
    return;
  }

  printf("%s: %s in %.3f seconds\n", $host, $response->status_line, tv_interval($t0, $t1) );

  my $content = $response->decoded_content;
  my $stats = decode_json $content;

  my $o = new Hash::Flatten;
  my $event = $o->flatten($stats);

  $event->{Hostname}  = $host;
  $event->{Type}      = $self->{event_type}     ? $self->{event_type} : 'JsonStats';
  $event->{Source}    = $self->{cfg}->{source}  ? $self->{cfg}->{source} : 'JsonStats';
  $event->{env}       = $self->{cfg}->{env}     ? $self->{cfg}->{env} : 'json_stats'; 

  $self->push_to_transport($event);
}

# vim: set ts=2 sw=2 expandtab:

#
# $Id: PagerDuty.pm 7877 2012-05-08 06:35:38Z rengith.j $
#

package IMON::Sender::PagerDuty;

use strict;
use warnings;
use POE;
use LWP::UserAgent;
use JSON;

use constant DEFAULT_PAGERDUTY_URL => "https://events.pagerduty.com/generic/2010-04-15/create_event.json";
use constant DEFAULT_RETRIES => 3;
use constant DEFAULT_TIMEOUT => 120;

use base 'IMON::Sender::AlertBase';

$|=1;
sub init {
    my ($self, %params) = @_;

    $self->SUPER::init(%params);

    $self->{tag_list}       = $params{cfg}->{tag_list};
    $self->{tag_match}      = {};
    $self->{tag_nomatch}    = {};

    my $pager_settings = $params{cfg}->{pager_settings};
    $self->init_pager($pager_settings);
}

sub init_pager {
    my ( $self, $cfg ) = @_;

    # setting defaults for events
    $self->{event} = {event_type => $cfg->{event_type} || "trigger", details => {}};
    
    my ($url, $timeout, $ua, $req);

    $url                    = $cfg->{pagerduty_url} || DEFAULT_PAGERDUTY_URL;
    $timeout                = $cfg->{timeout}       || DEFAULT_TIMEOUT;
    $self->{retries}        = $cfg->{retries}       || DEFAULT_RETRIES;
    $self->{service_key}    = $cfg->{service_key};

    # create useragent and http request object
    $ua = LWP::UserAgent->new;
    $ua->agent("imon-pager");
    $ua->timeout($timeout); #resetting request timeout

    $req = HTTP::Request->new(POST => $url);
    $req->content_type('application/x-www-form-urlencoded');

    $self->{ua}  = $ua;
    $self->{req} = $req;
}

sub send_data {
    my $self = shift;

    POE::Session->create(
        inline_states => {
            _start      => sub { $_[KERNEL]->yield('pull_data'); },
            pull_data   => sub { &{pull_data}($self, $_[KERNEL]); },
            process => 
                sub {
                    $_[HEAP]{retry_count} = 0;
                    &{process_and_page}($self, $_[ARG0], $_[KERNEL]);
                    $_[KERNEL]->yield('pull_data');
                },
            retry_on_timeout => 
                sub {
                    $_[HEAP]{retry_count}++;
                    my $rc = $_[HEAP]{retry_count};
                    if ($rc <= $self->{retries}) {
                        print "Request timed out, retrying($rc)\n";
                        &{post_request}($self, $_[ARG0], $_[KERNEL]);
                        $_[KERNEL]->yield('pull_data');# resume pulling data
                    }else {
                        print "Request retries failed, skipping the event. Resume pulling data\n";
                        $_[KERNEL]->yield('pull_data');
                    }
                },
        },
    );
    POE::Kernel->run();
}

sub pull_data {
    my ($self, $kernel) = @_;

    while(1) {
        my $found = 0;
        foreach my $t(@{$self->{transport}}) {
            map {
                $kernel->yield('process', $_);
                $found++; last;
            } $t->pull_data();
            last if ($found);
        }
        if ($found) {
            $found = 0; last;
        }
        sleep 1;
    }
}

sub process_and_page {
    my ( $self, $e, $kernel ) = @_;
    
    my ($hostname, $source);
    my $sleep_host = $e->{pivot} || $e->{Hostname};
    $hostname  = $e->{Hostname};
    $source    = $e->{Source};
    my $pivot     = $e->{pivot} || "unknown_pivot";

    if (!defined $hostname || !defined $source) {
        print "Hostname or Source attribute missing in the event, skipping\n";
        return;       
    }

    if (!defined($self->{service_key}->{$source})) {
        print "No service key found for source $source, not alerting\n";
        return;
    }

    if (!defined($e->{tags})) {
        print "Received invalid event from source $source on $hostname. Missing tag\n";
        return;
    }
    # skip.. if in sleep period
    if ($self->isleep(host => $sleep_host, source => $source)) {
        print "Host $sleep_host or source $source on $sleep_host is under sleep period, not alerting\n"; 
        return;
    }
    my @req_list = ();
    my $details = $self->{event};
    $details->{service_key} = $self->{service_key}->{$source};

    foreach my $tag (keys %{$e->{tags}}) {
        # skip if the tag not matches the tag_list in the config 
        # this check happens only once for a tag
        if ( ($self->{tag_nomatch}->{$tag}) || (!($self->{tag_match}->{$tag}) && !($self->tag_matched($tag))) ) {
            next;
        }
        if ($self->isleep(host => $sleep_host, source => $source, tag =>$tag)) {
            print "Tag $sleep_host/$source/$tag is under sleep period, not alerting\n";
            next;
        }            
        my $tag_value = $e->{tags}->{$tag};

        next if (!defined $tag_value);
        my $text = sprintf("%s: %s %s %s", $pivot, $source, $tag, $tag_value);
        $details->{description} = $text;
        push @req_list, encode_json $details;
    }
    # passing the kernel in order to yield retry_on_timeout in case of request timeouts
    $self->post_request(\@req_list, $kernel) if(@req_list);
}

sub post_request {
    my ( $self, $req_list, $kernel ) = @_;

    my @req = @{$req_list};
    foreach my $i(0 .. scalar(@req)-1) {
        $self->{req}->content($req[$i]); 
        my $res = $self->{ua}->request($self->{req});
        if ($res->is_success) {
            print "Successfully Paged (req_string: $req[$i])\n";
        }else {
            my $rc = $res->code;
            # invoke retry_on_timeout if the request timedout
            if ($rc eq 408) {
                sleep 1; # wait for a sec and retry
                my @r = @req[$i .. scalar(@req)-1];
                $kernel->yield('retry_on_timeout', \@r);
                last; # retry happens for the rest of the events in the event list, hence dont proceed
            }else {
                # For non-timeout errors, flushing err_code and json_string to stdout
                print "Request failed, skipping.. (err_code: $rc, json_string: $req[$i])\n";
            }
        }
    }
}

sub tag_matched {
    my ($self, $tag) = @_;

    my $tag_matched = 0;
    foreach my $t(@{$self->{tag_list}}) {
        if ($t =~ /^\/(.+)\/$/) {
            my $m = $1;
            if ($tag =~ /$m/) {
                $tag_matched++;
                last;
            }
        }elsif ($tag eq $t) {
            $tag_matched++;
            last;
        }
    }
    # preserving match/nomatch info to avoid further check for a tag
    $tag_matched ? $self->{tag_match}->{$tag}++ : $self->{tag_nomatch}->{$tag}++;
    return $tag_matched;
}

1;

# vim: set ts=4 sw=2 expandtab:

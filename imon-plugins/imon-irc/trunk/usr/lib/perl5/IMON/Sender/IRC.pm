#
# $Id: IRC.pm 6151 2012-03-23 06:02:54Z shanker.balan $
#

# TODO:
# - Add IRC handlers to quit gracefully from the server
# - Use callbacks for on_public_command()
# - If running under a Collector (LWES for example), handle hearbeats for uptime
# - A useful help
# DONE:
# - Fork model is not handling signals correctly. Move to threads
# - Colors need to be config driven

package IMON::Sender::IRC;

use strict;
use warnings;
use threads;
use Thread::Queue;
use Net::IRC;

use base 'IMON::Sender::AlertBase';

use constant {
  WHITE       => "\x0300",
  BLACK       => "\x0301",
  BLUE        => "\x0302",
  GREEN       => "\x0303",
  RED         => "\x0304",
  BROWN       => "\x0305",
  PURPLE      => "\x0306",
  ORANGE      => "\x0307",
  YELLOW      => "\x0308",
  LIGHT_GREEN => "\x0309",
  TEAL        => "\x0310",
  LIGHT_CYAN  => "\x0311",
  LIGHT_BLUE  => "\x0312",
  PINK        => "\x0313",
  GREY        => "\x0314",
  LIGHT_GREY  => "\x0315",
  DEFAULT_RETRIES => 3,
};

my $HEARTBEAT_INTERVAL = 300;
my $WARN_COLOR  = YELLOW;
my $CRIT_COLOR  = RED;
my $ERROR_COLOR = TEAL;

my $conn;

sub init {
  my ($self, %params) = @_;
  my $pid;

  $self->SUPER::init(%params);

  $self->{q} = Thread::Queue->new(); 
  $self->{retries} = $params{cfg}{retries} || DEFAULT_RETRIES;

  my $sub = sub {
    while (1) {
      $self->init_irc(%params);
    }
  };

  my $thr = threads->create($sub);
  $thr->detach();
}

sub init_irc {
  my ( $self, %params ) = @_;

  # reinit subref, invokes init_irc
  my $reinit_sub = sub { 
                        my $msg = shift;
                        print "$msg\n";
                        $self->init_irc(%params); 
                };
  # on die reinit_irc
  $SIG{__DIE__} = sub { $reinit_sub->("Received DIE signal, re-initing irc"); };
  my %irc_settings = %{$params{cfg}{irc_settings}};

  my $irc = new Net::IRC;
  $conn = $irc->newconn(%irc_settings) or die "Can't connect to IRC server: $!\n";
  $self->{conn} = $conn;
  # stashing retries and reinit_sub to irc conn object
  $conn->{retries} = $self->{retries};
  $conn->{reinit_sub} = $reinit_sub;
  # stashing sleep routines to irc conn obj
  $conn->{sleep_details} = sub { $self->sleep_details(@_) };
  $conn->{set_sleep} = sub { $self->set_sleep(@_) };
  $conn->{sleep_error} = sub { $self->error(@_) };

  $conn->{channel} = $params{cfg}{channel};
  die "No channel to join. Please fix config" unless defined $conn->{channel};

  $conn->add_global_handler([ 251,252,253,254,302,255 ], \&on_init);
  $conn->add_global_handler('433', \&on_nick_taken);
  $conn->add_global_handler('376', \&on_connect);
  $conn->add_global_handler('disconnect', \&on_disconnect);
  $conn->add_global_handler('msg', \&on_msg);
  $conn->add_handler('public', \&on_public);
  $conn->add_handler('notice', \&on_notice);
  $conn->add_handler('ping', \&on_ping);
  $conn->add_handler('kill', \&on_kill);
  $conn->add_handler('kick', \&on_kick);

  my $heartbeat   = $params{cfg}{heartbeat} || $HEARTBEAT_INTERVAL;
  my $error_color = $params{cfg}{colors}{'error'} || $ERROR_COLOR;
  my $warn_color  = $params{cfg}{colors}{'warn'}  || $WARN_COLOR;
  my $crit_color  = $params{cfg}{colors}{'crit'}  || $CRIT_COLOR;

  my $q = $self->{q};
  my $last_heartbeat = 0;
  my $last_nickreset = 0;

  # We cant do a $irc->start because we dont get control back
  while (1) {
    my $now = time;

    # Hpw many pending items in queue?
    my $pending = $q->pending();

    # do_one_loop() instead of start()
    $irc->do_one_loop();

    # reset nick to default. but try only once every 30s prevent NOTICE
    if ($conn->nick ne $irc_settings{Nick}) {
      # start timer if 0
      $last_nickreset = time if $last_nickreset == 0;
      my $elapsed = $now - $last_nickreset;
      print "Elapsed: $elapsed\n";
      if ($elapsed > 30) {
        print "Attempting nick reset to " . $irc_settings{Nick} . "\n";
        $conn->nick($irc_settings{Nick});
        $last_nickreset = 0;
      }
    }

    # XXX: RFC 1459: # the client may send 1 message every 2 seconds without
    # being adversely affected
    if ($pending > 0) {

      if (defined( my $e = $q->dequeue_nb()) ) {

        if (defined($e->{EventType}) and ($e->{EventType} eq 'System::Heartbeat')) {
          #print "Received heartbeat...\n"; # do something smarter
          next;
        }

        my $sleep_host = $e->{pivot} || $e->{Hostname};
        my $hostname  = $e->{Hostname} || "unknown_host";
        my $source    = $e->{Source} || "unknown_src";
        my $pivot     = $e->{pivot} || "unknown_pivot";

        if (!defined($e->{tags})) {
          print "Received invalid event from source $source on $hostname. Missing tag\n";
          next;
        }
        # skip.. if in sleep period
        # 1. host specific 2. host/source specific 3. host/source/tag specific
        if ($self->isleep(host => $sleep_host, source => $source)) {
          print "Host $sleep_host or source $source on $sleep_host is under sleep period, not alerting\n";        
          next;
        }

        foreach my $tag (keys %{$e->{tags}}) {
          if ($self->isleep(host => $sleep_host, source => $source, tag =>$tag)) {
            print "Tag $sleep_host/$source/$tag is under sleep period, not alerting\n";
            next;
          }            
          my $tag_value = $e->{tags}->{$tag};
          my $start_color = WHITE;
          $start_color  = $ERROR_COLOR if $tag =~ /^error|^unk/;
          $start_color  = $WARN_COLOR if $tag =~ /^warn/i;
          $start_color  = $CRIT_COLOR if $tag =~ /^crit/i;
      
          my $text = sprintf("%s%s: %s %s %s\x0f\n", $start_color, $pivot, $source,
            $tag, $tag_value);
          print "*** $text\n";
          $conn->privmsg($conn->{channel}, $text );
          sleep 2;  # Safe and use 2
        }

      }
    } else {
      # print "Q is empty\n";
    }

    # Hmm, how do I send a HB every 10 mins?
    my $elapsed = $now - $last_heartbeat;
    if ( $elapsed >= $heartbeat ) {
      my $t = localtime($now);
      print "*** Heartbeat sent at $t\n";
      $conn->privmsg($conn->{channel}, "$t (heartbeat)");
      $last_heartbeat = $now;
    } else {
      #print "Timer is $elapsed\n";
    }

  }
}

sub send_data {
  my $self = shift;
  my $q = $self->{q};
  while(1) {
    foreach my $t(@{$self->{transport}}) {
      map {
        my %hash = %$_;
        $q->enqueue(\%hash);
      } $t->pull_data();
    }
    sleep 1;
  }
}

sub on_kill {
  my ($self, $event) = @_;

  print "Got kill from ", $event->from(), " (",
  ($event->args())[0], "). Attempting to reconnect...\n";
  $self->connect();
}

sub on_kick {
  my ($self, $event) = @_;
  print "Got kicked from ", $event->from(), " (",
  ($event->args())[0], "). Attempting to reconnect...\n";
  sleep 5;
  $self->connect();
}

sub on_nick_taken {
  my ($self) = shift;
  my $rand_nick = $self->nick . $$;
  print "Nick taken. Changing to $rand_nick (will try resetting later)...\n";
  $self->nick($rand_nick);
}

sub on_connect {
  my $self = shift;
  print "*** Joining channel " . $self->{channel} . "\n";
  $self->join($self->{channel});
}

sub on_disconnect {
  my ($self, $event) = @_;

  print "Disconnected from ", $event->from(), " (",
  ($event->args())[0], "). Attempting to reconnect...\n";

  my $retries = 0;
  while (!$self->error) {
    my $sleep = 5;
    sleep 5;
    $retries++;
    print "Trying($retries) in $sleep (s)...\n";
    $self->connect();
    # reinit_irc if retries failed $self->{retries} times
    if ($retries == $self->{retries}) {
      $self->{reinit_sub}->("reconnect failed $retries times, re-initing irc");
    }
  }
}

sub on_init {
  my ($self, $event) = @_;
  my (@args) = ($event->args);
  shift (@args);

  print "*** @args\n";
}

sub on_public {
  my ($self, $event) = @_;
  my $mynick = $self->nick;
  my $nick  = $event->nick;
  my $to    = $event->{to}[0];
  my $text  = $event->{args}[0];

  chomp($text);

  if ($text !~ /^$mynick:\s/) {
    #print "Skipped $text. Not to me\n";
    return 1;
  }

  my (undef, $cmd, @args) = split(/\s+/, $text);

  if (!defined( my $resp = on_public_command($self, $cmd, @args)) ){
    chomp($resp);
    print "*** $cmd failed ($resp)\n";
    $self->privmsg($to, "$nick: Failed");
  } else {
    print "*** $cmd ok ($resp)\n";
    $self->privmsg($to, "$nick: $resp");
  }
}

sub on_public_command {
  my ($self, $command, @args) = @_;

  if ($command eq 'ping') {
    return "pong"
  } elsif ($command eq 'help') {
    return 1;
  } elsif ($command eq 'uptime') {
    my $uptime = `uptime`;
    my $runtime = time - $^T;
    return "$runtime(s) $uptime";
  } elsif ($command eq 'sleep') {
    return unless (@args);
    # sleep with digits as last parameter will invoke the set_sleep
    if ($args[-1] =~ /^\d+$/) {
     my $sleep = pop(@args);
     if(my $msg = $self->{set_sleep}->(join('/',@args),$sleep)) {
        return "$msg";
     }else {
        my $err = $self->{sleep_error}->();
        return "$err";
     }
    # else it is a querry to get sleep details
    }else {
      if (my $h = $self->{sleep_details}->(join('/',@args))) {
        my $duration = $h->{duration};
        return "@args has been sleeping for " . $h->{duration} . "(s), " . $h->{remaining} . "(s) remaining";
      }else {
        return "@args not under sleep";
      }
    }
  } else {
    # No such command?
    return;
  }
}

sub on_notice {
  my ($self, $event) = @_;
  my ($their_nick) = $event->nick;
  my ($notice_txt) = join(' ', $event->args);
  print "$notice_txt\n";
}

sub on_ping {
  my ($self, $event) = @_;
  my $nick = $event->nick;
  
  $self->ctcp_reply($nick, join (' ', ($event->args)));
  print "*** CTCP PING request from $nick received\n";
}

sub on_error {
  my $conn = shift;
  print "Error\n";
}

sub on_msg {
  my ($self, $event) = @_;
  my ($nick) = $event->nick;
  print "*$nick*  ", ($event->args), "\n";
}

1;

# vim: set ts=2 sw=2 expandtab:

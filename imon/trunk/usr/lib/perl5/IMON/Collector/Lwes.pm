#
# $Id: Lwes.pm 5791 2012-03-09 06:01:11Z rengith.j $

package IMON::Collector::Lwes;

use strict;
use warnings;
use base 'IMON::Collector::Base';
use LWES::EventParser;
use LWES::Listener;
use IO::Socket::INET;
use IO::Socket::Multicast;
use Data::Validate::IP qw(is_multicast_ipv4);
use LWES;

sub collect {
    my ($self) = @_;

    while(1){
        my $e = $self->recv_event();

        next if ( ( defined $e->{EventType} ) && !grep { $_ eq $e->{EventType} } @{$self->{event_type}} );

        $self->push_to_transport($e);
    }
}

sub init {
    my ($self, %params) = @_;
	
    $self->SUPER::init(%params);

    $self->{context_as_keys} = $params{cfg}->{context_as_keys};

    if ( is_multicast_ipv4($self->{ip}) ) {
        $self->{sock} = IO::Socket::Multicast->new(LocalPort=>$self->{port}, Reuse=>1)
            or die "Can't create socket: $!";
        # add multicast address
        $self->{sock}->mcast_add($self->{ip}) or die "mcast_add: $!";
    }else {
        $self->{sock} = IO::Socket::INET->new(LocalPort=>$self->{port}, Proto=>'udp', ReuseAddr=>1)
            or die "Can't create socket: $!";
    }
    $self->set_type("Lwes"); # set $self->{Type} to "Collected::Lwes"
}

sub recv_event {
    my $self = shift;

    my ($msg, $peer, $event_to_keyvalue) = (undef, undef, \&event_to_keyvalue_std);
    if (defined($self->{context_as_keys})) {
      $event_to_keyvalue = \&event_to_keyvalue_ctk;
    }
    while (1) {
        $peer = recv ($self->{sock}, $msg, 65535, 0);
        if (!$peer && ($!{EINTR} || $!{ERESTART})) {
            next;
        } elsif (!$peer) {
            die "socket recv error: $!\n";
        }
        last;
    }
    my ($port, $peeraddr) = sockaddr_in($peer);

    my $hash = {};
    $hash = LWES::event_hash_from_bytes($msg);
    if ($hash->{EventType} eq 'MonDemand::StatsMsg') {
        $hash = &{$event_to_keyvalue}($self, $hash);
    }

    $hash->{'SenderIP'}   ||= inet_ntoa($peeraddr);
    $hash->{'SenderPort'} ||= $port;
    $hash->{'env'}        ||= $self->{env};
    $hash->{'Hostname'}   ||= $hash->{hostname} || $hash->{SenderIP};
    $hash->{'Source'}     ||= $self->{name};
    $hash->{Type}           = $self->{Type};

    return $hash;
}

# decode mondemand event ( context is set as context.<context_name> )
sub event_to_keyvalue_std {
    my ($self, $e) = @_;

    my $vals = {};
    if ($e->{num}) {
        foreach my $i(0 .. $e->{num} - 1) {
            my $k = $e->{"k$i"};
            $vals->{$k} = $e->{"v$i"};
        }
    }

    if ($e->{ctxt_num}) {
        foreach my $i(0 .. $e->{ctxt_num} - 1) {
            my $k = $e->{"ctxt_k$i"};
            $vals->{"context\.$k"} = $e->{"ctxt_v$i"};
        }
    }
    $vals->{EventType} = $e->{EventType};
    $vals->{Source} = $vals->{prog_id} = $e->{prog_id};
    $vals->{Hostname} = $e->{hostname} || $e->{Hostname};

    return $vals;
}

# decode mondemand event (treat context as normal keys)
sub event_to_keyvalue_ctk {
    my ($self, $e) = @_;

    my $vals = {};
    if ($e->{num}) {
        foreach my $i(0 .. $e->{num} - 1) {
            my $k = $e->{"k$i"};
            $vals->{$k} = $e->{"v$i"};
        }
    }

    if ($e->{ctxt_num}) {
        foreach my $i(0 .. $e->{ctxt_num} - 1) {
            my $k = $e->{"ctxt_k$i"};
            $vals->{"$k"} = $e->{"ctxt_v$i"};
        }
    }
    $vals->{EventType} = $e->{EventType};
    $vals->{Source} = $vals->{prog_id} = $e->{prog_id};
    $vals->{Hostname} = $e->{hostname} || $e->{Hostname};

    return $vals;
}

1;

# vim: set sw=2 ts=4 expandtab:

#
# $Id: ImonConnector.pm 7871 2012-05-08 04:54:07Z rengith.j $

=head1 NAME
 
IMON::Transport::ImonConnector: LWES based imon transport module to send/receive events over network

=head1 AUTHOR

Rengith Jerome <rengith.j@inmobi.com>
=cut

package IMON::Transport::ImonConnector;

use LWES;
use LWES::EventParser;
use LWES::Listener;
use IO::Socket::INET;
use IO::Socket::Multicast;
use Data::Validate::IP qw(is_multicast_ipv4);
use threads;
use IMON::Transport::InMemory;
use Socket;

use base 'IMON::Transport::Base';

use constant DEFAULT_EVENT_TTL => 16;

sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params);

    map { $self->{$_} = $params{cfg}->{$_} } keys %{$params{cfg}};

    # mandatory config parameters, set error and return if not defined
    foreach (qw( addr port event_type )) {
        if (!defined($params{cfg}->{$_})) {
            $self->{error} = "ImonConnector Transport parameter '$_' missing";
            return;
        }
    }
    if ( $self->{addr} !~ /^\d+\.\d+\.\d+\.\d+$/ )  {
        my $packed_addr = gethostbyname($self->{addr});
        if (defined $packed_addr) {
            $self->{addr} = inet_ntoa($packed_addr);
        }else {
            $self->{error} = "ImonConnector: unable to resolve hostname($self->{addr}) to IP address";
            return;
        }
    }
}

sub push_data {
    my ($self, $e) = @_;

    # create emitter object if it's not already created
    $self->{emitter} ||= LWES::create_emitter($self->{addr}, "0", $self->{port}, $self->{ttl} || DEFAULT_EVENT_TTL , 60);

    my $event = LWES::create_event(undef, $self->{event_type});

    foreach my $k(%{$e}) {
        if ( !ref($e->{$k}) ) {
            LWES::set_string($event, "$k", "$e->{$k}") if (defined $e->{$k});
        }else {
            # if the value is a reference, it need to be serialized
            my %serialized = $self->_serialize(key => $k, valref => $e->{$k});
            foreach my $key(keys %serialized) {
                LWES::set_string($event, "$key", "$serialized{$key}") if (defined $serialized{$key});
            }
        }
    }

    print "ImonConnector: Sending event to $self->{addr} on port $self->{port}\n";
    LWES::emit($self->{emitter}, $event);
    LWES::destroy_event($event);
}

#
# pull_data listens for evetns at the multicast/unicast udp addr/port
#
sub pull_data {
    my $self = shift;

    # creating InMemory q obj to keep the pushed data in q (this will run as a child thread)
    # invoked only once (during the first time pull_data got called)
    $self->create_queuing_thread() if (!defined $self->{queuing_thread});

    my $q = $self->{q};
    my @ret;

    # dequeue the event, deserializes it and returns the list of deserialized events
    foreach my $href(my @list = $q->pull_data() ) {
        if (keys %{$href}) {
            my $rh = $self->_deserialize($href); 
            # consider only if there are keys in return_hash(rh)
            push @ret, $rh if (keys %{$rh});
        }
    }
    return @ret;
}

# create a thread to get the pushed data and enqueue it in memory
sub create_queuing_thread {
    my $self = shift;

    # using InMemory Transport object for keeping pushed data in memory
    # pull_data will dequeue the data from the inmemory queue rather than 
    # directly listening for data on the multicast ip/port
    $self->{q} = IMON::Transport::InMemory->new();

    my $sub = sub {
                $self->init_socket() if (!defined $self->{sock});
                while (1) {
                    my $href = $self->recv_event();
                    $self->{q}->push_data($href) if ($href);
                    sleep 1;
                }
    };
    my $thr = threads->create($sub);
    $thr->detach();
    $self->{queuing_thread} = $thr;
}

sub init_socket {
    my $self = shift;

    # multicast addr check, if fails use udp unicast
    if ( is_multicast_ipv4($self->{addr}) ) {
        $self->{sock} = IO::Socket::Multicast->new(LocalPort=>$self->{port}, Reuse=>1)
            or die "Can't create socket: $!";
        # add multicast address
        $self->{sock}->mcast_add($self->{addr}) or die "mcast_add: $!";
    }else {
        $self->{sock} = IO::Socket::INET->new(LocalPort=>$self->{port}, Proto=>'udp', ReuseAddr=>1)
            or die "Can't create socket: $!";
    }
}

sub recv_event {
    my $self = shift;

    my ($msg, $peer);
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

    my $hash = LWES::event_hash_from_bytes($msg);
    return $hash;
}

#
# _serialize hashref's in the event
# <>_keynames will have the keys separated by ','
# set <>_<key> with corresponding values
# need to do arrayref serialization if required
#
sub _serialize {
    my ($self, %event) = @_;

    my %h;
    if ( ref($event{valref}) eq 'HASH' ) {
        my @keys = keys %{$event{valref}};
        $h{"$event{key}\_keynames"} = join(',', @keys);
        foreach my $k( @keys ) {
            $h{"$event{key}\_$k"} = $event{valref}->{$k};
        }
    }
    return %h;
}

#
# _deserialize the hashref's in the events back to HOH
#
sub _deserialize {
    my ($self, $hash) = @_;

    my $h = {};
    foreach my $k(keys %{$hash}) {
        if ($k =~ /(.+)\_keynames$/) {
            my $href_key = $1;
            foreach my $key(split(/,/,$hash->{$k})) {
                if ($hash->{"$href_key\_$key"}) {
                    $h->{$href_key}->{$key} = delete $hash->{"$href_key\_$key"};
                }
            }
            delete $hash->{$k}; # don't need the <>_keynames key
        }
    }
    foreach (keys %{$hash}) {
        $h->{$_} ||= $hash->{$_}; 
    }
    return $h;
}

# destroy and undef emitter
sub DESTROY {
    my $self = shift;

    if (defined $self->{emitter}) {
        LWES::destroy_emitter($self->{emitter});
        $self->{emitter} = undef;
    }
}

1;
# vim: set ts=4 sw=2 expandtab:

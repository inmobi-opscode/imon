#
# $Id: AlertBase.pm 5996 2012-03-19 11:59:10Z rengith.j $

package IMON::Sender::AlertBase;

use strict;
use warnings;

use constant DEFAULT_SLEEP_MODULE => 'FileWatcher';

sub new {
   	my ( $obj, %params ) = @_;

	my $class = ref($obj) || $obj;

	my $self = {};

   	bless $self, $class;
   	$self->init(%params);
   	return $self;
}

sub init {
	my ($self, %params) = @_;	
	
    $self->{cfg} = $params{cfg};

    my $sleep_cfg = $self->{cfg}->{sleep} || {};
    $self->init_sleep($sleep_cfg);
}

sub init_sleep {
    my ($self, $params) = @_;

    my $c = (defined $params->{module}) ? $params->{module} : DEFAULT_SLEEP_MODULE;
    $c = "IMON::Sender::Sleep::$c";
    my $m = $c;
    $m =~ s/::/\//g;
    eval { require "$m\.pm" };
    die "Error loading module $m\.pm $@" if ($@);
    $self->{sleep_obj} = $c->new(%{$params});
}

# checks whether the host is inside sleep
# invokes sleep method of corresponding sleep object, which returns 1 or 0
sub isleep {
    my ( $self, %params ) = @_;

    my $ret;
    if(!($ret = $self->{sleep_obj}->isleep(%params))) {
        $self->{error} = $self->{sleep_obj}->error();
        return 0;
    }
    return $ret;
}

sub set_sleep {
    my ( $self, $path, $sleep ) = @_;

    my $ret;
    if(!($ret = $self->{sleep_obj}->set_sleep($path, $sleep))) {
        $self->{error} = $self->{sleep_obj}->error();
        return 0;
    }
    return $ret;
}

#
# interface to expose sleep details of a host
# returns hashref with keys: duration(have been sleeping for), and remaining(remaining seconds for sleeping)
# return 0 if not under sleep  
sub sleep_details {
    my ( $self, $host ) = @_;

    return $self->{sleep_obj}->sleep_details($host);
}

sub error {
    my ( $self ) = @_;

    return $self->{error};
}

sub add_transport {
    my ($self, $transport) = @_;

    @{$self->{transport}} = ref($transport) eq 'ARRAY' ? @{$transport} : ($transport);
}

#
# checks whether given tag matches the tag list in the configuration
# returns 1 on match, 0 on failure
#
sub is_tag_matched {
    my ( $self, %params ) = @_;

    my ( $tag , $src ) = map { $params{$_} } qw(tag source);

    if (defined $tag && defined $src) {
        my $src_cfg = $self->{cfg}->{Sources}->{$src};
        if (ref($src_cfg) eq 'ARRAY' || ref($src_cfg) eq 'HASH')  {
            my @patterns = ref($src_cfg) eq 'ARRAY' ? @{$src_cfg} : keys %{$src_cfg};
            if ( scalar(@patterns) > 0 ) {
                foreach my $str(@patterns) {
                    # regex match: string inside forward slash ( /<string>/ )
                    if ( $str =~ /^\/(.+)\/$/ ) { 
                        return $tag if ( $tag =~ /$1/ );
                    }else {
                        return $tag if ( $tag eq $str );
                    }
                }
            }else {
                return $tag;
            }   
        }else {
            # consider the tag if nothing is specified in the config (default: process all tags)
            return $tag;
        }
    }
    return 0;
}

1;

# vim: set ts=4 sw=2 expandtab:

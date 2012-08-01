#
# $Id: Syslog.pm 5199 2012-02-09 07:26:15Z rengith.j $

package IMON::Sender::Syslog;

use strict;
use warnings;
use Sys::Syslog;
use base 'IMON::Sender::AlertBase';

sub init {
    my ($self, %params) = @_;

    $self->SUPER::init(%params);
    
    $self->{Sources} = $self->{cfg}->{Sources};
    $self->init_logger($params{logger});
}

sub init_logger {
    my ( $self , $opts ) = @_;

    $opts ||= {};
    # syslog options
    my $ident   = $opts->{ident} || 'imon';
    my $logopt  = $opts->{logopt} || 'pid,perror';
    my $facility= $opts->{facility} || 'user';

    openlog( $ident, $logopt, $facility );
}

sub send_data {
    my $self = shift;

    while(1) {
        foreach my $t(@{$self->{transport}}) {
            map {
                $self->logit($_); 
            } $t->pull_data();
        }
        sleep 1; # to avoid cpu cycles
    }
}

sub logit {
    my ( $self, $data ) = @_;

    my ( $host, $type, $src, $pivot ) = map { delete $data->{$_} } qw(Hostname Type Source pivot);

    return if (!defined $data->{tags}); # skip if not tags found

    foreach my $t(keys %{$data->{tags}}) {
        # proceed if src/tag already matched, else do a is_tag_match (only once for an instance for a src/tag) and proceed
        if ( !$self->{found}->{$src}->{$t} ) {
            $self->{found}->{$src}->{$t}++ if ($self->is_tag_matched(tag => $t, source => $src))
        }
        next if (!$self->{found}->{$src}->{$t}); # skip if tag not found
        # info log with '<pivot> <source> <tag> <tag_value>' format
        syslog("info", "$pivot $src $t $data->{tags}->{$t}") if (defined $data->{tags}->{$t});
    }
}

1;

# vim: set ts=4 sw=2 expandtab:

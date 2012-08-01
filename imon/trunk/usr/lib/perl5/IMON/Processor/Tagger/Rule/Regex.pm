#
# $Id: Regex.pm 5187 2012-02-09 04:09:00Z rengith.j $

package IMON::Processor::Tagger::Rule::Regex;
use base 'IMON::Processor::Tagger::Rule::Base';

use strict;
use warnings;

sub name {
    my $self = shift;

    return $self->{name};
}

sub short_name {
    my $self = shift;

    return $self->{name};
}

sub init {
    my ($self, %params) = @_;

    $self->SUPER::init(%params);
    $self->{name} = 'Regex';
    $self->{regex} = $params{cfg}->{Regex};
    $self->{regex} =~ s/^\///;
    $self->{regex} =~ s/\/$//;
}

sub update {
    my ($self, $val) = @_;

    my $r = $self->{regex};
    if ($val =~ /$r/) {
        $self->{value} = $r; # update value with the match
        push @{$self->{matched_values}}, $val; # update the matched value
        $self->set_metadata();
    }
}

1;
# vim: set sw=2 ts=4 expandtab:

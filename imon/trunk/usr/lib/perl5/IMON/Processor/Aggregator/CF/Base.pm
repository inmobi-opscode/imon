#
# $Id: Base.pm 4403 2011-12-07 11:43:58Z rengith $

package IMON::Processor::Aggregator::CF::Base;

use strict;
use warnings;

sub new {
    my ( $obj, %params ) = @_;

    my $class = ref($obj) || $obj;

    my $self = {};

    bless $self, $class;
    $self->init(%params);
    return $self;
}

sub init {
    my ( $self, %params ) = @_;

    $self->{cfg} = $params{cfg} if ($params{cfg});
    $self->{value} = undef;
}

# should override
sub update {
    my ($self, $val) = @_;

}

sub retrieve {
    my $self = shift;

    #return $self->{value};
    return wantarray ? ( $self->{value}, $self->{matched_values} ) : $self->{value};
}

sub reset {
    my $self = shift;

    $self->{value} = undef;
}

1;
# vim: set sw=2 ts=4 expandtab:

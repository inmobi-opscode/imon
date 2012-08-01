#
# $Id: Last.pm 4403 2011-12-07 11:43:58Z rengith $

package IMON::Processor::Aggregator::CF::Last;
use base 'IMON::Processor::Aggregator::CF::Base';

sub name {
    my $self = shift;

    return 'Last';
}

sub short_name {
    my $self = shift;

    return 'l';
}

sub update {
    my ($self, $val) = @_;
    
    $self->{value} = $val;
}

1;
# vim: set sw=2 ts=4 expandtab:

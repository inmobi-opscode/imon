#
# $Id: Count.pm 4403 2011-12-07 11:43:58Z rengith $

package IMON::Processor::Aggregator::CF::Count;
use base 'IMON::Processor::Aggregator::CF::Base';

sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params);
    $self->{value} = 0; 
}

sub name {
    my $self = shift;

    return 'Count';
}

sub short_name {
    my $self = shift;

    return 'ct';
}

sub update {
    my ($self, $val) = @_;
    
    $self->{value}++;
}

sub reset {
    my $self = shift;

    $self->{value} = 0;
}

1;
# vim: set sw=2 ts=4 expandtab:

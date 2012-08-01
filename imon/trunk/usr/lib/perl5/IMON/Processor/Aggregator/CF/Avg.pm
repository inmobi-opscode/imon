#
# $Id: Avg.pm 4403 2011-12-07 11:43:58Z rengith $

package IMON::Processor::Aggregator::CF::Avg;
use base 'IMON::Processor::Aggregator::CF::Base';
use List::Util qw(sum);

sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params);
    $self->{value} = [];
}

sub name {
    my $self = shift;

    return 'Avg';
}

sub short_name {
    my $self = shift;

    return 'a';
}

sub update {
    my ($self, $val) = @_;
    
    push @{$self->{value}}, $val;
}

sub retrieve {
    my $self = shift;

    my @all = @{$self->{value}};
    if (@all) {
        return sum(@all)/@all;
    }else {
        return undef;
    }
}

sub reset {
    my $self = shift;

    $self->{value} = [];
}

1;
# vim: set sw=2 ts=4 expandtab:

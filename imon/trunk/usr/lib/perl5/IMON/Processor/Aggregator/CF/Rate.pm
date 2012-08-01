#
# $Id: Rate.pm 4831 2012-01-18 07:17:35Z rengith.j $

package IMON::Processor::Aggregator::CF::Rate;
use base 'IMON::Processor::Aggregator::CF::Base';

sub name {
    my $self = shift;

    return 'Rate';
}

sub short_name {
    my $self = shift;

    return 'r';
}

sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params);

    $self->{prev_value} = undef;
    $self->{threshold} = $self->{cfg}->{Rate};
}

#
# update the Rate of change of current value from the previous value
# set to undef if previous is greater than current or absence of previous value
#
sub update {
    my ($self, $val) = @_;
    
    if (defined $val) {
        if (defined $self->{prev_value}) {
            # we can't have negative values in counter, set the value to undef if previous value is greater than current value
            if ($val >= ($self->{prev_value} + $self->{threshold}) ) {
                $self->{value} = $val - $self->{prev_value};
            }elsif($self->{prev_value} > $val) {
                $self->{value} = undef;
            }
        }else {
            $self->{value} = undef; 
        }
        push @{$self->{matched_values}}, $val;
    }else {
        $self->{value} = undef;
    }
}

#
# reset the value with preserving the previous value
#
sub reset {
    my $self = shift;

    my $vals;
    (undef, $vals, undef)  = $self->retrieve();
    $self->{prev_value} = scalar(@{$vals}) > 0 ? $vals->[-1] : undef;

    $self->SUPER::reset();
}

1;
# vim: set sw=2 ts=4 expandtab:

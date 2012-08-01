#
# $Id: Range.pm 4403 2011-12-07 11:43:58Z rengith $

package IMON::Processor::Aggregator::CF::Range;
use base 'IMON::Processor::Aggregator::CF::Base';

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
    $self->{value} = 0;
    my $r = $params{cfg}->{Range};
    $self->{name} = $r;

    # closure to handle range evaluation
    if ($r =~ /^(\d+)-(\d+)$/) {
        $self->{start} = $1;
        $self->{end}   = $2;
        $self->{coderef} = sub { 
                                my $val = shift;
                                return 1 if (($val >= $self->{start}) && ($val <= $self->{end}));
                                return 0;
                          }; 
    } elsif ($r =~/^>(\d+)$/) {
        $self->{start} = $1;
        $self->{coderef} = sub { 
                                my $val = shift; 
                                return 1 if ( $val > $self->{start} );
                                return 0;
                          };
    } elsif ($r =~/^>=(\d+)$/) {
        $self->{start} = $1;
        $self->{coderef} = sub { 
                                my $val = shift; 
                                return 1 if ( $val >= $self->{start} );
                                return 0;
                          };
    } elsif ($r =~/^<(\d+)$/) {
        $self->{end}   = $1;
        $self->{coderef} = sub { 
                                my $val = shift; 
                                return 1 if ( $val < $self->{end} );
                                return 0;
                          };
    } elsif ($r =~/^<=(\d+)$/) {
        $self->{end}   = $1;
        $self->{coderef} = sub { 
                                my $val = shift; 
                                return 1 if ( $val <= $self->{end} );
                                return 0;
                          };
    } elsif ($r =~/^=(\d+(?:\.\d+)?)$/) { # '=number'
        $self->{number}   = $1;
        $self->{coderef} = sub { 
                                my $val = shift; 
                                return 1 if ( $val == $self->{number} );
                                return 0;
                          };
        
    }
}

sub update {
    my ($self, $val) = @_;

    if ( $self->{coderef}->($val) ) {
        $self->{value}++; # update the count
    }
}

sub reset {
    my $self = shift;

    $self->{value} = 0;
}

1;
# vim: set sw=2 ts=4 expandtab:

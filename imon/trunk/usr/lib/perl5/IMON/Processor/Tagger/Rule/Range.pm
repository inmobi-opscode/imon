#
# $Id: Range.pm 4906 2012-01-24 12:09:45Z rengith.j $

package IMON::Processor::Tagger::Rule::Range;
use base 'IMON::Processor::Tagger::Rule::Base';

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
        $self->{value} = $val; # update the value
        push @{$self->{matched_values}}, $val; # update the matched value
        $self->set_metadata();
    }
}

1;
# vim: set sw=2 ts=4 expandtab:

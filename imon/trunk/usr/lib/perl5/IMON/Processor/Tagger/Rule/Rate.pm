#
# $Id: Rate.pm 5271 2012-02-13 05:11:19Z rengith.j $

package IMON::Processor::Tagger::Rule::Rate;
use base 'IMON::Processor::Tagger::Rule::Base';

use strict;
use warnings;
use Time::HiRes qw( gettimeofday );
use constant DEFAULT_RATE_INTERVAL => 60;

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

    $self->{interval} = delete $self->{cfg}->{interval} || DEFAULT_RATE_INTERVAL;

    if ( my $e = $self->{cfg}->{expr} ) {
        # expects exactly 2 keys '<expr>' and 'ds'
        if (keys %{$e} != 2 || !$e->{ds}) {
            die "Bad config for expr(ds and expression key is expected or mismatch in the number of keys)";
        }
        $self->{ds} = delete $e->{ds}; 
        ($self->{expr}) = keys %{$e}; # 'expr': 'range', ex: '(x + y)/2': '>10'
        # create expr object with the required ds info
        $self->{exp_obj} = $self->init_obj(rule => 'Math', cfg => {expr => $self->{expr}, ds => $self->{ds}});
        $self->{range_obj} = $self->init_obj(rule => 'Range', cfg => {Range => $e->{$self->{expr}}}); # storing range object
    }else { 
        # expects exactly 1 key (metric_name) in addition to interval(optional)
        if (keys %{$self->{cfg}} != 1) {
            die "Bad config for Rate rule, only one metric is expected";
        }
        ($self->{key}) = keys %{$self->{cfg}}; # consider only one metric
        my $r = $self->{cfg}->{$self->{key}};
        $self->{range_obj} = $self->init_obj(rule => 'Range', cfg => {Range => $r}); # storing range object
    }

    $self->{last_time} = ( gettimeofday )[0];
    $self->{prev_value} = undef;
}

# initializing rule object
sub init_obj {
    my ($self, %params) = @_;

    my $r = $params{rule};
    my $class = "IMON::Processor::Tagger::Rule::$r";
    eval { require "IMON/Processor/Tagger/Rule/$r\.pm"; };
    die "Unable to invoke $r, Error: $@" if $@;

    return $class->new(cfg => $params{cfg});
}

#
# update the Rate of change of current value from the previous value
# set to undef if previous is greater than current or absence of previous value
#
sub update {
    my ($self, $val) = @_;
    
    my $now = ( gettimeofday )[0];
    
    # get current value (apply expr if needed)
    my $cur_val;
    if (defined $self->{expr}) {
        $self->{exp_obj}->update($val);
        $cur_val = $self->{exp_obj}->retrieve();
        $self->{exp_obj}->reset();
    }else {
        $cur_val = $val->{$self->{key}};
    }
    return if (!defined $cur_val);
    if (defined $self->{prev_value}) {
        if ( $now >= ( $self->{last_time} + $self->{interval} ) ) {
            my $diff = $cur_val - $self->{prev_value};
            if ($diff >= 0) { # applying range if diff is a positive value
                $self->{range_obj}->update($diff);
                $self->{value} = $diff if ($self->{range_obj}->retrieve());
                $self->{range_obj}->reset();
            }
            $self->{prev_value} = $cur_val; # assigning current value to prev_value as the interval is over
        }
    }else {
        $self->{prev_value} = $cur_val;
    }

    if ( $now >= ( $self->{last_time} + $self->{interval} ) ) {
        $self->{last_time} = $now;
    }
}

1;
# vim: set sw=2 ts=4 expandtab:

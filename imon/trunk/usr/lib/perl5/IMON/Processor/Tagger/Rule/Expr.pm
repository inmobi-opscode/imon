#
# $Id$

package IMON::Processor::Tagger::Rule::Expr;
use base 'IMON::Processor::Tagger::Rule::Base';

use strict;
use warnings;

sub name {
    my $self = shift;

    return 'Expr';
}

sub short_name {
    my $self = shift;

    return 'e';
}

sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params);

    my $e = $self->{cfg};
    # expects exactly 2 keys '<expr>' and 'ds'
    if (keys %{$e} != 2 || !$e->{ds}) {
      die "Bad config for Expr(ds and expression key is expected or mismatch in the number of keys)";
    }
    $self->{ds} = delete $e->{ds}; 
    ($self->{expr}) = keys %{$e}; # 'expr': 'range', ex: '(x + y)/2': '>10'
    # create expr object with the required ds info
    $self->{exp} = $self->init_obj(rule => 'Math', cfg => {expr => $self->{expr}, ds => $self->{ds}});
    $self->{range} = $self->init_obj(rule => 'Range', cfg => {Range => $e->{$self->{expr}}}); # storing range object
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
    
    if (defined $val && $self->{exp}) {
        # evaluate the expression and get it in $ret
        $self->{exp}->update($val);
        my $ret = $self->{exp}->retrieve();
        $self->{exp}->reset();
        # checks $ret against range(apply Range rule) and set the value if matched
        if (defined $ret) {
            $self->{range}->update($ret);
            if (defined $self->{range}->retrieve()) {
                # round of decimal value to 3 points
                $self->{value} = ($ret =~ /\.\d{4,}/) ? sprintf("%0.3f", $ret) : $ret;
            }
            $self->{range}->reset();
        }
    }
}

1;
# vim: set sw=2 ts=4 expandtab:

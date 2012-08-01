#
# $Id$

package IMON::Processor::Tagger::Rule::Math;

use strict;
use warnings;
use Math::Calculus::Expression;
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

    ($self->{expr}, $self->{ds}) = map { $self->{cfg}->{$_} } qw(expr ds);

    $self->init_exp();
}

sub init_exp {
    my $self = shift;
    
    my $ds = $self->{ds};
    my $expr = $self->{expr};

    # Create an expression object.
    $self->{e} = Math::Calculus::Expression->new;

    # add variables needed for expression
    # has to a single alphabet, hence need mapping against ds's
    # 
    my @map = split(//,'abcdefghijklmnopqrstuvwxyz'); 
    foreach(0 .. scalar(@{$ds}) - 1) {
        $self->{map}->{$ds->[$_]} = $map[$_];
        $self->{e}->addVariable("$map[$_]");
    }    

    # map ds's with alphabets and set expression 
    foreach my $m(keys %{$self->{map}}) {
        my $r = $self->{map}->{$m};
        $expr =~ s/(?!<[a-zA-Z])$m(?![a-zA-Z])/$r/g;
    }
    $self->{e}->setExpression("$expr") or die "Error in expr: " .  $self->{e}->getError;
}

sub update {
    my ($self, $val) = @_;

    my %m;

    foreach (@{$self->{ds}}) {
        return if (!defined $val->{$_});
        $m{$self->{map}->{$_}} = $val->{$_};
    }
    $self->{value} = $self->{e}->evaluate(%m);
}

1;
# vim: set sw=2 ts=4 expandtab:

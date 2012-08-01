#
# $Id: Base.pm 4878 2012-01-23 11:50:55Z rengith.j $

package IMON::Processor::Tagger::Rule::Base;

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
    $self->{matched_values} = [];
    $self->{metadata} = undef;

    # shared subs
    map { $self->{subs}->{$_} = $params{subs}->{$_} } keys %{$params{subs}} if ($params{subs});
}

# should override
sub update {
    my ($self, $val) = @_;

}

sub retrieve {
    my $self = shift;

    # returns 
    # scalar context: result
    # list context: reference to an array contains the elements which marches the cf
    return wantarray ? ( $self->{value}, $self->{matched_values}, $self->{metadata} ) : $self->{value};
}

sub set_metadata {
    my $self = shift;

    $self->{metadata} = $self->{subs}->{get_data}->() if ($self->{subs}  && $self->{subs}->{get_data});
}

sub reset {
    my $self = shift;

    $self->{value} = undef;
    $self->{matched_values} = [];
    $self->{metadata} = undef;
}

1;
# vim: set sw=2 ts=4 expandtab:

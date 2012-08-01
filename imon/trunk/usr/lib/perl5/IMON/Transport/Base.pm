#
# $Id: Base.pm 3493 2011-09-21 06:03:20Z rengith $

package IMON::Transport::Base;

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
	my ($self, %params) = @_;	
	
}

sub push_data {
    my $self = shift;	

    # defaults to no-op
}

sub pull_data {
    my $self = shift;

    # defaults to no-op
}

sub error {
    my $self = shift;

    return $self->{error};
}

1;
# vim: set ts=4 sw=2 expandtab:

#
# $Id: Base.pm 3919 2011-10-28 04:23:25Z rengith $

package IMON::Sender::Base;

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
	
    $self->{cfg} = $params{cfg};
}

# Need to override this
sub send_data {
    my ( $self ) = @_;

}

sub add_transport {
    my ($self, $transport) = @_;

    @{$self->{transport}} = ref($transport) eq 'ARRAY' ? @{$transport} : ($transport); 
}

sub error {
    my ( $self ) = @_;

    return $self->{error};
}

1;

# vim: set ts=4 sw=2 expandtab:

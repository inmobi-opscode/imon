#
# $Id: Dump.pm 3537 2011-09-23 07:25:48Z rengith $

package IMON::Sender::Dump;

use strict;
use warnings;
use Data::Dumper;
use base 'IMON::Sender::Base';

sub send_data {
    my $self = shift;

    while(1) {
        foreach my $t(@{$self->{transport}}) {
            map {
                print Dumper $_; 
            } $t->pull_data();
        }
        sleep 1;
    }
}

1;

# vim: set ts=4 sw=2 expandtab:

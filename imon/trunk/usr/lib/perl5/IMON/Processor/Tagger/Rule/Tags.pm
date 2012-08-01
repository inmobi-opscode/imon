#
# $Id: Tags.pm 5154 2012-02-08 06:48:05Z rengith.j $

package IMON::Processor::Tagger::Rule::Tags;
use base 'IMON::Processor::Tagger::Rule::Base';

use strict;
use warnings;

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
    $self->{name} = 'Tags';

    if (ref($self->{cfg}) eq 'HASH') { # Handling AND condition for Tags
        foreach my $k(keys %{$self->{cfg}}) {
            push @{$self->{objects}}, $self->{subs}->{rules}->(source => $params{source}, tag => $params{tag}, config => { $k => $self->{cfg}->{$k} });
        }
    }elsif (ref($self->{cfg}) eq 'ARRAY') {
        push @{$self->{objects}}, $self->{subs}->{rules}->(source => $params{source}, tag => $params{tag}, config => $self->{cfg});
        $self->{tags_list} = $self->{cfg};
    }
}

# do update on all the list of objects, retrieve data and increment value if all returns some non-zero value
sub update {
    my ($self, $val) = @_;

    my @data;
    my $i = 0;
    foreach (@{$self->{objects}}) {
        my $child_tag;
        if ( ref($self->{tags_list}) eq 'ARRAY' && defined $self->{tags_list}->[$i] && !ref($self->{tags_list}->[$i]) ) {
            $child_tag = $self->{tags_list}->[$i];
        }
        if (ref($_) eq 'HASH') {
            my $dh = {};
            foreach my $k(keys %{$_}) {
                $_->{$k}->update($val->{$k});
                my $d = $_->{$k}->retrieve();
                $dh->{$k} = $d if (defined $d);
                $_->{$k}->reset();
            }
            if (keys %{$dh}) {
                my $r = join('; ', map { "$_\=$dh->{$_}" } keys (%{$dh}) );
                $r = "$child_tag\:$r" if (defined $child_tag);
                push @data, $r;
            }
        }elsif (ref($_) eq 'ARRAY') {
            my @darr;
            foreach my $obj (@{$_}) {
                $obj->update($val);
                my $d = $obj->retrieve();
                push @darr, $d;    
            }
            if (@darr) {
                my $r = join('; ', @darr);
                push @data, (defined $child_tag) ? "$child_tag\:$r" : $r;
            }
        }else { 
            $_->update($val);
            if (my $d = $_->retrieve()) {
                push @data, (defined $child_tag) ? "$child_tag\:$d" : $d;
            }
            $_->reset();
        }
        last if (@data); # OR relationship, hence can stop at first match
        $i++;
    }
    if (scalar(@data) > 0) { # set value if any one rules matches
        $self->{value} = join('; ', @data);
    }
}

1;
# vim: set sw=2 ts=4 expandtab:

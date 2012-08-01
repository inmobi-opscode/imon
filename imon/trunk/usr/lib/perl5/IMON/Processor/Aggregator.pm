#
# $Id: Aggregator.pm 5914 2012-03-14 07:38:45Z rengith.j $

package IMON::Processor::Aggregator;
use strict;
use warnings;
use Clone qw(clone);

use base 'IMON::Processor::Base';

sub init {
    my ($self, %params) = @_;

    $self->SUPER::init(%params);
    $self->{interval} = $self->{cfg}->{interval};
    $self->{nr_dequeue} = $self->{cfg}->{nr_dequeue} || 1;
    $self->{comp_sleep_factor} = $self->{cfg}->{comp_sleep_factor} || 5;
    $self->{comp_sleep} = $self->{cfg}->{comp_sleep} || ($self->{interval} <= $self->{comp_sleep_factor} ? 1 : $self->{interval}/$self->{comp_sleep_factor});
    $self->{sep} = '::';
    $self->{pivots} = $self->{cfg}->{pivot} || { 'default' => [] };
    $self->{default_pivot} = $self->{cfg}->{default_pivot};

    $self->{Type} = 'Aggregated';
    $self->init_cf();
    $self->{events_count} = 0; # to keep track of the number of events processed
}

sub init_cf {
    my $self = shift;

    my $rules = $self->{cfg}->{rules};
    foreach my $k(keys %{$rules}) {
        map {
            if (!ref($_)) {
                my $class = "IMON::Processor::Aggregator::CF::$_";
                eval { require "IMON/Processor/Aggregator/CF/$_\.pm"; };
                die "Unable to invoke Consolidation Function module $_, Error: $@" if $@;
                push @{$self->{cf}->{$k}}, $class->new();
            }elsif ( ref($_) eq 'HASH')  {
                foreach my $f(keys %{$_}) {
                    my $class = "IMON::Processor::Aggregator::CF::$f";
                    eval { require "IMON/Processor/Aggregator/CF/$f\.pm"; };
                    die "Unable to invoke Consolidation Function module $f, Error: $@" if $@;
                    push @{$self->{cf}->{$k}}, $class->new(cfg => $_);
                }
            }

        } @{$rules->{$k}->{cf}};
    }
}

sub process {
	my $self = shift;

    # set SIGALRM and notify at every 'interval' seconds set in the conf
    $self->set_alarm_and_notify();
    
	while(1) {
        foreach my $t(@{$self->{transport}->{in}}) {
            map {
                $self->signal_safe_call(\&compute, $self, $_);
            } $t->pull_data();
        }
        sleep $self->{comp_sleep};
	}
}

sub compute {
    my ($self, $value_hash) = @_;

    my @pivots;
    foreach my $p( keys %{$self->{pivots}} ) {
        if (my @missing = grep { !defined($value_hash->{$_}) } (@{$self->{pivots}->{$p}}, $self->{default_pivot} || 'Hostname')) {
                # Below satement will be uncommented as and when debug options are introduced. just skipping the event as of now
                #print "No value found for pivot ", join(',',@missing), " (EventType: $value_hash->{EventType}; SenderIP: $value_hash->{SenderIP};) skipping..\n";
                next;
        }
        my $pivot;
        if (@{$self->{pivots}->{$p}}) {
            my @pivot_values = map { $value_hash->{$_} } @{$self->{pivots}->{$p}};
            my $pivotval = join($self->{sep}, @pivot_values);
            $pivot = $self->{default_pivot} ? join($self->{sep}, $pivotval, $value_hash->{$self->{default_pivot}}) : "${pivotval}$self->{sep}$value_hash->{Hostname}";
            $self->{result}->{$pivot}->{pivot_key} = join(',', @{$self->{pivots}->{$p}});
            $self->{result}->{$pivot}->{pivot_value} = $pivotval;
        }else {
            $pivot = $self->{default_pivot} ? $value_hash->{$self->{default_pivot}} : $value_hash->{Hostname};
        }
   
        $self->{result}->{$pivot}->{pivot_label} = $p;

        foreach ( qw/SenderIP SenderPort env Hostname prog_id Source/ ) {
            $self->{result}->{$pivot}->{$_} ||= $value_hash->{$_} if(defined $value_hash->{$_});
        }
        $self->{result}->{$pivot}->{Type} = $self->{Type};
        $self->{result}->{$pivot}->{default_pivot} = $value_hash->{$self->{default_pivot}} if defined($self->{default_pivot});

        push @pivots, $pivot;
    }

    foreach my $pivot(@pivots) {
        foreach my $k(keys %{$self->{cf}}) {
            next if (!defined($value_hash->{$k}));
            $self->{res}->{$pivot}->{$k} ||= clone ($self->{cf}->{$k});
            foreach( @{$self->{res}->{$pivot}->{$k}} ) {
                $_->update($value_hash->{$k});
            }
        }
    }
    $self->{events_count}++;
}

sub set_alarm {
    my $self = shift;

    $SIG{ALRM} = sub {
                        # XXX If another sig alarm comes if this one is going on, handle that cleanly
                        foreach my $t(@{$self->{transport}->{in}}) {
                            map {
                                $self->compute($_);
                            } $t->pull_data();
                        }
                        
                        if ($self->{events_count}) {
                            print "Processed $self->{events_count} events, pushing data to transport\n";
                            foreach my $p(keys %{$self->{res}}) {
                                $self->retrieve_data($p);
                                $self->{result}->{$p}->{sep} = $self->{sep};
                                $self->push_to_transport($self->{result}->{$p});
                            }
                            $self->{events_count} = 0; # resetting the events count
                        }
                };
}

sub retrieve_data {
    my ($self, $p) = @_;

    foreach my $k(keys %{$self->{res}->{$p}}) {
        if (ref($self->{res}->{$p}->{$k}) eq 'ARRAY' ) {
            foreach( @{$self->{res}->{$p}->{$k}} ) {
                my $name = $_->short_name();
                my $r = $_->retrieve();
                $self->{result}->{$p}->{"$k$self->{sep}$name"} = $r; 
                $_->reset();
            }
        }
    }
}

1;

# vim: set sw=2 ts=4 expandtab:

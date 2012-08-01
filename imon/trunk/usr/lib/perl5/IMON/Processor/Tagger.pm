#
# $Id: Tagger.pm 4265 2011-11-24 12:48:45Z rengith $

=head1 NAME
 
 Tagger: IMon Tagger module for Tagging based on rules

=head1 AUTHOR

 Rengith Jerome <rengith.j@inmobi.com>
=cut
package IMON::Processor::Tagger;
use strict;
use warnings;

use Clone qw(clone);
use base 'IMON::Processor::Base';

use constant DEFAULT_PIVOT  => 'Hostname';

# overriding init to add Tagged Falg
sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params);

    $self->{Type} = 'Tagged'; # Setting Type to Tagged
    $self->init_rule();
}

# initializing rules
#
sub init_rule {
    my $self = shift;

    $self->{rules} = $self->{cfg}->{rules};
  
    $self->is_config_valid($self->{rules}) or return;
    
    foreach my $src(keys %{$self->{rules}}) {
        $self->{$src}->{pivot_key} = $self->{rules}->{$src}->{pivot} || DEFAULT_PIVOT;
        foreach my $tag(keys %{$self->{rules}->{$src}->{tags}}) {
            my $cfg = $self->{rules}->{$src}->{tags}->{$tag};
            # List of primitive rules metric_name/rules_details
            if ( ref($cfg) eq 'ARRAY' ) {
                $self->{rule}->{$src}->{$tag} = $self->rules(source => $src, tag => $tag, config => $cfg);
            # else it'll be a HASH with Rule name as key and its config as value
            }elsif ( ref($cfg) eq 'HASH' ) {
                foreach my $rule(keys %{$cfg}) {
                    push @{$self->{rule}->{$src}->{$tag}}, $self->init_obj(rule => $rule, cfg => $cfg->{$rule}, source => $src, tag => $tag, subs => $self->export_subs() );
                }
            }else {
                $self->{error} = "error in config for tag $src\::$tag, refernce to ARRAY or HASH expected";
                return;
            }
        }
    }
}

#
# is_config_valid checks whether the configuration is valid, else return set error and false (0)
#
sub is_config_valid {
    my ($self, $conf) = @_;

    foreach my $src(keys %{$conf}) {
        foreach my $tag(keys %{$conf->{$src}->{tags}}) {
            my $cfg = $conf->{$src}->{tags}->{$tag};
            if (ref($cfg) eq 'ARRAY') {
                foreach my $r(@{$cfg}) {
                    if ( !ref($r) || (ref($r) && ref($r) ne 'HASH') ) {
                        $self->{error} = "Bad config for tag $src\::$tag";
                        return 0;
                    }elsif( ref($r) && ref($r) eq 'HASH' ) {
                        foreach my $k(keys %{$r}) {
                            if (ref($r->{$k})) {
                                $self->{error} = "Bad config for tag $src\::$tag";
                                return 0;
                            }
                        }
                    }
                }
            }elsif( ref($cfg) ne 'HASH' ) {
                $self->{error} = "Bad config for tag $src\::$tag, refernce to an ARRAY or HASH expected";
                return 0;
            }
        }
    }
    return 1;
}

#
# require rule class and return the instance of it
#
sub init_obj {
    my ( $self, %params ) = @_;

    my ( $rule, $cfg, $src, $tag, $subs ) = map { $params{$_} } qw(rule cfg source tag subs);

    my $class = "IMON::Processor::Tagger::Rule::$rule";
    eval { require "IMON/Processor/Tagger/Rule/$rule\.pm"; };
    die "Unable to invoke rule module $rule, Error: $@" if $@;

    return $class->new(cfg => $cfg, source => $src, tag => $tag, subs => $subs);
}

#
# Methods passed to the Rule's (as coderef). These methods can be used in the Rule class if required
#
sub export_subs {
    my $self = shift;

    return { rules      => sub { $self->rules(@_) },
             init_obj   => sub { $self->init_obj(@_) },
             rule       => sub { $self->rule(@_) },
             get_data   => sub { $self->get_data(@_) }
           };

}

#
# Rules method to invoke the rule objects
#
sub rules {
    my ( $self, %param ) = @_;

    my ( $cfg, $s, $tag ) = map { $param{$_} } qw(config source tag);

    my $o = {};
    my @objs;
    if (ref($cfg) eq 'ARRAY') {
        foreach my $rule(@{$cfg}) {
            if ( ref($rule) eq 'HASH' ) {
                # primitive rules with k/v  (eq: - cpu: '>70')
                foreach my $k(keys %{$rule}) {
                    if ( !ref($rule->{$k}) ) {
                        my $r = $self->rule($rule->{$k});
                        $o->{$k} = $self->init_obj(rule => $r, source => $s, tag => $tag, cfg => { $r => $rule->{$k} }, subs => $self->export_subs() );
                    }else {
                        die "Error in Tagger config at source $s ($k : $rule->{$k})";
                    }
                }
            }elsif ( !ref($rule) ) {
                if ($self->{rules}->{$s}->{tags}->{$rule} && ( $tag ne $rule )) {
                    my $cfg = $self->{rules}->{$s}->{tags}->{$rule};
                    push @objs, $self->rules(tag => $tag, source => $s, config => $cfg);
                }else {
                    die "Error in Tagger Config: Bad reference $tag to tag '$rule' for source '$s'";
                }
            }else {
                die "Error in Tagger config for tag '$s\::$tag', found " . ref($rule) . " type where refernce to HASH or SCALAR expected";
            }
        }
    }elsif(ref($cfg) eq 'HASH') {
        foreach my $k(keys %{$cfg}) {
            push @objs, $self->init_obj(rule => $k, cfg => $cfg->{$k}, source => $s, tag => $tag, subs => $self->export_subs() )
        }
    }else {
        die "Error in config at source $s ($cfg)";
    }
    return @objs ? @objs : $o;
}

#
# which rule to be invoked (Assumptions need to be documented)
# Need to Abstract this away and provide an interface which has the rule derivation
# /someRegex/ => Regex
# Range if \d-\d =\d >|<\d pattern
# returns $str if none of the above matches 
#

sub rule {
    my ( $self, $str ) = @_;

    if ( $str =~ /^\/.+\/$/ ) {
        return 'Regex';
    }elsif ( $str =~ /(?:>|<)=?\d|=\d|\d\-\d/ ) {
        return 'Range';
    }
    return $str;
}

#
# process method which run as a thread
# Sets ALRM based on interval and pull data from the incoming transport and send it for Tagging/Computation
#
sub process {
	my $self = shift;

	while(1) {
        foreach my $t(@{$self->{transport}->{in}}) {
            map {
                $self->compute($_);
                $self->send_data();
            } $t->pull_data();
        }
        sleep 1; # to avoid cpu cycles
	}
}

# 
# call update on all the rule objects for each sources
# 
sub compute {
    my ($self, $value_hash) = @_;

    my ( $source, $event_key, $eventId );
    $source = $value_hash->{Source}; 
    $event_key = $self->{$source}->{pivot_key};

    defined($value_hash->{$event_key}) ? $eventId = $value_hash->{$event_key} : return; # skip the event if event_key value not found

    foreach ( qw/Hostname Source/ ) {
        $self->{result}->{$source}->{$eventId}->{$_} ||= $value_hash->{$_} if(defined $value_hash->{$_});
    }
    $self->{result}->{$source}->{$eventId}->{Type} = $self->{Type};
    $self->{result}->{$source}->{$eventId}->{pivot_key} = $event_key;
    $self->{result}->{$source}->{$eventId}->{pivot} = $eventId;

    $self->{data} = $value_hash;

    foreach my $t(keys %{$self->{rule}->{$source}}) {
        # key/value corresponds to metric_name/rule_object and pass the corresponding value for the metric name
        if (ref($self->{rule}->{$source}->{$t}) eq 'HASH') {
            foreach my $k(keys %{$self->{rule}->{$source}->{$t}}) {
                $self->{res}->{$source}->{$eventId}->{$t}->{$k} ||= clone $self->{rule}->{$source}->{$t}->{$k};
                my $obj = $self->{res}->{$source}->{$eventId}->{$t}->{$k};
                $obj->update($value_hash->{$k});
            }
        # call update for all the rule objects in the array
        }elsif(ref($self->{rule}->{$source}->{$t}) eq 'ARRAY') {
            foreach (0 .. @{$self->{rule}->{$source}->{$t}} - 1) {
                my $obj;
                if (!$self->{objects}->{$source}->{$eventId}->{$t}->{$_}) {
                    $obj = $self->{objects}->{$source}->{$eventId}->{$t}->{$_} ||= clone $self->{rule}->{$source}->{$t}->[$_];
                    push @{$self->{res}->{$source}->{$eventId}->{$t}}, $obj;
                }else {
                    $obj = $self->{objects}->{$source}->{$eventId}->{$t}->{$_};
                }
                $obj->update($value_hash);  # need to pass the entire hash since the rules objects need multiple metrics
            }
        }
    }
}

#
# to expose all data corresponding to an event to rule objects
#
sub get_data {
    my $self = shift;
    
    return $self->{data};
}

#
# send the computed result to the transport
#
sub send_data {
    my $self = shift;

    # Get value for each Tag for all the Sources and interpolate the comment with returned data
    # Then, push the result to the transport
    foreach my $source(keys %{$self->{res}}) {
        $self->retrieve_data($source);
        foreach my $Id(keys %{$self->{result}->{$source}}) {
            my $tags = $self->{result}->{$source}->{$Id};
            $self->push_to_transport($tags) if (keys %{$tags->{tags}});
        }
    }
}

#
# For all the Tags in a source, get the result (retrieve method of the rule object)
# Then, interpolate the comments(if any) with the corresponding result variables (replace %{var_name} in the comment)
# Finally reset all the rule objects values
# Assumption: 
#   %%          : placeholder for return value of the rule
#   %{var_name} : placeholder for a variable
#
sub retrieve_data {
    my ($self, $source) = @_;
    
    foreach my $eventId(keys %{$self->{res}->{$source}}) {
        $self->{result}->{$source}->{$eventId}->{tags} = {}; # undef tags for each Id to avoid sending the previous data
        foreach my $t(keys %{$self->{res}->{$source}->{$eventId}}) {
            my $o = $self->{res}->{$source}->{$eventId}->{$t};
            my @r;
            if( ref($o) eq 'HASH' ) {
                foreach my $key( keys %{$o} ) {
                    my $obj = $o->{$key};
                    my $data = $obj->retrieve();
                    push @r, "$key\:" . $data if (defined $data);
                    $obj->reset();
                }
            }elsif( ref($o) eq 'ARRAY' ) {
                foreach my $obj(@{$o}) {
                    my $d = $obj->retrieve();
                    push @r, $d if (defined $d);
                    $obj->reset();
                }
            }
            my $d = join(';', @r) if(@r);
            my $e = $self->get_data(); # to get the metrics data point
            if (defined $d) {
                if (my $comment = $self->{rules}->{$source}->{comments}->{$t}) {
                    # %% is the placeholder for return value of retrieve method
                    if ($comment =~ /%/) {
                        if ($comment =~ /%%/) {
                            $comment =~ s/%%/$d/g;
                        }
                        if (my @k = $comment =~ /%\{([^}]+)\}/g ) {
                            foreach (@k) {
                                my $v = $e->{$_};
                                $comment =~ s/%\{$_\}/$v/g if (defined $v);
                            }   
                        }
                    }else { 
                        $comment .= "[ value: $d ]"; 
                    }
                    $self->{result}->{$source}->{$eventId}->{tags}->{$t} = $comment;
                }else {
                    $self->{result}->{$source}->{$eventId}->{tags}->{$t} = $d;
                }
            }
        }
    }
}
1;

# vim: set sw=2 ts=4 expandtab:


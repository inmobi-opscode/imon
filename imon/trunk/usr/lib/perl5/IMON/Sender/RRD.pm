#
#$Id: RRD.pm 4897 2012-01-24 05:21:10Z rengith.j $

package IMON::Sender::RRD;

use strict;
use warnings;
use RRDs;
use File::Spec qw(splitpath catfile rel2abs);
use File::Path qw(make_path);
use base 'IMON::Sender::Base';

use constant DEFAULT_DSTYPE => 'GAUGE';
use constant DS_MAXLEN => 19;

sub init {
    my ( $self, %params ) = @_;

    $self->SUPER::init(%params); 

    map { $self->{$_} = $self->{cfg}->{$_} } qw( datadir ds_type map step rras hb );

    $self->{basedir} = $self->{datadir};

    if ( -d $self->{basedir} && !(-w $self->{basedir}) ){
        $self->{error} = "Directory $self->{basedir} is not writable by the user";
    }elsif ( !(-d $self->{basedir}) ) {
        make_path($self->{basedir}, { error => \my $err });
        if(@$err) {
            $self->{error} = "Unable to create directory '$self->{basedir}': " . join(',', map { $_->{$self->{basedir} } if($_->{$self->{basedir}}) } @$err);
        }
    }
}

sub send_data {
    my $self = shift;

    while(1) {
        foreach my $t(@{$self->{transport}}) {
            map {
                next if $self->skip($_);
                $self->send($_);
            } $t->pull_data();
        }
        sleep 1; # to avoid cpu cycles
    }
}

sub skip {
    my ($self, $data) = @_;

    # skip if below mandatory fields are not defined
    return 1 if (grep { !defined($data->{$_}) } qw(env Type Source Hostname));
    return 0;
}

sub send {
    my ($self, $data) = @_;

    my ( $datadir, $rrd_filename, $valid_data, $sep );

    $datadir = File::Spec->catdir(  $self->{basedir},
                                     defined($data->{env}) ? $self->clean_field($data->{env}) : undef, 
                                     defined($data->{pivot_label}) ? $self->clean_field($data->{pivot_label}) : "default", 
                                     defined($data->{pivot_value}) ? $self->clean_field($data->{pivot_value}) : undef 
                            );
    $sep = $data->{sep};
    $datadir =~ s/(?:$sep)+/_/g;
    $rrd_filename = defined($data->{default_pivot}) ? $self->clean_field($data->{default_pivot}) : $self->clean_field($data->{Hostname});
    if (!defined $rrd_filename) {
        die "Unable to find hostname or default_pivot field, exiting...";
    }
    my $h   = {};
    my $dst = {};
    foreach my $k(keys %{$data}) {
        next if $k =~ /(?:EventType|Type|Source|SenderIP|Hostname|env|prog_id|SenderPort|pivot_key|pivot_value|pivot_label|default_pivot|sep)$|^context\./;
        if($k =~ /^(.+?)$sep(.*)$/) {
            if (defined($self->{map}->{$1})) {
                my $dn = $self->{map}->{$1}."_$2";
                $dst->{$dn} = $self->{ds_type}->{$1}; 
                $h->{$dn} = $data->{$k};
            } else {
                $dst->{$k} = $self->{ds_type}->{$1}; 
                $h->{$k} = $data->{$k};
            }
        }
        $valid_data++ if (defined $data->{$k}); 
    }
    my $file = File::Spec->catfile($datadir, "$rrd_filename\.rrd");
    if ($valid_data) {
        $self->rrdUpdate($file, $h, $dst);
    }else {
        print "No data found to update the rrd file: \"$file\"\n";
    }
}

sub rrdUpdate {
    my ($self, $file, $metrics, $ds_type) = @_; 

    $file = File::Spec->rel2abs($file);
    my ($junk, $dir, $filename) = File::Spec->splitpath($file);
    unless (-d $dir) {
        my $err = [];
        make_path($dir, { error => \$err });
        if (@$err) {
            warn "Directory $dir creation failed, Error: " . join(',', map { $_->{$dir} if ($_->{$dir}) } @$err);
            return;
        }
    }
    my @names = sort(keys %{$metrics});

    my $hb = $self->{hb} || 600;
    my @ds = map { my $dn = $self->def_name($_); my $dst = $ds_type->{$_} || DEFAULT_DSTYPE;  "DS:$dn:$dst:$hb:U:U" } @names;

    unless (-f $file) {
        # DS names check against MAXLEN
        my @ds_invalid;
        foreach ( map { /DS:([^:]+):/g } @ds ) {
            push @ds_invalid, $_ if (length($_) > DS_MAXLEN);
        }
        warn "WARNING: Invalid DS names: @ds_invalid [ exceeded maxlength limit ]" if (@ds_invalid);

        my $step = $self->{step} || 60;                   # basic step is 60 seconds
        my $start = $self->{start} || "now - 10s";
        RRDs::create (
            $file,
            "--step", "$step",
            "--start", "$start",
            @ds,
            @{$self->{rras}},
        );
        if (my $ERR = RRDs::error()) {
            warn "WARNING: rrdUpdate : while creating $file: $ERR\n";
            return;
        }
    }

    my $v = join(':', map { defined $metrics->{$_} ? $metrics->{$_} : 'U' } @names);
    RRDs::update (
        $file,
        "N:$v"
    );

    if (my $ERR = RRDs::error()) {
        warn "WARNING: rrdUpdate : while updating $file with $v :$ERR\n";
        return;
    }else {
        print "Updated RRD file \"$file\" with data \"$v\"\n";
    }
}

sub def_name {
    my ($self, $name) = @_;

    $name =~ s/<=/le_/;
    $name =~ s/>=/ge_/;
    $name =~ s/</lt_/;
    $name =~ s/>/gt_/;
    $name =~ s/::/_/;
    $name =~ s/[:,]/_/;

    return $name;
}

sub clean_field {
    my ($self, $field) = @_;

    # replace anything other than alphanum, ., _, - to _ 
    $field =~ s/[^A-Za-z0-9_.-]+/_/g;

    return $field;
}

1;

# vim: set ts=4 sw=2 expandtab:

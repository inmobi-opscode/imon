#
# $Id: FileWatcher.pm 7564 2012-04-27 11:38:31Z rengith.j $

package IMON::Sender::Sleep::FileWatcher;

use strict;
use warnings;
use Linux::Inotify2;
use threads;
use threads::shared;
use File::Find;
use File::Spec qw(catfile);
use File::Path qw(make_path);

use constant DEFAULT_BASEDIR => '/var/lib/imon/sleep';

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

    $self->{basedir} = $params{basedir} || DEFAULT_BASEDIR;
    die "sleep basedir $self->{basedir} not found" unless ( -d $self->{basedir} );
    $self->{inotify} = new Linux::Inotify2 or die "Unable to create new inotify object: $!";
    $self->{inotify}->blocking("false");
    $self->notify();
}

sub set_expire {
    my ( $self, $file ) = @_;

    if ( -f $file ) {
        my $mtime = ( stat($file) )[9];
        open(SLEEP, '<', $file) or ( warn "Unable to read file $file with err $!" and return );
        my $sleep;
        chomp($sleep = <SLEEP>);
        close(SLEEP);
        if ( $sleep =~ /^\d+$/ ) {
            $self->{expire}->{$file} = $mtime + $sleep; 
            $self->{sleep}->{$file} = $sleep; 
        }
    }
}

# checks whether the host is under sleep or not
# return 1 on sleep, else return 0
sub isleep {
    my ( $self, %params ) = @_;

    return 0 if ( !defined $self->{expire} || !defined $params{host}); # no expire hash set, hence no sleep

    my ($host, $src, $tag, @paths, $now);
    ($host, $src, $tag) = map { $params{$_} || undef } qw(host source tag);
    
    # host.sleep, host/source.sleep or host/source/tag.sleep directory structure
    push @paths, $host if ($host);
    push @paths, "$host/$src" if ($host && $src);
    push @paths, "$host/$src/$tag" if ($host && $src && $tag);
    
    $now = time;
    foreach my $path(@paths) {
        my $file = File::Spec->catfile($self->{basedir},"$path\.sleep");
        if (-f $file && defined $self->{expire}->{$file}) {
            # returns 0(no sleep) if currenttime is greater than expire time as populated in the hash
            return 1 if ( $now < $self->{expire}->{$file} );
        }
    }
    return 0;
}

#
# expose sleep details of a host
# returns hashref with keys: duration(have been sleeping for), and remaining(remaining seconds for sleeping)
# return 0 if not under sleep       
sub sleep_details {
    my ( $self, $path ) = @_;

    return 0 if ( !defined $self->{expire} ); # no expire hash set, hence no sleep
    my $file = $self->{basedir} . "/$path\.sleep";
    if ($self->{expire}->{$file}) {
        my $now = time;
        my $d = {};
        if ($now < $self->{expire}->{$file}) {
            $d->{remaining} = $self->{expire}->{$file} - $now;
            $d->{duration} = $self->{sleep}->{$file} - $d->{remaining}; 
            return $d;
        }
    }
    return 0;
}

# when calling from a generic script other than IMON Sender
# In such cases, data is not cached and the details have to be measured realtime
sub sleep_details_noncached {
    my ( $self, $path ) = @_;

    if (!defined $path) {
        $self->{error} = "path required for invoking sleep details";
        return 0;
    }
    my $d = {};
    my $file = $self->{basedir} . "/$path\.sleep";
    if ( -f $file ) {
        my $mtime = ( stat($file) )[9];
        open(SLEEP, '<', $file) or ( warn "Unable to read file $file with err $!" and return );
        my $sleep;
        chomp($sleep = <SLEEP>);
        close(SLEEP);
        if ( $sleep =~ /^\d+$/ ) {
            my $now = time;
            if( $now < ($mtime + $sleep) ) {
                $d->{duration} = $now - $mtime;
                $d->{remaining} = $mtime + $sleep - $now;
            }
        }
    }
    return (keys %{$d}) ? $d : 0;
}

#
# notify: watches every files and directories to see any modifications
# set the expire hash to set the expire timestamp
# this will run as a thread, since the expire hash need to be updated realtime upon modifications in files
sub notify {
    my $self = shift;

    my $inotify = $self->{inotify};

    my %expire :shared;
    my %sleep :shared;
    $self->{expire} = \%expire;
    $self->{sleep} = \%sleep;

    # Check already sleeping entries and cache details
    find( { wanted => sub {
                if ( -f $_ && $_ !~ /\.swp$/ && $_ !~ /~$/ ) {
                    $self->set_expire($_);
                }
            },
            no_chdir => 1
          },
          $self->{basedir}
    );

    my $sub = sub {
        my %seen;
        while (1) {
            # find all the files under basedir, add watch on it if it is already not under watch
            find( { wanted => sub {
                        $inotify->watch( "$_", IN_MODIFY ) if ( !$seen{$_}++ );
                    },
                    no_chdir => 1
                },
                $self->{basedir}
            );
            my @events = $inotify->read;
            foreach (@events) {
                my $name = $_->fullname;
                if ( -f $name && $name !~ /\.swp$/ && $name !~ /~$/ ) {
                    &set_expire( $self, $name );
                    $expire{$name} = $self->{expire}->{$name};
                    $sleep{$name} = $self->{sleep}->{$name};
                }
            }
            sleep 1;
        }
    };

    my $thr = threads->create($sub);
    $thr->detach();
}

sub set_sleep {
    my ( $self, $path, $sleep ) = @_;

    if(@_ < 3) {
        $self->{error} = "setting sleep need path and sleep parameters";
        return 0;
    }

    if ($sleep !~ /^\d+$/) {
        $self->{error} = "sleep param has to be digits(seconds)";
        return 0;
    }
    my $dir = $self->{basedir} . "/$path";
    $dir =~ s/(.*)\/.*/$1/;
    unless (-d $dir) {
        my $err;
        make_path($dir, { error => \$err });
        $self->{error} = "Err: @$err" and return 0 if (@$err);
    }
    my $file = $self->{basedir} . "/$path\.sleep";
        
    if( !(open(SLEEP, ">", "$file")) ) {
        $self->{error} = "unable to write to file $file, Err: $!";
        return 0;
    }
    print SLEEP "$sleep";
    close(SLEEP);
    return "$path slept for $sleep(s)";
}

sub error {
    my $self = shift;

    return $self->{error};
}

1;
# vim: set ts=4 sw=2 expandtab:

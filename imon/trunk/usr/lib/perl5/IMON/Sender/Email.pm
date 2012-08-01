#
# $Id$

package IMON::Sender::Email;

use strict;
use warnings;
use MIME::Lite;
use base 'IMON::Sender::AlertBase';

use constant DEFAULT_METHOD     => 'smtp';
use constant DEFAULT_MAILSERVER => 'mail.mkhoj.com';
use constant DEFAULT_FROM       => 'no-reply@inmobi.com';

sub init {
    my ($self, %params) = @_;

    $self->SUPER::init(%params);

    $self->{Contacts} = $self->{cfg}->{Contacts};
    $self->{Sources} = $self->{cfg}->{Sources};
    $self->init_mailer(%params);
}

sub init_mailer {
    my ( $self, %params ) = @_;

    $self->{msg} = new MIME::Lite;
    $self->{msg}->build();
    #$self->{msg}->add(From => DEFAULT_FROM);
    #$self->{msg}->add(Subject => "Test message");
}

sub send_data {
    my $self = shift;

    while(1) {
        foreach my $t(@{$self->{transport}}) {
            map {
                $self->send_mail($_); 
            } $t->pull_data();
        }
        sleep 1; # to avoid cpu cycles
    }
}

sub send_mail {
    my ( $self, $data ) = @_;

    my ( $host, $type, $src, $pivot ) = map { delete $data->{$_} } qw(Hostname Type Source pivot);

    return if (!defined $data->{tags}); # skip if no tag
    my $sleep_host = $data->{pivot} || $host;

    if ($self->isleep(host => $sleep_host,source => $src)) {
        print "Host $sleep_host or $sleep_host/$src is inside sleep period, not alerting\n";
        return;
    };
    foreach my $t(keys %{$data->{tags}}) {
        if ($self->isleep(host => $sleep_host,source => $src, tag => $t)) {
            print "Tag $sleep_host/$src/$t is inside sleep period, not alerting\n";
            next;
        };
        # proceed if src/tag already matched, else do a is_tag_match (only once for an instance for a src/tag) and proceed
        if ( !$self->{found}->{$src}->{$t} ) {
            $self->{found}->{$src}->{$t}++ if ($self->is_tag_matched(tag => $t, source => $src))
        }
        next if (!$self->{found}->{$src}->{$t}); # skip if the tag not found
        @{$self->{cts}->{$src}->{$t}} = $self->contacts($src, $t) if (!defined $self->{cts}->{$src}->{$t});

        if (@{$self->{cts}->{$src}->{$t}}) {
            $self->mail(To      => join(', ', @{$self->{cts}->{$src}->{$t}}),
                        Subject => "$pivot\: $t",
                        Data    => $data->{tags}->{$t}
            );
        }
    }
}

sub mail {
    my ( $self, %params ) = @_;

    my $msg = MIME::Lite->new(  From    => $params{From} || DEFAULT_FROM,
                                To      => $params{To},
                                Subject => $params{Subject},
                                Data    => "$params{Data}"
                            );
    eval { $msg->send(DEFAULT_METHOD, DEFAULT_MAILSERVER); };
    if ($@) {
        warn "Error sending mail: $@";
    }else {
        print "Mail sent to $params{To}\n";
    }
}

#
# returns contacts for a given src/tag pair 
#
sub contacts {
    my ( $self, $src, $tag ) = @_;
    
    my @contacts;
    if (defined $self->{Sources}->{$src}->{$tag}) {
        @contacts = map { @{$self->{Contacts}->{$_}} } @{$self->{Sources}->{$src}->{$tag}};
    }else {
        foreach my $str(keys %{$self->{Sources}->{$src}}) {
            if ( $str =~ /^\/(.+)\/$/ ) {
               if ( $tag =~ /$1/ ) {
                   push @contacts, map { @{$self->{Contacts}->{$_}} } @{$self->{Sources}->{$src}->{$str}} ;
               }
            }
        }
    }
    return @contacts;
}

1;

# vim: set ts=4 sw=2 expandtab:

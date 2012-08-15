package Lim::Plugin::DNS::Server;

use common::sense;

use Fcntl qw(:seek);
use IO::File ();
use Digest::SHA ();
use Scalar::Util qw(weaken);

use Lim::Plugin::DNS ();

use Lim::Util ();

use base qw(Lim::Component::Server);

=head1 NAME

...

=head1 VERSION

See L<Lim::Plugin::DNS> for version.

=cut

our $VERSION = $Lim::Plugin::DNS::VERSION;
our %ZoneFilePath = (
    #
    # OpenDNSSEC
    #
    OpenDNSSEC => {
        '/var/opendnssec/unsigned' => {
            writable => 1
        },
        '/var/opendnssec/signed' => {
            writable => 0
        },
        '/var/lib/opendnssec/unsigned' => {
            writable => 1
        },
        '/var/llb/opendnssec/signed' => {
            writable => 0
        }
    },
    #
    # BIND
    #
    BIND => {
        '/var/bind' => {
            writable => 1
        },
        '/var/lib/bind' => {
            writable => 1
        },
        '/var/cache/bind' => {
            writable => 0
        },
        '/etc/bind' => {
            writable => 1,
            match => qr/(?:^db\.|\.db$)/o
        },
        '/var/named' => {
            writable => 1
        },
        '/var/lib/named' => {
            writable => 1
        },
        '/var/cache/named' => {
            writable => 0
        },
        '/etc/named' => {
            writable => 1,
            match => qr/(?:^db\.|\.db$)/o
        }
    }
    #
    # NSD, Knot, Yadifa, PowerDNS. djbdns
    #
);

=head1 SYNOPSIS

...

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub Init {
}

=head2 function1

=cut

sub Destroy {
}

=head2 function1

=cut

sub _ScanZoneFile {
    my ($self) = @_;
    my %file;
    
    foreach my $software (keys %ZoneFilePath) {
        foreach my $path (keys %{$ZoneFilePath{$software}}) {
            my $entry = $ZoneFilePath{$software}->{$path};
            $path =~ s/\/+$//o;
            
            unless (opendir(DIR, $path)) {
                next;
            }
            
            while (defined (my $file = readdir(DIR))) {
                unless (-f $path.'/'.$file and $file !~ /^\./o) {
                    next;
                }
                if (exists $entry->{match} and $file !~ $entry->{match}) {
                    next;
                }
                
                if (defined ($_ = Lim::Util::FileWritable($path.'/'.$file))) {
                    my $write = $entry->{writable} ? 1 : 0;
                    
                    if (exists $file{$software}->{$_}) {
                        $file{$software}->{$_}->{write} = $write;
                        next;
                    }
                    
                    $file{$software}->{$_} = {
                        name => $_,
                        write => $write,
                        read => 1
                    };
                }
                elsif (defined ($_ = Lim::Util::FileReadable($path.'/'.$file))) {
                    if (exists $file{$software}->{$_}) {
                        next;
                    }
                    
                    $file{$software}->{$_} = {
                        name => $_,
                        write => 0,
                        read => 1
                    };
                }
            }
            closedir(DIR);
        }
    }
    
    return \%file;
}

=head2 function1

=cut

sub ReadZones {
    my ($self, $cb) = @_;
    my $files = $self->_ScanZoneFile;
    my @zone;
    
    foreach my $software (keys %$files) {
        foreach my $file (values %{$files->{$software}}) {
            push(@zone, {
                file => $file->{name},
                software => $software,
                read => $file->{read},
                write => $file->{write}
            });
        }
    }
    
    use Data::Dumper;
    print Dumper(\@zone);

    if (scalar @zone == 1) {
        $self->Successful($cb, { zone => $zone[0] });
    }
    elsif (scalar @zone) {
        $self->Successful($cb, { zone => \@zone });
    }
    else {
        $self->Successful($cb);
    }
}

=head2 function1

=cut

sub CreateZone {
    my ($self, $cb) = @_;
    
    $self->Error($cb, 'Not Implemented');
}

=head2 function1

=cut

sub ReadZone {
    my ($self, $cb) = @_;
    
    $self->Error($cb, 'Not Implemented');
}

=head2 function1

=cut

sub UpdateZone {
    my ($self, $cb) = @_;
    
    $self->Error($cb, 'Not Implemented');
}

=head2 function1

=cut

sub DeleteZone {
    my ($self, $cb) = @_;
    
    $self->Error($cb, 'Not Implemented');
}

=head2 function1

=cut

sub CreateZoneRr {
    my ($self, $cb) = @_;
    
    $self->Error($cb, 'Not Implemented');
}

=head2 function1

=cut

sub ReadZoneRr {
    my ($self, $cb) = @_;
    
    $self->Error($cb, 'Not Implemented');
}

=head2 function1

=cut

sub UpdateZoneRr {
    my ($self, $cb) = @_;
    
    $self->Error($cb, 'Not Implemented');
}

=head2 function1

=cut

sub DeleteZoneRr {
    my ($self, $cb) = @_;
    
    $self->Error($cb, 'Not Implemented');
}

=head1 AUTHOR

Jerry Lundström, C<< <lundstrom.jerry at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/jelu/lim-plugin-dns/issues>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Lim::Plugin::DNS

You can also look for information at:

=over 4

=item * Lim issue tracker (report bugs here)

L<https://github.com/jelu/lim-plugin-dns/issues>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Jerry Lundström.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Lim::Plugin::DNS::Server

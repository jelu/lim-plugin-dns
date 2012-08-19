package Lim::Plugin::DNS::Server;

use common::sense;

use Fcntl qw(:seek);
use IO::File ();
use Digest::SHA ();
use Scalar::Util qw(weaken);

use Lim::Plugin::DNS ();

use Lim::Util ();

use base qw(Lim::Component::Server);

=encoding utf8

=head1 NAME

...

=head1 VERSION

See L<Lim::Plugin::DNS> for version.

=cut

our $VERSION = $Lim::Plugin::DNS::VERSION;

=head1 SYNOPSIS

...

=head1 CONFIGURATION

=head2 function1

=cut

our %ZoneFilePath = (
    #
    # OpenDNSSEC
    #
    OpenDNSSEC => {
        '/var/opendnssec/unsigned' => {
            writable => 1,
            creatable => 1
        },
        '/var/opendnssec/signed' => {
            writable => 0
        },
        '/var/lib/opendnssec/unsigned' => {
            writable => 1,
            creatable => 1
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
            writable => 1,
            creatable => 1
        },
        '/var/lib/bind' => {
            writable => 1,
            creatable => 1
        },
        '/var/cache/bind' => {
            writable => 0
        },
        '/etc/bind' => {
            writable => 1,
            match => qr/(?:^db\.|\.db$)/o
        },
        '/var/named' => {
            writable => 1,
            creatable => 1
        },
        '/var/lib/named' => {
            writable => 1,
            creatable => 1
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
    my ($self, $cb, $q) = @_;

    foreach my $zone (ref($q->{zone}) eq 'ARRAY' ? @{$q->{zone}} : $q->{zone}) {
        my $file;
        
        if ($zone->{file} !~ /\//o) {
            unless (exists $zone->{software}) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Zone file ', $zone->{file}, ' without path needs to specify what software it belongs to'
                ));
                return;
            }
            unless (exists $ZoneFilePath{$zone->{software}}) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unknown software ', $zone->{software}, ' specified for zone file ', $zone->{file}
                ));
                return;
            }
            
            foreach my $path (keys %{$ZoneFilePath{$zone->{software}}}) {
                my $entry = $ZoneFilePath{$zone->{software}}->{$path};
                
                if (exists $entry->{creatable} and $entry->{creatable}) {
                    if (exists $entry->{match}) {
                        unless ($zone->{file} =~ $entry->{match}) {
                            next;
                        }
                    }
                    $file = $path .'/'. $zone->{file};
                }
            }
        }
        else {
            if ($zone->{file} =~ /^(.+)\/([^\/]+)$/o) {
                my ($path, $filename) = ($1, $2);
                
                foreach my $software (keys %ZoneFilePath) {
                    if (exists $ZoneFilePath{$software}->{$path}) {
                        my $entry = $ZoneFilePath{$software}->{$path};

                        if (exists $entry->{creatable} and $entry->{creatable}) {
                            if (exists $entry->{match}) {
                                unless ($zone->{file} =~ $entry->{match}) {
                                    next;
                                }
                            }
                            $file = $path .'/'. $filename;
                        }
                    }
                }
            }
        }
        
        unless (defined $file) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Zone file ', $zone->{file}, ' invalid or restricted to be created on specified path'
            ));
            return;
        }
        if (-f $file) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Zone file ', $zone->{file}, ' already exists'
            ));
            return;
        }
        if (exists $zone->{content} and (exists $zone->{options} or exists $zone->{rr})) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Zone file ', $zone->{file}, ' can not specify content and also specify options or rr'
            ));
            return;
        }
        
        if (exists $zone->{content}) {
            unless (Lim::Util::FileWriteContent($file, $zone->{content})) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to write content of zone file ', $zone->{file}, ' to file ', $file
                ));
                return;
            }
        }
        else {
            my $tmp = Lim::Util::TempFile;
            unless (defined $tmp) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to create temporary file for zone file ', $zone->{file}
                ));
                return;
            }
            
            if (exists $zone->{options}) {
                foreach my $option (values %{$zone->{options}}) {
                    print $tmp '$', $option->{name}, ' ', $option->{value}, "\n";
                }
            }
            if (exists $zone->{rr}) {
                foreach my $rr (values %{$zone->{rr}}) {
                    print $tmp join("\t",
                        $rr->{name},
                        exists $rr->{ttl} ? $rr->{ttl} : '',
                        exists $rr->{class} ? $rr->{class} : '',
                        $rr->{type},
                        $rr->{rdata}
                        ), "\n";
                    
                    if (exists $rr->{rr}) {
                        foreach my $more_rr (values %{$rr->{rr}}) {
                            print $tmp join("\t",
                                '',
                                exists $more_rr->{ttl} ? $more_rr->{ttl} : '',
                                exists $more_rr->{class} ? $more_rr->{class} : '',
                                $more_rr->{type},
                                $more_rr->{rdata}
                                ), "\n";
                        }
                    }
                }
            }
            
            $tmp->flush;
            $tmp->close;
            
            unless (rename($tmp->filename, $file)) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to rename the temporary file ', $tmp->filename, ' to ', $file, ' for zone file ', $zone->{file}
                ));
                return;
            }
        }
    }
    $self->Successful($cb);
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

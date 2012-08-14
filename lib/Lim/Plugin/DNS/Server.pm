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
    '/var/opendnssec/unsigned' => {
        read => 1,
        write => 1
    },
    '/var/opendnssec/signed' => {
        read => 1,
        write => 0
    },
    '/var/lib/opendnssec/unsigned' => {
        read => 1,
        write => 1
    },
    '/var/llb/opendnssec/signed' => {
        read => 1,
        write => 0
    },
    #
    # BIND
    #
    '/var/bind' => {
        read => 1,
        write => 1
    },
    '/var/lib/bind' => {
        read => 1,
        write => 1
    },
    '/var/cache/bind' => {
        read => 1,
        write => 0
    },
    '/etc/bind' => {
        read => 1,
        write => 1,
        match => '\.db$'
    },
    '/var/named' => {
        read => 1,
        write => 1
    },
    '/var/lib/named' => {
        read => 1,
        write => 1
    },
    '/var/cache/named' => {
        read => 1,
        write => 0
    },
    '/etc/named' => {
        read => 1,
        write => 1,
        match => '\.db$'
    },
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

sub ReadZones {
    my ($self, $cb) = @_;
    
    $self->Error($cb, 'Not Implemented');
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

package Lim::Plugin::DNS::CLI;

use common::sense;

use Getopt::Long ();
use Scalar::Util qw(weaken);

use Lim::Plugin::DNS ();

use base qw(Lim::Component::CLI);

=encoding utf8

=head1 NAME

...

=head1 VERSION

See L<Lim::Plugin::DNS> for version.

=cut

our $VERSION = $Lim::Plugin::DNS::VERSION;

=head1 SYNOPSIS

...

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub zones {
    my ($self) = @_;
    my $opendnssec = Lim::Plugin::DNS->Client;
    
    weaken($self);
    $opendnssec->ReadZones(sub {
        my ($call, $response) = @_;
        
        unless (defined $self) {
            undef($opendnssec);
            return;
        }
        
        if ($call->Successful) {
            if (exists $response->{zone}) {
                $self->cli->println(join("\t", 'Software', 'Zone File', 'Read', 'Write'));
                foreach my $zone (ref($response->{zone}) eq 'ARRAY' ? @{$response->{zone}} : $response->{zone}) {
                    $self->cli->println(join("\t",
                        $zone->{software},
                        $zone->{file},
                        $zone->{read} ? 'Yes' : 'No',
                        $zone->{write} ? 'Yes' : 'No'
                        ));
                }
            }
            $self->Successful;
        }
        else {
            $self->Error($call->Error);
        }
        undef($opendnssec);
    });
}

=head2 function1

=cut

sub zone {
    my ($self, $cmd) = @_;
    my $software;
    my $as_content = 0;
    my ($getopt, $args) = Getopt::Long::GetOptionsFromString($cmd,
        'software:s' => \$software,
        'as-content' => \$as_content
    );

    unless ($getopt and scalar @$args) {
        $self->Error;
        return;
    }

    if ($args->[0] eq 'create' and scalar @$args >= 2) {
        my (undef, $zone, $file) = @$args;
        my $content;
        
        if (defined $file) {
            unless (defined ($content = Lim::Util::FileReadContent($file))) {
                $self->Error('Unable to read file ', $file, ' to create zone ', $zone);
                return;
            }
        }
        
        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->CreateZone({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ()),
                (defined $content ? (content => $content) : ())
            }
        }, sub {
            my ($call, $response) = @_;
            
            unless (defined $self) {
                undef($opendnssec);
                return;
            }
            
            if ($call->Successful) {
                $self->cli->println('Zone ', $zone, ' created');
                $self->Successful;
            }
            else {
                $self->Error($call->Error);
            }
            undef($opendnssec);
        });
        return;
    }
    elsif ($args->[0] eq 'read' and scalar @$args >= 2) {
        my @zones;
        my $skip = 1;
        
        foreach (@$args) {
            if ($skip) {
                $skip--;
                next;
            }
            
            push(@zones, {
                file => $_,
                (defined $software ? (software => $software) : ()),
                ($as_content ? (as_content => 1) : ())
            });
        }
        
        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->ReadZone({
            zone => \@zones
        }, sub {
            my ($call, $response) = @_;
            
            unless (defined $self) {
                undef($opendnssec);
                return;
            }
            
            if ($call->Successful) {
                if (exists $response->{zone}) {
                    foreach my $zone (ref($response->{zone}) eq 'ARRAY' ? @{$response->{zone}} : $response->{zone}) {
                        $self->cli->println('Zone: ', $zone->{file}, ' (', $zone->{software}, ')');
                        if (exists $zone->{rr}) {
                            foreach my $rr (ref($zone->{rr}) eq 'ARRAY' ? @{$zone->{rr}} : $zone->{rr}) {
                                $self->cli->println(join("\t",
                                    $rr->{name},
                                    $rr->{ttl},
                                    $rr->{class},
                                    $rr->{type},
                                    $rr->{rdata}
                                ));
                            }
                        }
                        elsif (exists $zone->{content}) {
                            $self->cli->println($zone->{content});
                        }
                    }
                }
                $self->Successful;
            }
            else {
                $self->Error($call->Error);
            }
            undef($opendnssec);
        });
        return;
    }
    elsif ($args->[0] eq 'update' and scalar @$args == 3) {
        my (undef, $zone, $file) = @$args;
        my $content;
        
        unless (defined ($content = Lim::Util::FileReadContent($file))) {
            $self->Error('Unable to read file ', $file, ' to update zone ', $zone);
            return;
        }
        
        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->UpdateZone({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ()),
                content => $content
            }
        }, sub {
            my ($call, $response) = @_;
            
            unless (defined $self) {
                undef($opendnssec);
                return;
            }
            
            if ($call->Successful) {
                $self->cli->println('Zone ', $zone, ' updated');
                $self->Successful;
            }
            else {
                $self->Error($call->Error);
            }
            undef($opendnssec);
        });
        return;
    }
    elsif ($args->[0] eq 'delete' and scalar @$args == 2) {
        my (undef, $zone) = @$args;
        
        # Ask user
        
        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->DeleteZone({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ())
            }
        }, sub {
            my ($call, $response) = @_;
            
            unless (defined $self) {
                undef($opendnssec);
                return;
            }
            
            if ($call->Successful) {
                $self->cli->println('Zone ', $zone, ' deleted');
                $self->Successful;
            }
            else {
                $self->Error($call->Error);
            }
            undef($opendnssec);
        });
        return;
    }
    $self->Error;
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

1; # End of Lim::Plugin::DNS::CLI

package Lim::Plugin::DNS::CLI;

use common::sense;

use Getopt::Long ();
use Scalar::Util qw(weaken);

use Lim::Plugin::DNS ();

use base qw(Lim::Component::CLI);

=encoding utf8

=head1 NAME

Lim::Plugin::DNS::CLI - CLI class for DNS Manager Lim plugin

=head1 VERSION

See L<Lim::Plugin::DNS> for version.

=cut

our $VERSION = $Lim::Plugin::DNS::VERSION;

=head1 SYNOPSIS

You should not use this directly, please see L<Lim::Plugin::DNS> on how to use.

  use Lim::Plugin::DNS;
  
  # Create a CLI object
  $cli = Lim::Plugin::DNS->CLI;

=head1 METHODS

=over 4

=item $cli->zones

List existing zones and related software.

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

=item $cli->zone("create", "[--software <software>] <zone name> <local zone file>")

Create a new zone with the content of a local zone file.

=item $cli->zone("read", "[--software <software>] <zone names ... >")

Read zones and display content.

=item $cli->zone("update", "[--software <software>] <zone name> <local zone file>")

Update a existing zone with the content of a local zone file.

=item $cli->zone("delete", "[--software <software>] <zone name>")

Delete the specified zone.

=cut

sub zone {
    my ($self, $cmd) = @_;
    my $software;
    my $as_content = 0;
    my ($getopt, $args) = Getopt::Long::GetOptionsFromString($cmd,
        'software:s' => \$software
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
                (defined $software ? (software => $software) : ())
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
                        if (exists $zone->{content}) {
                            $self->cli->println($zone->{content});
                        }
                        else {
                            if (exists $zone->{option}) {
                                foreach my $option (ref($zone->{option}) eq 'ARRAY' ? @{$zone->{option}} : $zone->{option}) {
                                    $self->cli->println(join("\t",
                                        '$'.$option->{name},
                                        $option->{value}
                                    ));
                                }
                            }
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

=item $cli->option("create", "[--software <software>] <zone name> <option name> <option values ... >")

Create a new zone option in the an existing zone.

=item $cli->option("read", "[--software <software>] <zone name> [option name]")

Read and display the specified option, or all if not given, from the zone.

=item $cli->option("update", "[--software <software>] <zone name> <option name> <option values ... >")

Update an existing option in a zone.

=item $cli->option("delete", "[--software <software>] <zone name> <option name>")

Delete the specified option from a zone.

=cut

sub option {
    my ($self, $cmd) = @_;
    my $software;
    my ($getopt, $args) = Getopt::Long::GetOptionsFromString($cmd,
        'software:s' => \$software
    );

    unless ($getopt and scalar @$args) {
        $self->Error;
        return;
    }

    if ($args->[0] eq 'create' and scalar @$args >= 4) {
        my (undef, $zone, $name, @value) = @$args;
        my $value = join(' ', @value);

        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->CreateZoneOption({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ()),
                option => {
                    name => $name,
                    value => $value
                }
            }
        }, sub {
            my ($call, $response) = @_;
            
            unless (defined $self) {
                undef($opendnssec);
                return;
            }
            
            if ($call->Successful) {
                $self->cli->println('Zone ', $zone, ' option ', $name, ' created');
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
        my (undef, $zone, $name) = @$args;

        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->ReadZoneOption({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ()),
                (defined $name ? (option => { name => $name }) : ())
            }
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
                        if (exists $zone->{option}) {
                            foreach my $option (ref($zone->{option}) eq 'ARRAY' ? @{$zone->{option}} : $zone->{option}) {
                                $self->cli->println(join("\t",
                                    '$'.$option->{name},
                                    $option->{value}
                                ));
                            }
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
    elsif ($args->[0] eq 'update' and scalar @$args >= 4) {
        my (undef, $zone, $name, @value) = @$args;
        my $value = join(' ', @value);

        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->UpdateZoneOption({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ()),
                option => {
                    name => $name,
                    value => $value
                }
            }
        }, sub {
            my ($call, $response) = @_;
            
            unless (defined $self) {
                undef($opendnssec);
                return;
            }
            
            if ($call->Successful) {
                $self->cli->println('Zone ', $zone, ' option ', $name, ' updated');
                $self->Successful;
            }
            else {
                $self->Error($call->Error);
            }
            undef($opendnssec);
        });
        return;
    }
    elsif ($args->[0] eq 'delete' and scalar @$args == 3) {
        my (undef, $zone, $name) = @$args;

        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->DeleteZoneOption({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ()),
                option => {
                    name => $name
                }
            }
        }, sub {
            my ($call, $response) = @_;
            
            unless (defined $self) {
                undef($opendnssec);
                return;
            }
            
            if ($call->Successful) {
                $self->cli->println('Zone ', $zone, ' option ', $name, ' deleted');
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

=item $cli->rr("create", "[--software <software>] [--ttl <ttl>] [--class <class>] <zone name> <rr name> <rr type> <rr data ... >")

Create a new resource record in an existing zone.

=item $cli->rr("read", "[--software <software>] <zone name> [rr name]")

Read and display the specified resource record, or all if not given, from the zone.

=item $cli->rr("update", "[--software <software>] [--ttl <ttl>] [--class <class>] <zone name> <rr name> <rr type> <rr data ... >")

Update an existing resource record in a zone.

=item $cli->rr("delete", "[--software <software>] <zone name> <rr name>")

Delete the specified resource record from a zone.

=cut

sub rr {
    my ($self, $cmd) = @_;
    my $software;
    my $ttl;
    my $class;
    my ($getopt, $args) = Getopt::Long::GetOptionsFromString($cmd,
        'software:s' => \$software,
        'ttl:s' => \$ttl,
        'class:s' => \$class
    );

    unless ($getopt and scalar @$args) {
        $self->Error;
        return;
    }

    if ($args->[0] eq 'create' and scalar @$args >= 5) {
        my (undef, $zone, $name, $type, @rdata) = @$args;
        my $rdata = join(' ', @rdata);

        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->CreateZoneRr({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ()),
                rr => {
                    name => $name,
                    (defined $ttl ? (ttl => $ttl) : ()),
                    (defined $class ? (class => $class) : ()),
                    type => $type,
                    rdata => $rdata
                }
            }
        }, sub {
            my ($call, $response) = @_;
            
            unless (defined $self) {
                undef($opendnssec);
                return;
            }
            
            if ($call->Successful) {
                $self->cli->println('Zone ', $zone, ' RR ', $name, ' created');
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
        my (undef, $zone, $name) = @$args;

        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->ReadZoneRr({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ()),
                (defined $name ? (rr => { name => $name }) : ())
            }
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
    elsif ($args->[0] eq 'update' and scalar @$args >= 5) {
        my (undef, $zone, $name, $type, @rdata) = @$args;
        my $rdata = join(' ', @rdata);

        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->UpdateZoneRr({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ()),
                rr => {
                    name => $name,
                    (defined $ttl ? (ttl => $ttl) : ()),
                    (defined $class ? (class => $class) : ()),
                    type => $type,
                    rdata => $rdata
                }
            }
        }, sub {
            my ($call, $response) = @_;
            
            unless (defined $self) {
                undef($opendnssec);
                return;
            }
            
            if ($call->Successful) {
                $self->cli->println('Zone ', $zone, ' RR ', $name, ' updated');
                $self->Successful;
            }
            else {
                $self->Error($call->Error);
            }
            undef($opendnssec);
        });
        return;
    }
    elsif ($args->[0] eq 'delete' and scalar @$args == 3) {
        my (undef, $zone, $name) = @$args;

        my $opendnssec = Lim::Plugin::DNS->Client;
        weaken($self);
        $opendnssec->DeleteZoneRr({
            zone => {
                file => $zone,
                (defined $software ? (software => $software) : ()),
                rr => {
                    name => $name
                }
            }
        }, sub {
            my ($call, $response) = @_;
            
            unless (defined $self) {
                undef($opendnssec);
                return;
            }
            
            if ($call->Successful) {
                $self->cli->println('Zone ', $zone, ' RR ', $name, ' deleted');
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

=back

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

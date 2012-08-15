package Lim::Plugin::DNS;

use common::sense;

use base qw(Lim::Component);

=head1 NAME

Lim::Plugin::DNS - DNS Manager plugin for Lim

=head1 VERSION

Version 0.10

=cut

our $VERSION = '0.10';

=head1 SYNOPSIS

...

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub Module {
    'DNS';
}

=head2 function1

=cut

sub Calls {
    {
        ReadZones => {
            out => {
                zone => {
                    file => 'string',
                    software => 'string optional',
                    read => 'bool',
                    write => 'bool'
                }
            }
        },
        #
        # Zone
        #
        CreateZone => {
            in => {
                zone => {
                    '' => 'required',
                    file => 'string',
                    software => 'string optional',
                    options => {
                        name => 'string',
                        value => 'string'
                    },
                    rr => {
                        name => 'string',
                        ttl => 'string',
                        class => 'string',
                        type => 'string',
                        rdata => 'string'
                    },
                    content => 'string optional'
                }
            },
        },
        ReadZone => {
            in => {
                zone => {
                    '' => 'required',
                    file => 'string',
                    raw => 'bool optional'
                }
            },
            out => {
                zone => {
                    file => 'string',
                    software => 'string optional',
                    options => {
                        name => 'string',
                        value => 'string'
                    },
                    rr => {
                        name => 'string',
                        ttl => 'string',
                        class => 'string',
                        type => 'string',
                        rdata => 'string'
                    },
                    content => 'string optional'
                }
            }
        },
        UpdateZone => {
            in => {
                zone => {
                    '' => 'required',
                    file => 'string',
                    options => {
                        name => 'string',
                        value => 'string'
                    },
                    rr => {
                        name => 'string',
                        ttl => 'string',
                        class => 'string',
                        type => 'string',
                        rdata => 'string'
                    },
                    content => 'string optional'
                }
            }
        },
        DeleteZone => {
            in => {
                zone => {
                    '' => 'required',
                    file => 'string'
                }
            }
        },
        #
        # Zone Resource Record
        #
        CreateZoneRr => {
            in => {
                zone => {
                    '' => 'required',
                    file => 'string',
                    rr => {
                        name => 'string',
                        ttl => 'string',
                        class => 'string',
                        type => 'string',
                        rdata => 'string'
                    }
                }
            }
        },
        ReadZoneRr => {
            in => {
                zone => {
                    '' => 'required',
                    file => 'string',
                    rr => {
                        name => 'string'
                    }
                }
            },
            out => {
                zone => {
                    file => 'string',
                    rr => {
                        name => 'string',
                        ttl => 'string',
                        class => 'string',
                        type => 'string',
                        rdata => 'string'
                    }
                }
            }
        },
        UpdateZoneRr => {
            in => {
                zone => {
                    '' => 'required',
                    file => 'string',
                    rr => {
                        name => 'string',
                        ttl => 'string',
                        class => 'string',
                        type => 'string',
                        rdata => 'string'
                    }
                }
            }
        },
        DeleteZoneRr => {
            in => {
                zone => {
                    '' => 'required',
                    file => 'string',
                    rr => {
                        name => 'string'
                    }
                }
            }
        }
    };
}

=head2 function1

=cut

sub Commands {
    {
        zones => 1
    };
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

1; # End of Lim::Plugin::DNS

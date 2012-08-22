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

# http://www.iana.org/assignments/dns-parameters
our %_CLASS = (
    IN => 1,
    CH => 1,
    HS => 1
);
our %_CLASS_NAME = ();
our %_TYPE = (
    A => 1,
    NS => 1,
    MD => 1,
    MF => 1,
    CNAME => 1,
    SOA => 1,
    MB => 1,
    MG => 1,
    MR => 1,
    NULL => 1,
    WKS => 1,
    PTR => 1,
    HINFO => 1,
    MINFO => 1,
    MX => 1,
    TXT => 1,
    RP => 1,
    AFSDB => 1,
    X25 => 1,
    ISDN => 1,
    RT => 1,
    NSAP => 1,
    'NSAP-PTR' => 1,
    SIG => 1,
    KEY => 1,
    PX => 1,
    GPOS => 1,
    AAAA => 1,
    LOC => 1,
    NXT => 1,
    EID => 1,
    NIMLOC => 1,
    SRV => 1,
    ATMA => 1,
    NAPTR => 1,
    KX => 1,
    CERT => 1,
    A6 => 1,
    DNAME => 1,
    SINK => 1,
    OPT => 1,
    APL => 1,
    DS => 1,
    SSHFP => 1,
    IPSECKEY => 1,
    RRSIG => 1,
    NSEC => 1,
    DNSKEY => 1,
    DHCID => 1,
    NSEC3 => 1,
    NSEC3PARAM => 1,
    TLSA => 1,
    HIP => 1,
    NINFO => 1,
    RKEY => 1,
    TALINK => 1,
    CDS => 1,
    SPF => 1,
    UINFO => 1,
    UID => 1,
    GID => 1,
    UNSPEC => 1,
    NID => 1,
    L32 => 1,
    L64 => 1,
    LP => 1,
    TKEY => 1,
    TSIG => 1,
    IXFR => 1,
    AXFR => 1,
    MAILB => 1,
    MAILA => 1,
    '*' => 1,
    URI => 1,
    CAA => 1,
    TA => 1,
    DLV => 1,
    NB => 1,
    NBSTAT => 1
);
our %_TYPE_NAME = ();

BEGIN {
    %_CLASS_NAME = reverse %_CLASS;
    %_TYPE_NAME = reverse %_TYPE;
}

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
                        software => $software,
                        short => $file,
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
                        software => $software,
                        short => $file,
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

sub _ParseZoneFile {
    my ($self, $file, $option, $rr) = @_;
    my ($line, $last, $rr_hash, $rr_array, $option_hash, $option_array);
    
    if (defined $rr) {
        if (ref($rr) eq 'HASH') {
            $rr_hash = $rr;
        }
        elsif (ref($rr) eq 'ARRAY') {
            $rr_array = $rr;
        }
    }
    
    if (defined $option) {
        if (ref($option) eq 'HASH') {
            $option_hash = $option;
        }
        elsif (ref($option) eq 'ARRAY') {
            $option_array = $option;
        }
    }

    while (<$file>) {
        if (/^([^;]+[^;\s])/o) {
            my $this = $1;
    
            if (defined $line) {
                $line .= $this;
                unless ($this =~ /\)/o) {
                    next;
                }
            }
            elsif ($this =~ /\(/o and $this !~ /\)/o) {
                $line .= $this;
                next;
            }
            else {
                $line = $this;
            }

            my ($name, $ttl, $class, $type, $rdata);
            {
                my @parts = split(/\s+/o, $line);
                $name = shift(@parts);
                
                if ($name =~ /^\$/o) {
                    $name =~ s/^\$//o;
                    
                    if (defined $option_hash) {
                        $option_hash->{$name} = join(' ', @parts);
                    }
                    elsif (defined $option_array) {
                        push(@$option_array, {
                            name => $name,
                            value => join(' ', @parts)
                        })
                    }
                    undef($line);
                    next;
                }
                
                my $part = shift(@parts);
                if (exists $_TYPE{$part}) {
                    $type = $part;
                }
                else {
                    if ($part =~ /^\d+[YyMmWwDdHhSs]?$/o) {
                        $ttl = $part;
                    }
                    elsif (exists $_CLASS{$part}) {
                        $class = $part;
                    }
                    else {
                        undef($line);
                        next;
                    }
            
                    $part = shift(@parts);
                    if (exists $_TYPE{$part}) {
                        $type = $part;
                    }
                    else {
                        if (!defined $ttl and $part =~ /^\d+[YyMmWwDdHhSs]?$/o) {
                            $ttl = $part;
                        }
                        elsif (!defined $class and exists $_CLASS{$part}) {
                            $class = $part;
                        }
                        else {
                            undef($line);
                            next;
                        }
                        
                        $type = shift(@parts);
                        unless (exists $_TYPE{$type}) {
                            undef($line);
                            next;
                        }
                    }
                }
                
                $rdata = join(' ', @parts);
            }

            if (defined $name and defined $type and defined $rdata) {
                unless ($name) {
                    if (defined $last) {
                        $name = $last;
                    }
                }
                else {
                    $last = $name;
                }

                if (defined $rr_hash) {
                    push(@{$rr_hash->{$name}}, {
                        (defined $ttl ? (ttl => $ttl) : ()),
                        (defined $class ? (class => $class) : ()),
                        type => $type,
                        rdata => $rdata
                    });
                }
                elsif (defined $rr_array) {
                    push(@$rr_array, {
                        name => $name,
                        (defined $ttl ? (ttl => $ttl) : ()),
                        (defined $class ? (class => $class) : ()),
                        type => $type,
                        rdata => $rdata
                    })
                }
            }
            undef($line);
        }
    }
    return 1;
}

=head2 function1

=cut

sub _ParseZoneContent {
    my ($self, $buf, $option, $rr) = @_;
    my ($pre, $name, $ttl, $class, $type, $rdata, $last, $rr_hash, $rr_array, $option_hash, $option_array);
    my $concat = 0;
    
    if (defined $rr) {
        if (ref($rr) eq 'HASH') {
            $rr_hash = $rr;
        }
        elsif (ref($rr) eq 'ARRAY') {
            $rr_array = $rr;
        }
    }
    
    if (defined $option) {
        if (ref($option) eq 'HASH') {
            $option_hash = $option;
        }
        elsif (ref($option) eq 'ARRAY') {
            $option_array = $option;
        }
    }

    while (1) {
        if (!$concat) {
            if ($buf =~ /\G[\r\n]*(\s*)([^;\s\r\n]+)/ogc) {
                $pre = $1;
                $name = $2;
                if ($buf =~ /\G[\s\r\n]*([^;\s\r\n]+)/ogc) {
                    $ttl = $1;
                    if ($buf =~ /\G[\s\r\n]*([^;\s\r\n]+)/ogc) {
                        $class = $1;
                        if ($buf =~ /\G[\s\r\n]*([^;\s\r\n]+)/ogc) {
                            $type = $1;
                            if ($buf =~ /\G[\s\r\n]*([^;\r\n]*[^;\s\r\n])/ogc) {
                                $rdata = $1;
                            }
                        }
                    }
                }
                
                $buf =~ /\G[^\r\n]*/ogc;
            }
            else {
                unless ($buf =~ /\G[\r\n]*[^\r\n]*/ogc) {
                    last;
                }
                next;
            }

            if ($name =~ /^\$/o) {
                $name =~ s/^\$//o;
                
                my $value;
                if (defined $ttl) {
                    $value .= (defined $value ? ' ' : '').$ttl;
                }
                if (defined $class) {
                    $value .= (defined $value ? ' ' : '').$class;
                }
                if (defined $type) {
                    $value .= (defined $value ? ' ' : '').$type;
                }
                if (defined $rdata) {
                    $value .= (defined $value ? ' ' : '').$rdata;
                }

                if (defined $option_hash) {
                    $option_hash->{$name} = $value;
                }
                elsif (defined $option_array) {
                    push(@$option_array, {
                        name => $name,
                        value => $value
                    })
                }
                $pre = $name = $ttl = $class = $type = $rdata = undef;
                next;
            }
            
            if (length($pre)) {
                if (defined $rdata) {
                    $rdata = $type . $rdata;
                }
                else {
                    $rdata = $type;
                }
                $type = $class;
                $class = $ttl;
                $ttl = $name;
                undef($name);
            }
    
            if (exists $_TYPE{$ttl}) {
                $rdata = $class .
                    (defined $type ? ' '.$type : '') .
                    (defined $rdata ? ' '.$rdata : '');
                $type = $_TYPE{$ttl};
                undef($ttl);
                undef($class);
            }
            else {
                if ($ttl =~ /^\d+[YyMmWwDdHhSs]?$/o) {
                    if (exists $_TYPE{$class}) {
                        $rdata = $type .
                            (defined $rdata ? ' '.$rdata : '');
                        $type = $_TYPE{$class};
                        undef($class);
                    }
                    else {
                        if (exists $_CLASS{$class}) {
                            $class = $_CLASS{$class};
                        }
                        else {
                            $pre = $name = $ttl = $class = $type = $rdata = undef;
                            next;
                        }
                    }
                }
                elsif (exists $_CLASS{$ttl}) {
                    if (exists $_TYPE{$class}) {
                        $rdata = $type .
                            (defined $rdata ? ' '.$rdata : '');
                        $type = $_TYPE{$class};
                        undef($class);
                    }
                    else {
                        if ($class =~ /^\d+[YyMmWwDdHhSs]?$/o) {
                        }
                        else {
                            $pre = $name = $ttl = $class = $type = $rdata = undef;
                            next;
                        }
                    }
                    
                    $_ = $ttl;
                    $ttl = $class;
                    $class = $_CLASS{$_};
                }
                else {
                    $pre = $name = $ttl = $class = $type = $rdata = undef;
                    next;
                }
            }
        
            if ($rdata =~ /\(/o and $rdata !~ /\)/o) {
                $concat = 1;
                next;
            }
        }
        else {
            if ($buf =~ /\G[\s\r\n]*([^;\r\n]*[^;\r\n\s])/ogc) {
                $rdata .= ' '.$1;
                
                unless ($1 =~ /\)/o) {
                    next;
                }
                $concat = 0;
            }
            else {
                unless ($buf =~ /\G[\r\n]*[^\r\n]*/ogc) {
                    last;
                }
                next;
            }
        }
    
        unless ($name) {
            unless (defined $last) {
                $pre = $name = $ttl = $class = $type = $rdata = undef;
                next;
            }
            $name = $last;
        }
        else {
            $last = $name;
        }
        if (defined $rr_hash) {
            push(@{$rr_hash->{$name}}, {
                (defined $ttl ? (ttl => $ttl) : ()),
                (defined $class ? (class => $class) : ()),
                type => $type,
                rdata => $rdata
            });
        }
        elsif (defined $rr_array) {
            push(@$rr_array, {
                name => $name,
                (defined $ttl ? (ttl => $ttl) : ()),
                (defined $class ? (class => $class) : ()),
                type => $type,
                rdata => $rdata
            })
        }
    
        $pre = $name = $ttl = $class = $type = $rdata = undef;
    }
    return 1;
}

=head2 function1

=cut

sub _WriteZoneFile {
    my ($self, $file, $rr, $option) = @_;
    my $tmp;
        
    if (-f $file) {
        $tmp = Lim::Util::TempFileLikeThis($file);
    }
    else {
        $tmp = Lim::Util::TempFile;
    }
    unless (defined $tmp) {
        die 'Unable to create temporary file';
    }
    
    if (defined $option) {
        if (ref($option) eq 'HASH') {
            foreach my $name (keys %{$option}) {
                print $tmp '$', $name, ' ', $option->{$name}, "\n";
            }
        }
        elsif (ref($option) eq 'ARRAY') {
            foreach (@$option) {
                unless (ref($_) eq 'HASH') {
                    die 'Invalid option data structure';
                }
                print $tmp '$', $_->{name}, ' ', $_->{value}, "\n";
            }
        }
        else {
            die 'Invalid parameters';
        }
    }

    if (defined $rr) {
        if (ref($rr) eq 'HASH') {
            foreach my $name (values %{$rr}) {
                unless (ref($rr->{$name}) eq 'ARRAY') {
                    die 'Invalid rr data structure';
                }
                foreach (@{$rr->{$name}}) {
                    unless (ref($_) eq 'HASH') {
                        die 'Invalid rr data structure';
                    }
                    
                    print $tmp join("\t",
                        $name,
                        exists $_->{ttl} ? $_->{ttl} : '',
                        exists $_->{class} ? uc($_->{class}) : '',
                        uc($_->{type}),
                        $_->{rdata}
                        ), "\n";
                }
            }
        }
        elsif (ref($rr) eq 'ARRAY') {
            foreach (@{$rr}) {
                unless (ref($_) eq 'HASH') {
                    die 'Invalid rr data structure';
                }
                
                print $tmp join("\t",
                    $_->{name},
                    exists $_->{ttl} ? $_->{ttl} : '',
                    exists $_->{class} ? uc($_->{class}) : '',
                    uc($_->{type}),
                    $_->{rdata}
                    ), "\n";
            }
        }
    }
            
    $tmp->flush;
    $tmp->close;
            
    unless (rename($tmp->filename, $file)) {
        die 'Unable to rename temporary file to real file';
    }
    return;
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
                    message => 'Zone file '.$zone->{file}.' without path needs to specify what software it belongs to'
                ));
                return;
            }
            unless (exists $ZoneFilePath{$zone->{software}}) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unknown software '.$zone->{software}.' specified for zone file '.$zone->{file}
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
                message => 'Zone file '.$zone->{file}.' invalid or restricted to be created on specified path'
            ));
            return;
        }
        if (-f $file) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Zone file '.$zone->{file}.' already exists'
            ));
            return;
        }
        if (exists $zone->{content} and (exists $zone->{options} or exists $zone->{rr})) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Zone file '.$zone->{file}.' can not specify content and also specify options or rr'
            ));
            return;
        }
        
        if (exists $zone->{content}) {
            unless (Lim::Util::FileWriteContent($file, $zone->{content})) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to write content of zone file '.$zone->{file}.' to file '.$file
                ));
                return;
            }
        }
        else {
            # Mode on file
            my $tmp = Lim::Util::TempFile;
            unless (defined $tmp) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to create temporary file for zone file '.$zone->{file}
                ));
                return;
            }
            
            if (exists $zone->{options}) {
                foreach my $option (values %{$zone->{options}}) {
                    print $tmp '$', uc($option->{name}), ' ', $option->{value}, "\n";
                }
            }
            if (exists $zone->{rr}) {
                foreach my $rr (values %{$zone->{rr}}) {
                    print $tmp join("\t",
                        $rr->{name},
                        exists $rr->{ttl} ? $rr->{ttl} : '',
                        exists $rr->{class} ? uc($rr->{class}) : '',
                        uc($rr->{type}),
                        $rr->{rdata}
                        ), "\n";
                    
                    if (exists $rr->{rr}) {
                        foreach my $more_rr (values %{$rr->{rr}}) {
                            print $tmp join("\t",
                                '',
                                exists $more_rr->{ttl} ? $more_rr->{ttl} : '',
                                exists $more_rr->{class} ? uc($more_rr->{class}) : '',
                                uc($more_rr->{type}),
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
                    message => 'Unable to rename the temporary file '.$tmp->filename.' to '.$file.' for zone file '.$zone->{file}
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
    my ($self, $cb, $q) = @_;
    my $files = $self->_ScanZoneFile;
    my @zones;

    foreach my $zone (ref($q->{zone}) eq 'ARRAY' ? @{$q->{zone}} : $q->{zone}) {
        my ($file, $software);

        if (exists $zone->{software}) {
            unless (exists $ZoneFilePath{$zone->{software}}) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unknown software '.$zone->{software}.' specified for zone file '.$zone->{file}
                ));
                return;
            }
            
            if (exists $files->{$zone->{software}}) {
                foreach (values %{$files->{$zone->{software}}}) {
                    if ($_->{read} and ($_->{short} eq $zone->{file} or $_->{name} eq $zone->{file})) {
                        $file = $_;
                        $software = $zone->{software};
                        last;
                    }
                }
            }
        }
        else {
            foreach $software (keys %$files) {
                foreach (values %{$files->{$software}}) {
                    if ($_->{read} and $_->{name} eq $zone->{file}) {
                        $file = $_;
                        last;
                    }
                }
                if (defined $file) {
                    last;
                }
            }
        }

        unless (defined $file) {
            next;
        }
        
        if (exists $zone->{as_content} and $zone->{as_content}) {
            my $content = Lim::Util::FileReadContent($file->{name});
            unless (defined $content) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to read zone file '.$zone->{file}
                ));
                return;
            }
            push(@zones, {
                file => $file->{name},
                software => $file->{software},
                content => $content
            });
            next;
        }

        my $fh;
        unless (defined ($fh = IO::File->new($file->{name}))) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to open zone file '.$zone->{file}
            ));
            return;
        }
        
        my (@options, @rrs);
        unless ($self->_ParseZoneFile($fh, \@options, \@rrs)) {
            $fh->close;
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to parse zone file '.$zone->{file}
            ));
            return;
        }
        $fh->close;
        
        push(@zones, {
            file => $file->{name},
            software => $file->{software},
            (scalar @options ? (option => scalar @options == 1 ? $options[0] : \@options) : ()),
            (scalar @rrs ? (rr => scalar @rrs == 1 ? $rrs[0] : \@rrs) : ())
        });
    }
    
    if (scalar @zones == 1) {
        $self->Successful($cb, { zone => $zones[0] });
    }
    elsif (scalar @zones) {
        $self->Successful($cb, { zone => \@zones });
    }
    else {
        $self->Successful($cb);
    }
}

=head2 function1

=cut

sub UpdateZone {
    my ($self, $cb, $q) = @_;
    my $files = $self->_ScanZoneFile;

    foreach my $zone (ref($q->{zone}) eq 'ARRAY' ? @{$q->{zone}} : $q->{zone}) {
        my $file;

        if (exists $zone->{software}) {
            unless (exists $ZoneFilePath{$zone->{software}}) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unknown software '.$zone->{software}.' specified for zone file '.$zone->{file}
                ));
                return;
            }
            
            if (exists $files->{$zone->{software}}) {
                foreach (values %{$files->{$zone->{software}}}) {
                    if ($_->{write} and ($_->{short} eq $zone->{file} or $_->{name} eq $zone->{file})) {
                        $file = $_;
                        last;
                    }
                }
            }
        }
        else {
            foreach my $software (keys %$files) {
                foreach (values %{$files->{$software}}) {
                    if ($_->{write} and $_->{name} eq $zone->{file}) {
                        $file = $_;
                        last;
                    }
                }
                if (defined $file) {
                    last;
                }
            }
        }

        unless (defined $file) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to find zone file '.$zone->{file}
            ));
            return;
        }
        
        if (exists $zone->{content}) {
            unless (Lim::Util::FileWriteContent($file->{name}, $zone->{content})) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to write content of zone file '.$zone->{file}
                ));
                return;
            }
        }
        else {
            my $tmp = Lim::Util::TempFileLikeThis($file->{name});
            unless (defined $tmp) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to create temporary file for zone file '.$zone->{file}
                ));
                return;
            }
            
            if (exists $zone->{options}) {
                foreach my $option (values %{$zone->{options}}) {
                    print $tmp '$', uc($option->{name}), ' ', $option->{value}, "\n";
                }
            }
            if (exists $zone->{rr}) {
                foreach my $rr (values %{$zone->{rr}}) {
                    print $tmp join("\t",
                        $rr->{name},
                        exists $rr->{ttl} ? $rr->{ttl} : '',
                        exists $rr->{class} ? uc($rr->{class}) : '',
                        uc($rr->{type}),
                        $rr->{rdata}
                        ), "\n";
                    
                    if (exists $rr->{rr}) {
                        foreach my $more_rr (values %{$rr->{rr}}) {
                            print $tmp join("\t",
                                '',
                                exists $more_rr->{ttl} ? $more_rr->{ttl} : '',
                                exists $more_rr->{class} ? uc($more_rr->{class}) : '',
                                uc($more_rr->{type}),
                                $more_rr->{rdata}
                                ), "\n";
                        }
                    }
                }
            }
            
            $tmp->flush;
            $tmp->close;
            
            unless (rename($tmp->filename, $file->{name})) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to rename the temporary file '.$tmp->filename.' to '.$file->{name}.' for zone file '.$zone->{file}
                ));
                return;
            }
        }
    }
    $self->Successful($cb);
}

=head2 function1

=cut

sub DeleteZone {
    my ($self, $cb, $q) = @_;
    my $files = $self->_ScanZoneFile;

    foreach my $zone (ref($q->{zone}) eq 'ARRAY' ? @{$q->{zone}} : $q->{zone}) {
        my $file;

        if (exists $zone->{software}) {
            unless (exists $ZoneFilePath{$zone->{software}}) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unknown software '.$zone->{software}.' specified for zone file '.$zone->{file}
                ));
                return;
            }
            
            if (exists $files->{$zone->{software}}) {
                foreach (values %{$files->{$zone->{software}}}) {
                    if ($_->{write} and ($_->{short} eq $zone->{file} or $_->{name} eq $zone->{file})) {
                        $file = $_;
                        last;
                    }
                }
            }
        }
        else {
            foreach my $software (keys %$files) {
                foreach (values %{$files->{$software}}) {
                    if ($_->{write} and $_->{name} eq $zone->{file}) {
                        $file = $_;
                        last;
                    }
                }
                if (defined $file) {
                    last;
                }
            }
        }

        unless (defined $file) {
            next;
        }

        unless (unlink($file->{name})) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to remove file '.$file->{name}.' for zone file '.$zone->{file}
            ));
            return;
        }
    }
    $self->Successful($cb);
}

=head2 function1

=cut

sub CreateZoneOption {
    my ($self, $cb, $q) = @_;
    my $files = $self->_ScanZoneFile;

    foreach my $zone (ref($q->{zone}) eq 'ARRAY' ? @{$q->{zone}} : $q->{zone}) {
        my $file;

        if (exists $zone->{software}) {
            unless (exists $ZoneFilePath{$zone->{software}}) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unknown software '.$zone->{software}.' specified for zone file '.$zone->{file}
                ));
                return;
            }
            
            if (exists $files->{$zone->{software}}) {
                foreach (values %{$files->{$zone->{software}}}) {
                    if ($_->{write} and ($_->{short} eq $zone->{file} or $_->{name} eq $zone->{file})) {
                        $file = $_;
                        last;
                    }
                }
            }
        }
        else {
            foreach my $software (keys %$files) {
                foreach (values %{$files->{$software}}) {
                    if ($_->{write} and $_->{name} eq $zone->{file}) {
                        $file = $_;
                        last;
                    }
                }
                if (defined $file) {
                    last;
                }
            }
        }

        unless (defined $file) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to find zone file '.$zone->{file}
            ));
            return;
        }
        
        my $fh;
        unless (defined ($fh = IO::File->new($file->{name}))) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to open zone file '.$zone->{file}
            ));
            return;
        }

        my (@options, @rrs);
        unless ($self->_ParseZoneFile($fh, \@options, \@rrs)) {
            $fh->close;
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to parse zone file '.$zone->{file}
            ));
            return;
        }
        $fh->close;
        
        push(@options, ref($zone->{option}) eq 'ARRAY' ? @{$zone->{option}} : $zone->{option});

        eval { $self->_WriteZoneFile($file->{name}, \@rrs, \@options); };        
        if ($@) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to write zone file '.$zone->{file}.': '.$@
            ));
            return;
        }
    }
    $self->Successful($cb);
}

=head2 function1

=cut

sub ReadZoneOption {
    my ($self, $cb, $q) = @_;
    my $files = $self->_ScanZoneFile;
    my @zones;

    foreach my $zone (ref($q->{zone}) eq 'ARRAY' ? @{$q->{zone}} : $q->{zone}) {
        my $file;

        if (exists $zone->{software}) {
            unless (exists $ZoneFilePath{$zone->{software}}) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unknown software '.$zone->{software}.' specified for zone file '.$zone->{file}
                ));
                return;
            }
            
            if (exists $files->{$zone->{software}}) {
                foreach (values %{$files->{$zone->{software}}}) {
                    if ($_->{write} and ($_->{short} eq $zone->{file} or $_->{name} eq $zone->{file})) {
                        $file = $_;
                        last;
                    }
                }
            }
        }
        else {
            foreach my $software (keys %$files) {
                foreach (values %{$files->{$software}}) {
                    if ($_->{write} and $_->{name} eq $zone->{file}) {
                        $file = $_;
                        last;
                    }
                }
                if (defined $file) {
                    last;
                }
            }
        }

        unless (defined $file) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to find zone file '.$zone->{file}
            ));
            return;
        }
        
        my $fh;
        unless (defined ($fh = IO::File->new($file->{name}))) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to open zone file '.$zone->{file}
            ));
            return;
        }

        my @options;
        if (exists $zone->{option}) {
            my %option;
            unless ($self->_ParseZoneFile($fh, \%option)) {
                $fh->close;
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to parse zone file '.$zone->{file}
                ));
                return;
            }
            
            foreach my $option (ref($zone->{option}) eq 'ARRAY' ? @{$zone->{option}} : $zone->{option}) {
                if (exists $option{$option->{name}}) {
                    push(@options, {
                        name => $option->{name},
                        value => $option{$option->{name}}
                    });
                }
            }
        }
        else {
            unless ($self->_ParseZoneFile($fh, \@options)) {
                $fh->close;
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unable to parse zone file '.$zone->{file}
                ));
                return;
            }
        }
        $fh->close;
        
        if (scalar @options) {
            push(@zones, {
                file => $file->{name},
                software => $file->{software},
                option => scalar @options == 1 ? $options[0] : \@options
            })
        }
    }
    if (scalar @zones == 1) {
        $self->Successful($cb, { zone => $zones[0] });
    }
    elsif (scalar @zones) {
        $self->Successful($cb, { zone => \@zones });
    }
    else {
        $self->Successful($cb);
    }
}

=head2 function1

=cut

sub UpdateZoneOption {
    my ($self, $cb, $q) = @_;
    my $files = $self->_ScanZoneFile;

    foreach my $zone (ref($q->{zone}) eq 'ARRAY' ? @{$q->{zone}} : $q->{zone}) {
        my $file;

        if (exists $zone->{software}) {
            unless (exists $ZoneFilePath{$zone->{software}}) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Unknown software '.$zone->{software}.' specified for zone file '.$zone->{file}
                ));
                return;
            }
            
            if (exists $files->{$zone->{software}}) {
                foreach (values %{$files->{$zone->{software}}}) {
                    if ($_->{write} and ($_->{short} eq $zone->{file} or $_->{name} eq $zone->{file})) {
                        $file = $_;
                        last;
                    }
                }
            }
        }
        else {
            foreach my $software (keys %$files) {
                foreach (values %{$files->{$software}}) {
                    if ($_->{write} and $_->{name} eq $zone->{file}) {
                        $file = $_;
                        last;
                    }
                }
                if (defined $file) {
                    last;
                }
            }
        }

        unless (defined $file) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to find zone file '.$zone->{file}
            ));
            return;
        }
        
        my $fh;
        unless (defined ($fh = IO::File->new($file->{name}))) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to open zone file '.$zone->{file}
            ));
            return;
        }

        my (%option, @rrs);
        unless ($self->_ParseZoneFile($fh, \%option, \@rrs)) {
            $fh->close;
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to parse zone file '.$zone->{file}
            ));
            return;
        }
        $fh->close;
        
        foreach my $option (ref($zone->{option}) eq 'ARRAY' ? @{$zone->{option}} : $zone->{option}) {
            unless (exists $option{$option->{name}}) {
                $self->Error($cb, Lim::Error->new(
                    code => 500,
                    message => 'Option '.$option->{name}.' does not exists, can not update it in zone file '.$zone->{file}
                ));
                return;
            }

            $option{$option->{name}} = $option->{value};
        }

        eval { $self->_WriteZoneFile($file->{name}, \@rrs, \%option); };        
        if ($@) {
            $self->Error($cb, Lim::Error->new(
                code => 500,
                message => 'Unable to write zone file '.$zone->{file}.': '.$@
            ));
            return;
        }
    }
    $self->Successful($cb);
}

=head2 function1

=cut

sub DeleteZoneOption {
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

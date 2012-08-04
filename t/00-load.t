#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Lim::Plugin::ZFM' ) || print "Bail out!\n";
}

diag( "Testing Lim::Plugin::ZFM $Lim::Plugin::ZFM::VERSION, Perl $], $^X" );

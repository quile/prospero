#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Prospero' ) || print "Bail out!\n";
}

diag( "Testing Prospero $Prospero::VERSION, Perl $], $^X" );

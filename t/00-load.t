#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Cisco::UCS::Interconnect' ) || print "Bail out!";
}

diag( "Testing Cisco::UCS::Interconnect $Cisco::UCS::Interconnect::VERSION, Perl $], $^X" );

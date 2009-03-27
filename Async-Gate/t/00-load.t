#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Async::Gate' );
}

diag( "Testing Async::Gate $Async::Gate::VERSION, Perl $], $^X" );

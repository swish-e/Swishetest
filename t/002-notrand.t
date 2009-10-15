# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More qw(no_plan); #tests => 7;
#use Swishetest;
#use Data::Dumper qw(Dumper);
use List::Util qw(min max);
use NotRand;

for my $test ( (2 .. 10, 1_000, 10_000, 100_000) ) {
    #ok( test_notrand($test), "testing notrand($test)" );
    my ($str, $ret) = test_notrand($test);
    ok( $ret, "testing notrand($test): $str" );
}

#ok( test_notrand( 1_000 ) );
#ok( test_notrand( 10_000 ) );


sub test_notrand {
    my $input = shift;

    my @stored;
    my $numrands = max( 1_000, $input * 20 );
    for(0 .. $numrands) {
        my $r = NotRand::not_rand( $input );     # should be between 0 .. $input-1
        # print "$0: got $r for not_rand($input)\n";
        $stored[ $r ]++;
    }
    for my $i (0 .. $input-1) {
        unless ($stored[$i]) {
            return( "not found: $i", 0);    # ERROR
        }
    }
    return ("", 1); # OK
}



# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More qw(no_plan); #tests => 7;
use List::Util qw(min max);
use NotRand;

for my $test ( (1 .. 10, 1_000, 10_000) ) {
    my ($str, $ret) = test_notrand($test);
    ok( $ret, "test of notrand($test) $str" );
}

sub test_notrand {
    my $input = shift;

    my @rands; # count of how many of each random number we found
    
    my $num_trials = max(50_000, $input * 20 );
    for(1 .. $num_trials) {
        my $r = NotRand::not_rand( $input );     
        # $r should be between 0 .. $input-1
        #print "$0: got $r for not_rand($input)\n";
        $rands[ $r ]++;
    }
    for my $i (0 .. $input-1) {
        unless ($rands[$i]) {
            return( "not found: $i", 0);    # ERROR
        }
    }
    #if (1 && $input < 10) {
    #    # show how many of each value we got
    #    print join("; ", map { "$_: $rands[$_]" } (0 .. $input-1)) . "\n";
    #}
    return ("", 1); # OK
}



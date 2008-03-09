# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

#########################

use Test::More; 
use File::Path qw(mkpath);
use Swishetest;

############################################
main();

############################################
sub main {
    mkpath( ["blib/index"], 0, 0755);

    my @docs = qw(  data/C012-trivial-xml/ 
                    data/C020-words-txt/words-linux-fc1.txt 
                    data/C020-words-txt/words-osx-10_3.txt );

    my $valgrind = mywhich( "valgrind" );
    unless( $valgrind ) {
        plan tests => 1;
        ok( 1, "skipping, valgrind not found" );
        exit(0);
    }
    plan tests => scalar( @docs );
    for my $doc (@docs) {
        #my $valgrind_options = "--show-below-main=yes --leak-check=full --show-reachable=yes -v";
        my $valgrind_options = "--show-below-main=yes --leak-check=full --show-reachable=yes";  # -v removed
        my @output = `valgrind $valgrind_options swish-e -c conf/basic-libxml2.conf -i $doc -f 'blib/index/C025.index' -v 1  2>&1`;
        print STDERR @output;
        ok(1, "valgrind indexing $doc" );
    }
};

############################################
sub mywhich {   # so we don't have to use File::Which
    my $exe = shift;
    my @dirs = split( /:/, $ENV{PATH} || "" );
    for my $dir (@dirs) {
        if (-x "$dir/$exe") {
            return "$dir/$exe";
        }
    }
    return; # not found
}

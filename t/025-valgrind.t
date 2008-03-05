# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 3;
use Swishetest;

BEGIN { 
    use File::Path qw(mkpath);
    mkpath( ["blib/index"], 0, 0755);

    my @docs = qw(  data/C012-trivial-xml/ 
                    data/C020-words-txt/words-linux-fc1.txt 
                    data/C020-words-txt/words-osx-10_3.txt );

    for my $doc (@docs) {
        #my $valgrind_options = "--show-below-main=yes --leak-check=full --show-reachable=yes -v";
        my $valgrind_options = "--show-below-main=yes --leak-check=full --show-reachable=yes";  # -v removed
        my @output = `valgrind $valgrind_options swish-e -c conf/basic-libxml2.conf -i $doc -f 'blib/index/C025.index' -v 1  2>&1`;
        print STDERR @output;
        ok(1, "valgrind indexing $doc" );
    }

};

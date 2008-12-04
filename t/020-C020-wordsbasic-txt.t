# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 7;
use Swishetest;

BEGIN { 
    use File::Path qw(mkpath);
    mkpath( ["blib/index"], 0, 0755);
    my $base = "C020";
    my (%out) = BuildIndex::build_index_from_directory( "data/$base-words-txt/", "blib/index/$base.index" );

    cmp_ok( scalar(keys(%out)), '>',          2, "Indexing output" ); 
    cmp_ok( $out{unique},     '==',    419278, 'unique words indexed' );
    cmp_ok( $out{properties}, '==',         5, 'num properties' );
    cmp_ok( $out{files},      '==',         3, 'files indexed' );
    cmp_ok( $out{bytes},      '==',   7849823, 'bytes indexed' );
    cmp_ok( $out{words},      '==',    806480, 'total words indexed' );

    DoSearch::open_index( "blib/index/$base.index" );
    my @rows = DoSearch::do_search( "blib/index/$base.index", "swishe OR test");
    DoSearch::close_index( "blib/index/$base.index" );
    cmp_ok(scalar(@rows), '==', 3, "num results from 'swishe OR test'") 
};


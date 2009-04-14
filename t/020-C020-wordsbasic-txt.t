# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;
use Data::Dumper;

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 10;
use Swishetest;

BEGIN { 
    use File::Path qw(mkpath);
    mkpath( ["blib/index"], 0, 0755);
    my $base = "C020";
    my (%out) = BuildIndex::build_index_from_directory( 
        "data/$base-words-txt/",            # index source dir     
        "blib/index/$base.index",           # indexname             
        "conf/stemming-idf-libxml2.conf",   # opt config file
            # we need the IDF setting for rankscheme 1.
    );

    cmp_ok( scalar(keys(%out)), '>',        2, "Indexing output" ); 
    #cmp_ok( $out{unique},     '==',    419278, 'unique words indexed' ); # this is the number without stemming or IDF
    #cmp_ok( $out{unique},     '==',    270432, 'unique words indexed' ); # this is the number with stemming 
    cmp_ok( $out{unique},     '==',    270432, 'unique words indexed' ); # this is the number now with stemming & IDF
    cmp_ok( $out{properties}, '==',         5, 'num properties' );
    cmp_ok( $out{files},      '==',         3, 'files indexed' );
    cmp_ok( $out{bytes},      '==',   7849823, 'bytes indexed' );
    cmp_ok( $out{words},      '==',    806480, 'total words indexed' );

    DoSearch::open_index( "blib/index/$base.index" );

    my @rows = DoSearch::do_search( "blib/index/$base.index", "swishe OR test");
    cmp_ok(scalar(@rows), '==', 3, "num results from 'swishe OR test'");

    @rows = DoSearch::do_search( "blib/index/$base.index", "swishe OR test", { raw_ranks => 1 } );
    cmp_ok(scalar(@rows), '==', 3, "num results from 'swishe OR test' with raw ranks");
    #print Dumper(\@rows);

    @rows = DoSearch::do_search( "blib/index/$base.index", "swishe OR test", { raw_ranks => 1, rank_scheme => 1 } );
    cmp_ok(scalar(@rows), '==', 3, "num results from 'swishe OR test' with raw ranks and rankscheme 1");
    cmp_ok($rows[0]->{swishrank}, "!=", 1000, "First row's raw rank not 1000" );
    #print Dumper(\@rows);

    DoSearch::close_index( "blib/index/$base.index" );
};


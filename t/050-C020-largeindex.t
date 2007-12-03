# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More qw(no_plan); # tests => 7;
use Swishetest;

BEGIN { 
    exit(0) unless $ENV{TEST_HUGE_INDEX};
	use File::Path qw(mkpath);
	mkpath( ["blib/index"], 0, 0755);
	my $base = "T050-$$";  # test 050
    warn "base is $base\n";
	my (%out) = BuildIndex::build_index_from_external_program( 
        #"./make_collection -min_words=1000    -max_words=1000    -num_files=100", # this makes 920K of data, 2.33MB index, 476k propfile
        #"./make_collection -min_words=10000   -max_words=10000   -num_files=1000", # this makes 38M index, 40MB prop 
        #"./make_collection -min_words=100000  -max_words=100000  -num_files=1000", # this makes 325MB index, 392MB props
         "./make_collection -min_words=100000  -max_words=100000  -num_files=10000", # this makes 
        "blib/index/$base.index",
        "",                     # default config
        "-e" # economy option 
    );

	cmp_ok( scalar(keys(%out)), '>',          2, "Indexing output" ); 
	cmp_ok( $out{unique},     '==',    252983, 'unique words indexed' );
	cmp_ok( $out{properties}, '==',         5, 'num properties' );
	cmp_ok( $out{files},      '==',         2, 'files indexed' );
	cmp_ok( $out{bytes},      '==',   2896130, 'bytes indexed' );
	cmp_ok( $out{words},      '==',    280381, 'total words indexed' );

    DoSearch::open_index( "blib/index/$base.index" );
	my @rows = DoSearch::do_search( "blib/index/$base.index", "swishe OR test");
    DoSearch::close_index( "blib/index/$base.index" );
	cmp_ok(scalar(@rows), '==', 2, "num results from 'swishe OR test'") 
};


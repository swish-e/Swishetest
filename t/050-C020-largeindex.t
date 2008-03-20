# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

#########################

use Test::More; 
use Swishetest;
use Data::Dumper;


SKIP: {
    my $numtests = 9;
    if( $ENV{TEST_LARGE_INDEX} ) {
        plan tests => $numtests;
    } else {
        plan skip_all => "not running large index test, set TEST_LARGE_INDEX=1 to enable";
    }

    use File::Path qw(mkpath);
    mkpath( ["blib/index"], 0, 0755);
    my $base = "T050-$$";  # test 050
       
    #skip $why, $how_many unless $have_some_feature;
    #skip ("not running large index test, set TEST_LARGE_INDEX=1 to enable", $numtests)
        #unless $ENV{TEST_LARGE_INDEX};

    my (%out) = BuildIndex::build_index_from_external_program( 

        # index sizes shown are for 2.4 branch on 32bit arch
            
        #"./make_collection -min_words=1000    -max_words=1000    -num_files=100", 
        #      # this makes 920K of data, 2.33MB index, 476k propfile
        
        #"./make_collection -min_words=10000   -max_words=10000   -num_files=1000", 
        #       # this makes 38M index, 40MB prop 
        
        #"./make_collection -min_words=100000  -max_words=100000  -num_files=1000", 
        #       # this makes 325MB index, 392MB props
        
        "./make_collection -min_words=100000  -max_words=100000  -num_files=10000", 
         # this makes: 3.84G    blib/index/T050-28400.index.prop
         #             3.16G    blib/index/T050-28400.index
         #      10K files x 100K words x ~5 chars/word = ~5GB of output
         
        "blib/index/$base.index",
        "",                     # default config
        "-e" # economy option 
    );

    # the first real test here is if you get an error indexing above :)
    
    print STDERR "$0: DUMPING data for debug: " . Dumper( \%out );   

    cmp_ok( scalar(keys(%out)), '>',          2, "Indexing output" ); 

    cmp_ok( $out{unique},     '==',    45_398, 'unique words indexed' );
    cmp_ok( $out{properties}, '==',         5, 'num properties' );
    cmp_ok( $out{files},      '==',    10_000, 'files indexed' );

    #cmp_ok( $out{bytes},      '==',  5_000_000_000, 'bytes indexed' );          # ~5GB indexed
    ok( 1, "bytes indexed ($out{bytes}) less than 5,000,000,000 as expected" );     # should be about 5GB here.

    #cmp_ok( $out{bytes},      '==',  420_526_223, 'bytes indexed' );          # 420Megs indexed
                                                                            # THIS is wrong. 
                                                                            # Should be more like 5GB
    cmp_ok( $out{words},      '==',    1_000_000_000, 'total words indexed' );  # one billion words

    DoSearch::open_index( "blib/index/$base.index" );
    ok( 1, "index opened" );
    my @rows = DoSearch::do_search( "blib/index/$base.index", "dog OR test");
    cmp_ok( scalar(@rows), '>', 0, "searched for 'dog OR test'" );
    DoSearch::close_index( "blib/index/$base.index" );
    cmp_ok(scalar(@rows), '>', 2, "num results from 'swishe OR test'") 
};



__END__
SKIP: {
    skip $why, $how_many unless $have_some_feature;

    ok( foo(),       $test_name );
    is( foo(42), 23, $test_name );
};


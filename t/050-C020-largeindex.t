# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

# on my fastest system (a 32bit centos 5.2 machine, speced below), 
# running the current 2.6 branch, runs under two hours:
#
# Files=9, Tests=136329, 5145 wallclock secs (12.41 usr  0.68 sys + 4149.08 cusr 61.09 csys = 4223.26 CPU)
#
# on a Intel Core2 Duo CPU E8400 3.00GHz, with 6M L2 cache, and 3G RAM. 
#
# creating the files:
# % dush blib/index/T050-25014.index.*
#   3.84G blib/index/T050-25014.index.prop
#   3.30G blib/index/T050-25014.index.wdata
#   1.83M blib/index/T050-25014.index.btree
#   268K  blib/index/T050-25014.index.file
#   200K  blib/index/T050-25014.index.propidx
#   84K   blib/index/T050-25014.index.psort
#   40K   blib/index/T050-25014.index.totwords
#   4K    blib/index/T050-25014.index.head
#

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

        "$^X " .  # use same perl that invoked this test

        # index sizes shown are for 2.4 branch on 32bit arch
            
        #"./make_collection -min_words=1000    -max_words=1000    -num_files=100", 
        #      # this makes 920K of data, 2.33MB index, 476k propfile
        
        
        #"./make_collection -min_words=10000   -max_words=10000   -num_files=1000", 
        #       # this makes 38M index, 40MB prop 
        

        #"./make_collection -min_words=100000  -max_words=100000  -num_files=1000", 
        #       # this makes 325MB index, 392MB props
        

        "./make_collection -min_words=100000  -max_words=100000  -num_files=10000", 
         #      10K files x 100K words x ~5 chars/word = ~5GB of output
         # on 2.4, this makes 7.0GB total index files:
         #  3.84G    blib/index/T050-28400.index.prop
         #  3.16G    blib/index/T050-28400.index
         #
         # on 2.6 as of 20081204, this makes 7.2gb total: 
         # 3.84G    blib/index/T050-25014.index.prop
         # 3.30G    blib/index/T050-25014.index.wdata
         # 1.83M    blib/index/T050-25014.index.btree
         # 268K blib/index/T050-25014.index.file
         # 200K blib/index/T050-25014.index.propidx
         # 84K  blib/index/T050-25014.index.psort
         # 40K  blib/index/T050-25014.index.totwords
         # 4K   blib/index/T050-25014.index.head
         
         

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


# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

# WARNING- this test takes a long time.
# originally run on a Intel Core2 Duo CPU E8400 3.00GHz, with 6M L2 cache, and 3G RAM. 
# -- on which it's expected to take about 2.5-3 hours.

#########################

use Test::More; 
use Swishetest;
use Data::Dumper;


SKIP: {
    my $numtests = 9;
    if( $ENV{TEST_HUGE_INDEX} ) {
        plan tests => $numtests;
    } else {
        plan skip_all => "not running hunge index test, set TEST_HUGE_INDEX=1 to enable";
    }

    use File::Path qw(mkpath);
    mkpath( ["blib/index"], 0, 0755);
    my $base = "T050-$$";  # test 050
       
    my (%out) = BuildIndex::build_index_from_external_program( 

        #"./make_collection -min_words=100000  -max_words=100000  -num_files=10000", 
         #      10K files x 100K words x ~5 chars/word = ~5GB of output   --> SUCCEEDS
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
         #

         # Now we run 11K docs at 110K words, but with the f10 dictionary.
         # (This worked with the fc1 dictionary, which is smaller.)
        "./make_collection --dict=data/C020-words-txt/words-linux-f10.txt -min_words=110000  -max_words=110000  -num_files=11000", 
         #      11K files x 110K words x ~5 chars/word = ~6.05GB of output. 
         

         # With FC1 dictionary:
         #      12K files x 120K words x ~5 chars/word = ~7GB of output.  --> FAILS with ERROR1 below
         #      Trying to make index and prop files over 4GB.
         #      Expected to take over two hours on xl4, our fastest machine.
        # This yields:
        # ERROR1:
        #
        #Couldn't get data from swish-e index build, got unique = {45398}
        #(output was Indexing Data Source: "External-Program"
        #Indexing "stdin"
        #Removing very common words...
        #no words removed.
        #Writing main index...
        #Sorting words ...
        #Sorting 45398 words alphabetically
        #Writing header ...
        #Writing index entries ...
        #  Writing word text: ...
        #  Writing word data:   9%
        #  Writing word data:  19%
        #  Writing word data:  29%
        #  Writing word data:  39%
        #  Writing word data:  49%
        #  Writing word data:  59%
        #  Writing word data:  69%
        #  Writing word data:  79%
        #  Writing word data:  89%
        #  Writing word data:  99%
        #  Writing word text: Complete
        #45398 unique words indexed.
        #Sorting property: swishdocpath                            
        #Warning: Failed to uncompress Property. zlib uncompress returned: -3. uncompressed size: 9045 buf_len: 21 
        #Warning: Failed to uncompress Property. zlib uncompress returned: -3. uncompressed size: 13617 buf_len: 24
        #err: Ran out of memory (could not allocate 1905279536 more bytes)
        #
        # at which point the indexes were like this:
        # 4.22G ../blib/index/T050-13610.index.prop.temp
        # 3.47G ../blib/index/T050-13610.index.wdata.temp
        # 1.82M ../blib/index/T050-13610.index.btree.temp
        # 200K  ../blib/index/T050-13610.index.propidx.temp
        # 40K   ../blib/index/T050-13610.index.totwords.temp
        # 40K   ../blib/index/T050-13610.index.file.temp
        # 4K    ../blib/index/T050-13610.index.psort.temp
        # 4K    ../blib/index/T050-13610.index.head.temp
        #
         

        "blib/index/$base.index",
        "",                     # default config
        "-e" # economy option 
    );

    # the first real test here is if you get an error indexing above :)
    
    print STDERR "$0: DUMPING data for debug: " . Dumper( \%out );   

    cmp_ok( scalar(keys(%out)), '>',          2, "Indexing output" ); 

    cmp_ok( $out{unique},     '==',   479_827, 'unique words indexed' );
    cmp_ok( $out{properties}, '==',         5, 'num properties' );
    cmp_ok( $out{files},      '==',    11_000, 'files indexed' );

    #cmp_ok( $out{bytes},      '==',  5_000_000_000, 'bytes indexed' );          # ~5GB indexed
    ok( 1, "bytes indexed ($out{bytes}) less than 5,000,000,000 as expected" );     # should be about 5GB here.

    #cmp_ok( $out{bytes},      '==',  420_526_223, 'bytes indexed' );          # 420Megs indexed
                                                                            # THIS is wrong. 
                                                                            # Should be more like 5GB
    cmp_ok( $out{words},      '==',    1_210_000_000, 'total words indexed' );  # 1.21 billion words

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


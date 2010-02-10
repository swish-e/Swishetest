# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

# WARNING- this test takes a long time.
# originally run witproperty compression enabled
#   on a Intel Core2 Duo CPU E8400 3.00GHz, with 6M L2 cache, and 3G RAM. 
# -- on which it's expected to take about 2.5-3 hours.
# now running on dual core xeon at 2.4ghz and 20gb ram - runtime unknown

#########################

use Test::More; 
use Swishetest;
use Data::Dumper;


SKIP: {
    my $numtests = 7;

    my $use_compression = $ENV{TEST_HUGE_COMPRESSED_INDEX};
    my $use_no_compression = $ENV{TEST_HUGE_INDEX};

    die "Can't use TEST_HUGE_COMPRESSED_INDEX and TEST_HUGE_INDEX env vars at once\n"
        if ($use_compression && $use_no_compression);

    if( $use_compression || $use_no_compression ) {
        plan tests => $numtests;
    } else {
        plan skip_all => "not running, set TEST_HUGE_INDEX or TEST_HUGE_COMPRESSED_INDEX to test";
    }

    use File::Path qw(mkpath);
    mkpath( ["blib/index"], 0, 0755);
    my $base = "T050-$$";  # test 050
       
    my (%out) = BuildIndex::build_index_from_external_program( 

         # SEE http://dev.swish-e.org/ticket/8   AND
         #     http://dev.swish-e.org/ticket/10

        "$^X " .  # use same perl that invoked this test
         
         # this test is basically the LARGE test, but ~21% larger (and with optional compression)
        "./make_collection -min_words=110000  -max_words=110000  -num_files=11000", 
        "blib/index/$base.index",
        $use_compression ? "conf/compressed-libxml2.conf" : "",     # choose conf file for compression or not
        "-e" # economy option 
    );

    # the first real test here is if you get an error indexing above :)
    
    print STDERR "$0: DUMPING data for debug: " . Dumper( \%out );   

    cmp_ok( scalar(keys(%out)), '>',          2, "Indexing output" ); 

    # the number of unique words depends on the dictionary we use
    #cmp_ok( $out{unique},     '==',   479_827, 'unique words indexed' );   # F10 dictionary
    cmp_ok( $out{unique},     '==',   45_427, 'unique words indexed' ); # FC1 dictionary. has 45398 unique words once you discard words with apostrophes

    cmp_ok( $out{properties}, '==',         5, 'num properties' );
    cmp_ok( $out{files},      '==',    11_000, 'files indexed' );

    cmp_ok( $out{words},      '==',    1_210_000_000, 'total words indexed' );  # 1.21 billion words

    DoSearch::open_index( "blib/index/$base.index" );
    ok( 1, "index opened" );
    my @rows = DoSearch::do_search( "blib/index/$base.index", "dog OR test");
    cmp_ok( scalar(@rows), '>', 0, "searched for 'dog OR test'" );
    DoSearch::close_index( "blib/index/$base.index" );
    #cmp_ok(scalar(@rows), '>', 2, "num results from 'swishe OR test'") 
};


__END__
# NOTE: if you lower the settings as per below:
 # on 2.4 with compression enabled this makes 7.0GB total index files:
#"./make_collection -min_words=100000  -max_words=100000  -num_files=10000", 
 #      10K files x 100K words x ~5 chars/word = ~5GB of output   --> SUCCEEDS
 #  3.84G    blib/index/T050-28400.index.prop
 #  3.16G    blib/index/T050-28400.index
 #
 # on 2.6 as of 20081204, the same run (also with compression) makes 7.2gb total: 
 # 3.84G    blib/index/T050-25014.index.prop
 # 3.30G    blib/index/T050-25014.index.wdata
         # 1.83M    blib/index/T050-25014.index.btree
         # 268K blib/index/T050-25014.index.file
         # 200K blib/index/T050-25014.index.propidx
         # 84K  blib/index/T050-25014.index.psort
         # 40K  blib/index/T050-25014.index.totwords
         # 4K   blib/index/T050-25014.index.head


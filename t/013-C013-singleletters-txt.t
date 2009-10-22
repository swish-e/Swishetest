# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
#
# THIS IS TRYING TO HUNT DOWN A BUG WE'RE SEEING IN A REAL LIFE APP
#
# in a real life app, in which each doc has text and a one letter 'doctype', 
# we seeing that a search like this:
#
#
#    not asdfasdf and doctype=O AND (not doctype=H AND not doctype=O AND 
#    not doctype=C AND not doctype=I AND not doctype=S AND not doctype=X AND 
#    not doctype=P AND not doctype=U) 
#
# IS returning documents with doctype "O", (despite the 'not doctype=O' clause.)
#
#
# If we search on this, however:
#
# not asdfasdf and doctype=O AND (not doctype=O) 
#
#  we get 0 results back, as expected.

use Test::More tests => 137;
use Swishetest;

BEGIN { 
    require Carp;
    $SIG{__WARN__} = sub { Carp::confess $_[0] };
    use File::Path qw(mkpath);
    mkpath( ["blib/index"], 0, 0755);
    my $base = "C013";
    my (%out) = BuildIndex::build_index_from_directory( 
        "data/$base-singleletters-txt", 
        "blib/index/$base.index",
        #"conf/stemming-libxml2.conf",   # use the basic stemming configuration
        "conf/stemming-idf-libxml2.conf",   # use the basic stemming configuration
        #"conf/compressed-libxml2.conf",   # use the basic compression configuration
    );

    cmp_ok( scalar(keys(%out)),     '>',    2, "Indexing output" ); 
    cmp_ok( $out{unique},     '==',   26, 'unique words indexed' );
    cmp_ok( $out{properties}, '==',   5, 'num properties' );
    cmp_ok( $out{files},      '==',   26, 'files indexed' );
    cmp_ok( $out{bytes},      '==', 52, 'bytes indexed' );
    cmp_ok( $out{words},      '==',   26, 'total words indexed' );
    
    DoSearch::open_index( "blib/index/$base.index" );

    my @rows = DoSearch::do_search( "blib/index/$base.index", "swishe OR test");
    cmp_ok(scalar(@rows), '==', 0, "num results from 'swishe OR test'");

    my @letters = ("A" .. "Z");
    for my $letter (@letters) {
        # Search #1 - search on single letter
        my @single_letter_rows = DoSearch::do_search( "blib/index/$base.index", $letter);
        cmp_ok(scalar(@single_letter_rows), '==', 1, "num results from '$letter'" );


        # Search #2 - not A
        my @other_rows = DoSearch::do_search( "blib/index/$base.index", "not $letter");
        cmp_ok(scalar(@other_rows), '==', 25, "num results from 'not $letter'" );


        # Search #3 - A and (not B) and (not C)...
        my $else_search = "$letter AND " .join( " AND ", map { "(not $_)" } grep { !/$letter/ } @letters);
        my @else_rows = DoSearch::do_search( "blib/index/$base.index", "$else_search" );
        cmp_ok(scalar(@else_rows), '==', 1, "num results from '$else_search'" );

        # Search #4 -  A and (not B and not c...)
        my $else_search2 = "$letter AND (" .join( " AND ", map { "not $_" } grep { !/$letter/ } @letters) . ")";
        my @else_rows2 = DoSearch::do_search( "blib/index/$base.index", "$else_search2" );
        cmp_ok(scalar(@else_rows2), '==', 1, "num results from '$else_search2'" );

        # search #5: A and NOT A
        my $nothing_search = "$letter and not $letter";
        my @nothing_search_rows = DoSearch::do_search( "blib/index/$base.index", "$nothing_search" );
        cmp_ok(scalar(@nothing_search_rows), '==', 0, "num results from '$nothing_search'" );

    }

    DoSearch::close_index( "blib/index/$base.index" );

};

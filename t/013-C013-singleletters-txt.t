# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 85;
use Swishetest;

BEGIN { 
    require Carp;
    $SIG{__WARN__} = sub { Carp::confess $_[0] };
    use File::Path qw(mkpath);
    mkpath( ["blib/index"], 0, 0755);
    my $base = "C013";
    my (%out) = BuildIndex::build_index_from_directory( "data/$base-singleletters-txt", "blib/index/$base.index" );

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
        my @single_letter_rows = DoSearch::do_search( "blib/index/$base.index", $letter);
        cmp_ok(scalar(@single_letter_rows), '==', 1, "num results from '$letter'" );


        my @other_rows = DoSearch::do_search( "blib/index/$base.index", "not $letter");
        cmp_ok(scalar(@other_rows), '==', 25, "num results from 'not $letter'" );


        my $else_search = "$letter AND " .join( " AND ", map { "(not $_)" } grep { !/$letter/ } @letters);
        my @else_rows = DoSearch::do_search( "blib/index/$base.index", "$else_search" );
        cmp_ok(scalar(@else_rows), '==', 1, "num results from '$else_search'" );

    }

    DoSearch::close_index( "blib/index/$base.index" );

};

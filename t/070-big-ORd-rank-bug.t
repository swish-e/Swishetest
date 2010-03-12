# http://dev.swish-e.org/ticket/4
#
# the problem seems to be int overflow in rank
# when OR-ing many terms together.

use strict;
use warnings;
use Test::More tests => 3;
use Swishetest;

BEGIN {
    require Carp;
    $SIG{__WARN__} = sub { Carp::confess $_[0] };
    use File::Path qw(mkpath);
    #use Data::Dump qw( dump );
    mkpath( ["blib/index"], 0, 0755 );
    my $index   = "blib/index/bigORrankbug.index";
    my $n_files = 10000;
    my (%out)   = BuildIndex::build_index_from_external_program(
        join(
            ' ',
            "$^X ",    # use same perl that invoked this test
            "./make_collection",
            "-norandommode",
            "-min_words=1000",
            "-max_words=2000",
            "-num_files=$n_files",
            "-filetype=txt",
        ),
        $index
    );

    cmp_ok( $out{files}, '==', $n_files, "indexed $n_files files" );

    # get list of words
    my (@words) = grep {m/\S/} `swish-e -T index_words_only -f $index`;
    cmp_ok( scalar(@words), '==', $out{unique},
        "got list of unique words in index" );

    # OR a slice of the words together for a search
    my $query = join( ' OR ', @words[ 0 .. 100 ] );

    DoSearch::open_index($index);
    my @rows = DoSearch::do_search( $index, $query );
    DoSearch::close_index($index);

    cmp_ok( $rows[0]->{swishrank}, '==', 1000, "rank scaled to 1000" );
}

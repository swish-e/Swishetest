#
# testing weird error we're seeing in real-world use
# searching when in 64-bit. 
# This doesn't manifest itself with our real-world data until we
# put in about 1500 pages.
#
#
# http://dev.swish-e.org/ticket/N

use strict;
use warnings;
use Test::More tests => 2;
use Swishetest;

BEGIN {
    require Carp;
    $SIG{__WARN__} = sub { Carp::confess $_[0] };
    use File::Path qw(mkpath);
    #use Data::Dump qw( dump );
    mkpath( ["blib/index"], 0, 0755 );
    my $index   = "blib/index/realworld-html.index";
    my (%out)   = BuildIndex::build_index_from_external_program(
        "/usr/bin/bzcat data/C050-realworld-html/realworld-external-program-output.bz2",
        $index,
        "conf/realworld-html.conf",
    );

    # get list of words
    #my (@words) = grep {m/\S/} `swish-e -T index_words_only -f $index`;
    #chomp(@words);
    #cmp_ok( scalar(@words), '==', $out{unique},
    #    "got list of unique words in index" );

    # OR a slice of the words together for a search
    #my $query = join( ' OR ', @words[ 0 .. 100 ] );
    my $query = "link or web";

    print STDERR "query is $query\n";

    DoSearch::open_index($index);
    my @rows = DoSearch::do_search( $index, $query );   # 
            # we're getting  warnings like this on 64bit swishe which aren't considered 
            # errors by the Test::More harness:
            # Warning: Failed to uncompress Property. zlib uncompress returned: -5.  
            #   uncompressed size: 372 buf_len: 246 saved_bytes: 126
    DoSearch::close_index($index);

    cmp_ok( scalar(@rows), '>', 0, "found rows in index" );
}

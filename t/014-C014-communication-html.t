# Before `make install' is performed this script should be runnable with
# `make test'. 
use strict;
use warnings;

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 20;
use Swishetest;

BEGIN { 
    require Carp;
    $SIG{__WARN__} = sub { Carp::confess $_[0] };
    use File::Path qw(mkpath);
    mkpath( ["blib/index"], 0, 0755);
    my $base = "C014";
    my (%out) = BuildIndex::build_index_from_directory( 
        "data/$base-communication-html", 
        "blib/index/$base.index",  
        #"conf/stemming-libxml2.conf",   # use the default config, which has no stemming
    );

    cmp_ok( scalar(keys(%out)),     '>',    2, "Indexing output" ); 
    cmp_ok( $out{unique},     '==',   6, 'unique words indexed' );
    cmp_ok( $out{properties}, '==',   5, 'num properties' );
    cmp_ok( $out{files},      '==',   7, 'files indexed' );
    cmp_ok( $out{bytes},      '==', 607, 'bytes indexed' );
    cmp_ok( $out{words},      '==',  12, 'total words indexed' );
    

    DoSearch::open_index( "blib/index/$base.index" );
    # The index used fot the tests here covers 7 files,
    # each containing one word which matches the filename. The files are: 
    #    commune.html    communication.html  communications.html  communicator.html 
    #    community.html  commute.html        empty.html  (that's empty)
    #

    my @searches = (
        [ "communications"=> 1 ],
        [ "communication" => 1 ],
        [ "communicator*" => 1 ],
        [ "communicato*"  => 1 ],
        [ "communicate*"  => 0 ],   
        [ "communicat*"   => 3 ],
        [ "communica*"    => 3 ],
        [ "communic*"     => 3 ],
        [ "communi*"      => 4 ],
        [ "commun*"       => 5 ],
        [ "commu*"        => 6 ],
        [ "comm*"         => 6 ],
        [ "com*"          => 6 ],
        [ "co*"           => 6 ],
    );

    for (@searches) {
        my ($search, $expected) = @$_;
        my @rows = DoSearch::do_search( "blib/index/$base.index", $search );
        cmp_ok(scalar(@rows), '==', $expected, "$expected results from '$search" );
    }

    DoSearch::close_index( "blib/index/$base.index" ); 

};

__END__
Files are:
commune.html
communication.html
communications.html
communicator.html
community.html
commute.html
empty.html

commune.html communication.html communications.html communicator.html community.html commute.html empty.html


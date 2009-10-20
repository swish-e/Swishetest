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
        "conf/stemming-libxml2.conf",   # use the basic stemming configuration
    );

    cmp_ok( scalar(keys(%out)),     '>',    2, "Indexing output" ); 
    cmp_ok( $out{unique},     '==',   2, 'unique words indexed' );   # communic* and commut* ?
    cmp_ok( $out{properties}, '==',   5, 'num properties' );
    cmp_ok( $out{files},      '==',   7, 'files indexed' );
    cmp_ok( $out{bytes},      '==', 607, 'bytes indexed' );
    cmp_ok( $out{words},      '==',  12, 'total words indexed' );
    

    DoSearch::open_index( "blib/index/$base.index" );
    # this index covers 7 files, each containing one word which matches the filename, are: 
    #    commune.html    communication.html  communications.html  communicator.html 
    #    community.html  commute.html        empty.html  (that's empty)
    #

    # these searches highlight some strange interactions between stemming and wildcard searches
    # we doctored the expected number of rows to match observations on <<< tests.
    my @searches = (
        #  search   =>  expected number of rows
        [ "communication" => 5 ],   # ok - stems to 'communicat'
        [ "communicator*" => 5 ],   # ok - same
        [ "communicato*"  => 0 ],   # ??? should be at least one -- 'communicator' <<<
        [ "communicate*"  => 5 ],   # ok - stems to 'communicat'
        [ "communicat*"   => 0 ],   # should be 5?  this should match _something_ <<<
        [ "communica*"    => 0 ],   # should be 5?  this should match _something_ <<<
        [ "communic*"     => 5 ],   # ok 
        [ "communi*"      => 0 ],   # should be 5?  this should match _something_ <<<
        [ "commun*"       => 5 ],   # ok
        [ "commu*"        => 6 ],   # ok
        [ "commut*"       => 1 ],   # ok
        [ "comm*"         => 6 ],   # ok
        [ "com*"          => 6 ],   # ok
        [ "co*"           => 6 ],   # ok
    );

    for (@searches) {
        my ($search, $expected) = @$_;
        my @rows = DoSearch::do_search( "blib/index/$base.index", $search );
        cmp_ok(scalar(@rows), '==', $expected, "num results ($expected) from '$search" );
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


#!/usr/bin/perl -w

# Before `make install' is performed this script should be runnable with
# `make test'. 

# at this point the name  030-C030-medsm-xml.t is a misnomer 
# because we build and test html, xml, and txt indexes

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use strict;
use warnings;

use Test::More;# qw(no_plan);
use Swishetest;

############################################
main();

############################################
sub main {
#BEGIN { 
    unless ($ENV{TEST_HUGE_INDEX} || $ENV{TEST_MEDIUM_INDEX}) {
        plan tests => 1;
        ok( 1, "no test" );
        print STDERR "$0: not running medium index test, set TEST_[HUGE|MEDIUM]_INDEX=1 to enable\n";
        exit(0);
    }


    use MinMax;
    use File::Path qw(mkpath);
    use List::Util qw(sum);    # sum sums up digits in a list
    use GetDictionaryWords;
    my $max_words = MinMax::min(1_000_000, ($ENV{MAX_INDEX_FILES} || 1_000_000));
    # predict number of tests based on number of files in dictionaries and number of index types

    #my @dicts = qw( data/C020-words-txt/words-linux-fc1.txt data/C020-words-txt/words-osx-10_3.txt);
    #my @dicts = qw( data/C020-words-txt/words-osx-10_3.txt);    # skip smaller linux words list
    my @dicts = qw( data/C020-words-txt/words-linux-fc1.txt );  # skip larger osx words list


    my @dictwordcounts = map { `wc -l $_ | awk '{print \$1}' ` } @dicts;
    chomp(@dictwordcounts);
    my $numdictwords = sum( @dictwordcounts );

    my @filetypes = qw(txt xml html);   # simpler to more complex
    my $numdicts = scalar(@dicts);
    my $numfiletypes = scalar(@filetypes);
    my $totalnumtests = $numfiletypes * $numdictwords + scalar(@dicts) * scalar(@filetypes) * 3;
    plan tests => $totalnumtests;
    mkpath( ["blib/index"], 0, 0755);
    my $base = "C030";
    for my $dict (@dicts) {
        ( my $dictname = $dict ) =~ s/^.*-(([^.]|-)+)\.txt$/$1/;
        for my $filetype ( @filetypes ) {

            my $index = "blib/index/${base}_${dictname}_${filetype}.index";
            my ($words, $word_count) = GetDictionaryWords::get_dictionary_words( $dict, 0, $max_words);
                # this filename should come from somewhere factored
            die "Couldn't get words from $dict" unless @$words;
            
            # make a collection from dict, one word per document
            my $cmd = "./make_collection --dict=$dict --norand --noenglishify " .
                        "--filetype=$filetype --min_words=1 --max_words=1 --num_files=" . scalar(@$words);
            print STDERR "Using $cmd\n" if $ENV{TEST_VERBOSE};

            my (%out) = BuildIndex::build_index_from_external_program( $cmd, $index);

            # first three tests: did the indexing seem to work?
            cmp_ok( scalar(keys(%out)), '>',        0,      "Indexing output" ); 
            cmp_ok( $out{files},      '==', scalar(@$words), 'files indexed' );
            cmp_ok( $out{properties}, '==',         5,      'num properties' );

            DoSearch::open_index($index);
            for my $word (@$words) {    # then, one test for each word in the test
                my @rows = DoSearch::do_search($index, "'$word'");  # quote the word
                #my ($num_expected_rows) = (     # look up the count unless it's AND, OR, or NOT
                #    ($word =~ /^\s*(and|or|not|near)\s*$/i) ? 0 : ($word_count->{lc($word)} || 1));
                my $num_expected_rows = $word_count->{lc($word)};
                cmp_ok(scalar(@rows), "==", $num_expected_rows, "'$word' ($filetype/$dictname)");
            }
            DoSearch::close_index($index);
            $words = undef;
            $word_count = undef;
        }
    }
};

__END__

BEGIN { 
    use File::Path qw(mkpath);
    mkpath( ["blib/index"], 0, 0755);
    my $base = "C030";
    my (%out) = build_index( 
        "data/C030-medsm-xml", "blib/index/$base.index");

    cmp_ok( scalar(%out),     '>',          2, "Indexing output" ); 
    cmp_ok( $out{unique},     '==',    117468, 'unique words indexed' );
    cmp_ok( $out{properties}, '==',         4, 'num properties' );
    cmp_ok( $out{files},      '==',      1000, 'files indexed' );
    cmp_ok( $out{bytes},      '==',  16626260, 'bytes indexed' );
    cmp_ok( $out{words},      '==',   1513714, 'total words indexed' );

    
    my @rows = do_search( 
        "blib/index/$base.index", "swishe OR test");
    cmp_ok(scalar(@rows), '==', 14, "num results from 'swishe OR test'") 
};


package GetDictionaryWords;

use strict;
use warnings;

# given a /usr/dict/words type file, whether or not to be case-sensitive, and a max amount of words (0 means no limit)
# reads word-like lines (one word per line)
# returns ref to array of the read words and ref to hash of word->count
sub get_dictionary_words {
    my $dict = shift;
    my ($case_sensitive) = (shift || 0);        
    my ($max_words) = (shift || 0);     # 0 means don't limit
    my @words;
    my %word_count;
    # Load words. Repeats are OK
    print STDERR "Loading dictionary...\n" if $ENV{TEST_VERBOSE};
    open (my $fh, "<", $dict)|| die "$0: Couldn't open $dict: $!"; 
    #for($num_words = 0; $words[$num_words] = <$fh>; ) { 
    while( defined( my $word = <$fh> ) && ($max_words == 0 || scalar(@words) < $max_words)) {
        $word =~ s/[-',.<>]//g;     # strip stuff
        chomp $word;            # strip newline
        $word =~ s/^\s+//;
        $word =~ s/\s+$//;
        if($word =~ /^$/) { 
            warn "Skipping empty non-word '$word'\n";
            next;
        } 
        push(@words, $word);
        my ($counted_word) = ($case_sensitive ? $word : lc($word));
        $word_count{$counted_word}++;
    }
    close $fh || die "$0: Couldn't close $dict: $!";
    return (\@words, \%word_count);
}

1;


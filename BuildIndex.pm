# BuildIndex.pm
package BuildIndex;
use strict;
use warnings; 
use File::Copy;

use Fatal qw(copy); # die if the copy of the config to $index.conf fails

# given an Input directory, an Index to build, a Config file to use, and optional Extra Options,
# returns a hash of info parsed from the indexing 
sub build_index_from_directory {
    my ($input, $index, $config, $extra_options) = @_; 
    $config = "conf/basic-libxml2.conf" unless $config;
    $extra_options = "" unless $extra_options; 
    my $cmd = "swish-e -c $config -i '$input' -f '$index' -v 1 $extra_options";

    return build_index_with_cmd( $input, $index, $config, $cmd );
}  


# given an external prog, an Index to build, a Config file to use, and optional Extra Options,
# returns a hash of info parsed from the indexing 
sub build_index_from_external_program {
    my ($external_program, $index, $config, $extra_options) = @_; 
    $config = "conf/basic-libxml2.conf" unless $config;
    $extra_options = "" unless $extra_options; 
    my $cmd = "$external_program | swish-e -c $config -i stdin -f '$index' -v 1 -S prog $extra_options";

    return build_index_with_cmd( $external_program, $index, $config, $cmd );
}

sub build_index_with_cmd {
    my ($input, $index, $config, $cmd) = @_; 

    # record the config file used
    copy( $config, "$index.conf" );
	
	# we assume swish-e is in the PATH!
    my $output = `$cmd`;
    print STDERR "$0: Running '$cmd'\n" if $ENV{TEST_VERBOSE};
        # -v 1 is important, we use it to test the indexer 
    die "$0: Didn't get any output from $cmd\n" unless $output;
    return parse_indexing_output( $output );
}


# given the output from an swish-e indexing run with '-v 1' (or greater) enabled,
# returns a  hash of name->value pairs gleaned from the swish-e output
sub parse_indexing_output {
    my $output = shift;
    my @output = split(/\r|\n/, $output);   # both \n's and \r's are in $output.
        # yup, @output and $output. 
    my %out;     # the hash of index output data that we'll return
    my $numreg = '([0-9]+)';
    for(@output) {
        chomp();    
        s/,//g;     # remove all commas, they made parsing harder.

        print "PROCESSING: $_\n" if defined($ENV{TEST_VERBOSE}) && $ENV{TEST_VERBOSE} > 1;  

        $out{unique} = $1       if /^\s*($numreg)\s+unique\s+words?\s+indexed/;
        $out{properties} = $1   if /^\s*($numreg)\s+properties/;
        $out{files} = $1        if /^\s*($numreg)\s+files?\s+indexed/;
        $out{bytes} = $1        if  /\s($numreg)\s+total\s+byte/;
        $out{words} = $1        if  /\s($numreg)\s+total\s+word/;
    }
    die "Couldn't get data from swish-e index build, got " . 
        join(", ", map { "$_ = {$out{$_}}" } keys(%out)) . "\n(output was " . join("\n", @output) . ")" 
            unless (scalar(keys(%out)) == 5);
    return %out;
}

1;

#!/usr/bin/perl -w 

use strict;
use Getopt::Long; 
use File::Basename;
use File::Slurp qw(read_file write_file);
use XML::Simple;

my $xmlsimple = new XML::Simple();  # used for $xmlsimple->escape_value()

my $prog = basename($0);
my $verbose;

# Usage() : returns usage information
sub Usage {
    "$prog [--verbose]\n";
}

# call main()
main();

# main()
sub main {
    GetOptions(
        "verbose!" => \$verbose,
    ) or die Usage();
    my @letters = ('A'..'J');
    for my $letter (@letters) {
        my $doctype = chr( ord($letter) - ord('A') + ord('K') );
        my $xml = simple_xmlify_with_doctype( $letter, $doctype );
        write_file( "$letter.xml", $xml );
    }
}

# one block of text in xml
# MODIFIED FROM make_collection's simple_xmlify
sub simple_xmlify_with_doctype {
    my ($text, $doctype) = @_;
    # we should test with other encodings. This tests with ISO-8859-1
    
    # handle ampersands and other chars that need to be escaped
    return qq{<?xml version="1.0" encoding="ISO-8859-1"?>\n<all>\n} . 
       qq{<swishdefault>\n} . 
       $xmlsimple->escape_value( $_[0] ) . 
        "\n</swishdefault>\n" . 
        "<doctype>$doctype</doctype>\n" . 
        "</all>\n\n"; 
}


=pod

=head1 NAME

new_perl_script -- does something awesome

=head1 SYNOPSIS

The synopsis, showing one or more typical command-line usages.

=head1 DESCRIPTION

What the script does.

=head1 OPTIONS

Overall view of the options.

=over 4

=item --verbose/--noverbose

Turns on/off verbose mode. (off by default)

=back

=head1 TO DO

If you want such a section.

=head1 BUGS

None

=head1 COPYRIGHT

Copyright (c) 2009 Josh Rabinowitz, All Rights Reserved.

=head1 AUTHORS

Josh Rabinowitz

=cut    



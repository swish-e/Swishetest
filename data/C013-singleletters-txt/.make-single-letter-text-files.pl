#!/usr/bin/perl -w 

use strict;
use Getopt::Long; 
use File::Basename;
use File::Slurp qw(read_file write_file);

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
    my @letters = ('A'..'Z');
    for my $letter (@letters) {
        write_file( "$letter.txt", "$letter\n" );
    }
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



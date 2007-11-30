package Swishetest;

use 5.008001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw( build_index do_search) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw( );

our $VERSION = '0.04a';

use DoSearch;
use BuildIndex;
use Carp;

$SIG{__WARN__} = sub { Carp::carp $_[0] };
$SIG{__DIE__} = sub { Carp::confess $_[0] };


1;

__END__
=head1 NAME

Swishetest - Library routines for the Swishetest tool

=head1 SYNOPSIS

  use Swishetest qw(build_index do_search);
  use Data::Dumper qw(Dumper);
	
  my %info = build_index( "input/data", "out/myindex.index"); 
	# 3rd & 4th params 'configfile' and 'extraoptions' are optional
  print Dumper( \%info );
  open_index("myindex.index");
  my @rows = do_search( "myindex.index", "this is the search" );	
		# returns a list of hashrefs
  close_index("myindex.index");
  print Dumper( \@rows );
  #Test::More::comp_ok( scalar(@rows), '>', 10, "more than 10 results found");

=head1 DESCRIPTION

build_index() builds an index given a directory and a target index, and returns 
some data about the index (from 'swish-e -v 1 ...') in a hash. It takes four parameters:

 my %opts = build_index( $input_dir, $index, [$configfile], [$extraswisheoptions] );
 my @r = do_search( $index, $query );

do_search() returns a list of hashrefs of the rows returned from the search.

=head2 EXPORT

None by default.  

=head1 AUTHOR

Josh Rabinowitz, E<lt>joshr@nonetE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004-2007 by Josh Rabinowitz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

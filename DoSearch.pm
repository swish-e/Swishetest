package DoSearch;

use SWISH::API;
use strict;
use warnings;

my %swishes = ();   # map of filename -> SWISH::API

# given an index filename and a query, opens the index if needed, 
#  performs the search, and
# returns the results as a list of hashrefs

sub open_index { 
    my $index = shift;
    if (!exists($swishes{$index})) {
        my $swish = $swishes{$index} = SWISH::API->new( $index );
        die "$0: index $index could not be opened.\n" unless $swish;
        print STDERR "Index $index opened\n" if $ENV{TEST_VERBOSE};
    }
    return 1;
}

sub close_index {
    my $index = shift;
    if (exists($swishes{$index})) {
        delete $swishes{$index};    # remove from the hash, should close it
    } else { 
        die "$0: index $index was not open.\n";
    }
}
sub do_search {
    my ($index, $query) = @_;   
    my @r = ();
    #return @r unless $query;
    my $swish;
    eval {
        if (exists($swishes{$index})) {
            $swish = $swishes{$index};
        } else { 
            #$swish = $swishes{$index} = SWISH::API->new( $index );
            die "$0: index $index was not opened.\n";
        }
        #print STDERR "Searching for $query\n" if $ENV{TEST_VERBOSE};
        my $results = $swish->Query( $query );
        my @props = map { $_->Name } ($swish->PropertyList( $index ) );
        if ($swish->Error()) {
            #print STDERR "$0: Error searching for $query: " . $swish->ErrorString();
            return @r;
        }

        while ( my $result = $results->NextResult() ) {
            my %h;
            #for my $p (@props) { $h{$p} = $result->Property($p); }
            for my $p (@props) { if($p eq "swishdocpath") { $h{$p} = $result->Property($p);}  }
            push(@r, \%h);
            #push( @r, {swishdocpath=>$result->Property( "swishdocpath" );
        }
    };  # end eval{}
    if ($@) {
        my $str = "$0: test failed: $@";
        if ($swish && $swish->Error()) {
            $str .= " (" . $swish->ErrorString() . ")";
        }
    }
    return @r;
}

1;

__END__

=head1 NAME

Swishetest - Library routines for the Swishetest tool

=head1 SYNOPSIS

See tests in t/

=head1 DESCRIPTION

build_index() builds an index given a directory and a target index, and returns 
some data about the index (from 'swish-e -v 1 ...') in a hash. It takes four parameters:

 my %opts = build_index( $input_dir, $index, [$configfile], [$extraswisheoptions] );
 open_index( $index );
 my @r = do_search( $index, $query );
 close_index( $index );

do_search() returns a list of hashrefs of the rows returned from the search.

=head2 EXPORT

None by default.  

=head1 AUTHOR

Josh Rabinowitz, E<lt>joshrE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004-2007 by Josh Rabinowitz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

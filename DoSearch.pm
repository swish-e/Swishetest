package DoSearch;

use SWISH::API;
use Test::More; # for can_ok() to test if an object provides a method
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

# returns a list of hashrefs of the rows returned from the search.
sub do_search {
    my ($index, $query, $options_hashref) = @_;   
    my @r = ();
    #return @r unless $query;
    my $swish;
    eval {
        if (exists($swishes{$index})) {
            $swish = $swishes{$index};
        } else { 
            die "$0: index $index was not opened.\n";
        }

        # test if swish has the return_raw_rank method
        if ($swish->can( "return_raw_rank" )) {
            if ($options_hashref->{raw_ranks})  {
                #warn "$0: enabling raw ranks\n";
                $swish->return_raw_rank(1);
            } else {
                #warn "$0: disabling raw ranks\n";
                $swish->return_raw_rank(0);
            }
        }
        if ($options_hashref->{rank_scheme}) {
            $swish->rank_scheme( $options_hashref->{rank_scheme} );
        }

        #print STDERR "Searching for $query\n" if $ENV{TEST_VERBOSE};
        my $results = $swish->Query( $query );
        my @props = map { $_->Name } ($swish->PropertyList( $index ) );
        if ($swish->Error()) {
            return @r;
        }

        while ( my $result = $results->NextResult() ) {
            my %h;
            #for my $p (@props) { $h{$p} = $result->Property($p); } # once we fetched everything
            $h{swishdocpath} = $result->Property("swishdocpath"); # get just the swishdocpath...
            $h{swishrank}         = $result->Property("swishrank");        # and the rank
            push(@r, \%h);
        }
    };  # end eval{}
    if ($@) {
        my $str = "$0: test failed: $@";
        if ($swish && $swish->Error()) {
            $str .= " (" . $swish->ErrorString() . ")";
            # wither $str?
        }
        warn "$0: Error in DoSearch::do_search(): $str\n";
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
 my @r = do_search( $index, $query, $search_options_hashref );
 close_index( $index );

do_search() returns a list of hashrefs of the rows returned from the search.

=head2 EXPORT

None by default.  

=head1 AUTHOR

Josh Rabinowitz, E<lt>joshrE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004-2009 by Josh Rabinowitz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

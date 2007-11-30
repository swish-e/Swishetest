package MinMax;
use strict;
use warnings;

sub max {
    my $max = shift;
    for(@_) { $max = $_ if $_ > $max; }
    return $max;
}
sub min {
    my $min = shift;
    for(@_) { $min = $_ if $_ < $min; }
    return $min;
}
1;

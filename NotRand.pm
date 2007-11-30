package NotRand;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(not_rand);  # symbols to export on request


# *repeatable* semi-random-ish integer number generator
# we deal with overflow by truncating to 30 bits , so this never returns an int
# larger than about 2**30
# this implementation from "Advanced Perl Programming", 4.4 Using Closures, 
# but we use global $last instead of a closure. 
# I can't imagine that this ever returns numbers that look very random, 
# as such things go...
use vars qw( $last );
sub not_rand {
	my $max = $_[0] || 1;	# if no value is passed, we return '0' or '1'
	use integer;	# is it faster not to use integer? No, it's faster to USE int.
	$last = 1 unless defined($last);
	$last = ($last*21+1);	
		# from "Advanced Perl Programming", 4.4 Using Closures. 
		# We truncate to 30 bits to preclude system overflow and thereby be more portable
		# that would be 'mod 2 ** 30' (1,073,741,824), which makes sense, 4.2G over 4
	$last %= 1_073_741_824;	 # that's 2 to the 30th
	#print "rand of $max is " . abs($last % $max) . "\n";
	return abs($last % $max);	# abs isn't needed
}

1;

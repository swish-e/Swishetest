package NotRand;
require Exporter;

##use Math::PRSG;
#use Digest::MD5 qw(md5);
##use Digest::SHA qw(sha1);

@ISA = qw(Exporter);
@EXPORT_OK = qw(not_rand);  # symbols to export on request

#my $seed = 'a1b2c3d4e5f6g7h8i9j0';  # the seed
#my $prsg = new PRSG $seed;


use vars qw( $last $prsg);
sub not_rand {
    my $max = $_[0] || 2;   # if no value is passed, we return '0' or '1'
    if (1) {
        # *repeatable* semi-random-ish integer number generator
        # we deal with overflow by truncating to 30 bits , so this never returns an int
        # larger than about 2**30
        # this implementation from "Advanced Perl Programming", 4.4 Using Closures, 
        # but we use global $last instead of a closure. 
        # I can't imagine that this ever returns numbers that look very random, 
        # as such things go...
        use integer;    # we tested, and yes, it's faster to 'use int'.
        $last = 1 unless defined($last);
        $last = ($last*21+1);   
            # from "Advanced Perl Programming", 4.4 Using Closures. 
            #
            # We truncate to 30 bits to preclude system overflow and thereby be more portable
            # that would be 'mod 2 ** 30' (1,073,741,824), which makes sense, 4.2G over 4
        $last %= 1_073_741_824;  # that's 2 to the 30th
        return abs($last % $max);   # abs isn't needed
    }
    #} else {
    #    # this should be pretty 'random'. 
    #    my $val = $prsg->clock( );   # the raw "20-byte string" from the prsg (160 bits)
    #    $val = sha1( $val );          # the sha1 digest of it, which is 160 bits long too
    #    my $fourbytes = substr( $val, 4, 4 );   # bytes 4-8
    #    my $long = unpack( "L", $fourbytes );   # L is "unsigned long"
    #    my $ret =  $long % $max;
    #    #print "$0: unpacked $long, returning $ret\n";
    #    return $ret;
    #}
}

1;

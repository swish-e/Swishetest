package NotRand;
require Exporter;

#use integer;    # on 5.10.1 on macos/xeon  shaves runtime: 8.9->8.2s, approx 10%    
# BUT 'use integer' breaks not_rand()  on some perls (5.10.0 from osx 10.6, for example) (!)

@ISA = qw(Exporter);
@EXPORT_OK = qw(not_rand);  # symbols to export on request

# from wikipedia on 'random number generator'
use vars qw( $m_w $m_z ); 
$m_w = 34301;    # must not be zero. this is a prime.
$m_z = 280859;      # must not be zero. this is a prime.
sub not_rand {  
    $m_z = 36969 * ($m_z & 65535) + ($m_z >> 16);
    $m_w = 18000 * ($m_w & 65535) + ($m_w >> 16);
    my $raw = ($m_z << 16) + $m_w;  # 32-bit result 
    return $raw % shift;
}

1;


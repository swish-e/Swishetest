package NotRand;
require Exporter;

use integer;    # on 5.10.1 on macos/xeon  shaves runtime: 8.9->8.2s, approx 10%

@ISA = qw(Exporter);
@EXPORT_OK = qw(not_rand);  # symbols to export on request

# from wikipedia on 'random number generator'
use vars qw( $m_w $m_z ); 
$m_w = 21314141;    # must not be zero
$m_z = 983639;      # must not be zero 
sub not_rand {
    $m_z = 36969 * ($m_z & 65535) + ($m_z >> 16);
    $m_w = 18000 * ($m_w & 65535) + ($m_w >> 16);
    my $raw = ($m_z << 16) + $m_w;  # 32-bit result 
    return $raw % shift;
}

1;

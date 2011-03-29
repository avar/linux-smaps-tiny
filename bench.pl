use strict;
use warnings;
use Benchmark qw(:all);

use Linux::Smaps::Tiny qw(get_smaps_summary get_smaps_summary2 get_smaps_summary3 get_smaps_summary4);

cmpthese(10000, {
    read => sub { get_smaps_summary() },
    slurp => sub { get_smaps_summary2() },
    split_n => sub { get_smaps_summary3() },
    substr_etc => sub { get_smaps_summary4() },
});

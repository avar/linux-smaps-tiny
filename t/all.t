use strict;
use warnings FATAL => "all";
use Test::More;
use List::Util qw(sum);

plan skip_all => "This only works on Linux" unless $^O eq "linux";
plan 'no_plan';

use_ok 'Linux::Smaps::Tiny';
use_ok 'Linux::Smaps::Tiny::PP';

my @fields = qw(
    KernelPageSize
    MMUPageSize
    Private_Clean
    Private_Dirty
    Pss
    Referenced
    Rss
    Shared_Clean
    Shared_Dirty
    Size
    Swap
);

for my $function (qw(Linux::Smaps::Tiny::get_smaps_summary Linux::Smaps::Tiny::PP::get_smaps_summary)) {
    pass "Now testing $function:";
    for my $arg ([], [$$]) {
        my $smaps = do { no strict 'refs'; &$function(@$arg) };
        cmp_ok(ref($smaps), "eq", "HASH", "We got a hash back");


        for my $thing (@fields) {
            ok(exists $smaps->{$thing}, "The $thing entry exists");
        }

        cmp_ok(sum(values %$smaps), ">", 0, "We got some memory reported");
    }

    eval {
        do { no strict 'refs'; &$function("HELLO THERE") };
        1;
    };
    my $err = $@;
    like($err, qr[Failed to read '/proc/HELLO THERE/smaps'], "Sensible error messages");
}



#!/usr/bin/env/perl
use strict;
use warnings;
use Linux::Smaps;
use Linux::Smaps::Tiny;
use Benchmark qw/:all :hireswallclock/;

cmpthese(1000, {
    "Linux::Smaps" => sub {
        Linux::Smaps->new->all;
        return;
    },
    "Linux::Smaps::Tiny" => sub {
        Linux::Smaps::Tiny::get_smaps_summary;
        return;
    },
    "Linux::Smaps::Tiny::XS (stdio)" => sub {
        Linux::Smaps::Tiny::get_smaps_summary_xs;
        return;
    },
    "Linux::Smaps::Tiny::XS (mmap)" => sub {
        Linux::Smaps::Tiny::get_smaps_summary_mmap;
        return;
    },
});

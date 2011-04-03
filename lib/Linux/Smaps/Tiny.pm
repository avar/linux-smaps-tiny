package Linux::Smaps::Tiny;
use strict;
use warnings FATAL => "all";

BEGIN {
    require XSLoader;
    XSLoader::load(__PACKAGE__, $Linux::Smaps::Tiny::VERSION || '0.01');
}

use Exporter 'import';

our @EXPORT_OK = qw(get_smaps_summary);

=encoding utf8

=head1 NAME

Linux::Smaps::Tiny - A minimal and fast alternative to L<Linux::Smaps>

=head1 SYNOPSIS

    use Linux::Smaps::Tiny qw(get_smaps_summary);

    my $summary = get_smaps_summary();
    my $size = $summary->{Size};
    my $shared_clean = $summary->{Shared_Clean};
    my $shared_dirty = $summary->{Shared_Dirty};

    warn "Size / Clean / Dirty = $size / $shared_clean/ $shared_dirty";

=head1 DESCRIPTION

This module is a tiny interface to F</proc/$$/smaps> files. It was
written because when we rolled out L<Linux::Smaps> in some critical
code at a Big Internet Company we experienced slowdowns that were
solved by writing a more minimal version.

If something like that isn't your use case you should probably use
L<Linux::Smaps> instead. Also note that L<Linux::Smaps> itself L<has
been
optimized|http://mail-archives.apache.org/mod_mbox/perl-modperl/201103.mbox/browser>
since this module was initially written.

=head1 FUNCTIONS

=head2 get_smaps_summary

Takes an optional process id (defaults to C<self>) returns a summary
of the smaps data for the given process. Dies if the process does not
exist.

Returns a hashref like this:

        {
          'MMUPageSize' => '184',
          'Private_Clean' => '976',
          'Swap' => '0',
          'KernelPageSize' => '184',
          'Pss' => '1755',
          'Private_Dirty' => '772',
          'Referenced' => '2492',
          'Size' => '5456',
          'Shared_Clean' => '744',
          'Shared_Dirty' => '0',
          'Rss' => '2492'
        };

Values are in kB.

=cut

sub get_smaps_summary {
    my $proc_id= shift || "self";
    my $smaps_file= "/proc/$proc_id/smaps";
    open my $fh, "<", $smaps_file
        or do {
            my $errnum= 0+$!; # numify
            my $errmsg= "$!"; # stringify
            my $msg= "In get_smaps_summary, failed to read '$smaps_file': [$errnum] $errmsg";

            die $msg;
        };
    my %sum;
    while (<$fh>) {
        next unless substr($_,-3) eq "kB\n";
        my ($field, $value)= split /:/,$_;
        no warnings 'numeric';
        $sum{$field}+=$value if $value;
    }
    close $fh;
    return \%sum;
}

sub get_smaps_summary_xs {
    $_[0] = "/proc/self/smaps" unless $_[0];
    goto &__get_smaps_summary_xs;
}

sub get_smaps_summary_slurp {
    $_[0] = "/proc/self/smaps" unless $_[0];
    goto &__get_smaps_summary_slurp;
}


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Yves Orton <yves@cpan.org> and Ævar Arnfjörð Bjarmason
<avar@cpan.org>

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

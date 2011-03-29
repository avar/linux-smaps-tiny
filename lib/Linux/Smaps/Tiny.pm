package Linux::Smaps::Tiny;
use strict;
use warnings FATAL => "all";

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
code at a Big Internet Company we experienced slowdowns due to its
generous use of method calls.

If something like that isn't your use case you should probably use
L<Linux::Smaps> instead.

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
        or die "Failed to read '$smaps_file': $!";
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

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Yves Orton <yves@cpan.org> and Ævar Arnfjörð Bjarmason
<avar@cpan.org>

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

1;

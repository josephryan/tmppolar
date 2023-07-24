#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use JSON::Parse;
use Data::Dumper;

our $VERSION  = '0.02';
our $AUTHOR  = 'Joseph F. Ryan <joseph.ryan@whitney.ufl.edu>';
our $CUTOFF  = 0.05;

MAIN: {
    my $rh_o = get_options();    
    my $dir = $rh_o->{'busted_dir'};
    my $ra_f = get_files($dir,$rh_o->{'suf'});
    foreach my $file (@{$ra_f}) {
        next if (-z "$dir/$file");
        my $rh_j;
        eval {
            $rh_j = JSON::Parse::read_json("$dir/$file");
        };
        if ($@) {
            $rh_j = undef;
            warn "could not parse $dir/$file:$@\n";
        } else {
            my $pval = $rh_j->{'test results'}->{'p-value'};
            print "$file has p-value = $pval\n" if ($pval <= $CUTOFF);
        }
    }
}

sub get_files {
    my $dir = shift;
    my $suf = shift;
    opendir DIR, $dir or die "cannot opendir $dir:$!";
    my @files = grep { /$suf/ } readdir(DIR);
    return \@files;
}

sub get_options {
    my $rh_opts = {};
    my $opt_results = Getopt::Long::GetOptions(
                                   'version' => \$rh_opts->{'version'},
                                         'v' => \$rh_opts->{'version'},
                                      'help' => \$rh_opts->{'help'},
                                         'h' => \$rh_opts->{'help'},
                                     'suf=s' => \$rh_opts->{'suf'},
                              'busted_dir=s' => \$rh_opts->{'busted_dir'});

    pod2usage({-exitval => 0, -verbose => 2}) if($rh_opts->{'help'});
    if ($rh_opts->{'version'}) {
        print "parse_busted.pl version $VERSION\n";
        exit;
    }
    unless ($rh_opts->{'busted_dir'} && $rh_opts->{'suf'}) {
        print "missing --busted_dir\n" unless ($rh_opts->{'busted_dir'});
        print "missing --suf\n" unless ($rh_opts->{'suf'});
        usage();
    }
    return $rh_opts;
}

sub usage {
    print "parse_busted.pl --busted_dir=BUSTED_DIR --suf=SUFFIX [--version] [--help]\n";
    exit;
}

__END__

=head1 NAME 

B<parse_busted.pl> - identify BUSTED runs with positive test results

=head1 AUTHOR

Joseph F. Ryan <joseph.ryan@whitney.ufl.edu>

=head1 SYNOPSIS

parse_busted.pl --busted_dir=BUSTED_DIR --suf=SUFFIX [--version] [--help]\n";

=head1 OPTIONS

=over

=item B<--busted_dir>

directory with hyphy BUSTED outputs

=item B<--suf>

suffix of JSON formatted files generated by hyphy BUSTED

item B<--version>

Print the version and exit.

=item B<--help>

Print this manual.

=back

=head1 DESCRIPTION

This program is a helper script that we developed as part of the Polar Genomics Workshop. It identifies BUSTED runs with positive test results.

=head1 BUGS

Please report them to the author.

=head1 ACKNOWLEDGEMENT

This material is based upon work supported by the National Science Foundation under Grant Numbers (1935672 and 1935635) awarded to Joseph Ryan and Scott Santagata.

=head1 COPYRIGHT

Copyright (C) 2023 Joseph F. Ryan, Scott Santagata

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
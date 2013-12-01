#!/usr/bin/perl

if (@ARGV < 2) {
    print "Please pass in the input chr file and output file as parameters\n";
    print "usage: parse_chr.pl chr_match.txt out.txt\n";
}

# make sure you are passing in the input file and output file as parameters
my $input_file = shift;
my $output_file = shift;

open (IN, $input_file) or die "cant open input file";
open (OUT, ">$output_file") or die "can't open output file to write";

# data structure to store the results.  its an array
my @results = ();

# looping through the file
while (my $row = <IN>) {

    # removing the carriage return, empty rows if any, header, and tailing tabs/spaces
    chomp $row;
    next if $row =~ m/^$/;
    next if $row =~ m/^id/;
    $row =~ s/\s+$//g;

    # creating columns in the row as an array
    my @columns = split /\t/, $row;

    # remove the unique id - doesn't look like its relevant for how we create 
    # the output?
    shift @columns;

    while (scalar(@columns) >= 3) {
	push (@results, shift(@columns) . "\t" . shift(@columns) . "\t" . shift(@columns));
    }

}

print "A total of " . scalar(@results) . " entries of chr-start-end found in input file\n";

# I found some duplicate entries of chr-start-end across the unique ids.  If you want
# to see in your output set, then comment out the 4 lines below.  These current remove 
# those duplicates
my %seen;
my @unique = grep { ! $seen{$_}++ } @results;
@results = @unique;
print "A total of " . scalar(@results) . " unique entries of chr-start-end found in input file\n";

# now, print the various combinations
for ($i = 0; $i < scalar(@results); $i++) {
    for ($j = $i + 1; $j < scalar(@results); $j++) {
	print OUT $results[$i] . "\t" . $results[$j] . "\n";
    }
}

close IN;
close OUT;

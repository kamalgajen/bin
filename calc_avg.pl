#!/usr/bin/perl -w

# a perl script to parse and aggregate a couple of metrics in a tsv
# an equivalent command line script below - 
# tail -n+2 mg_GC3_out.txt | sort | cut -f 1,2,3 | awk '{gcsum[$1]+=$2; gccount[$1]++; gc3sum[$1]+=$3; gc3count[$1]++;} END {for (i in gcsum) {print i, "\t", gcsum[i]/gccount[i], "\t", gc3sum[i]/gc3count[i]}}' > gonzo.out

my $input_file = shift @ARGV;

# check if the input file was passed
if (!$input_file) {
    print "pass the input file to parse\n";
    exit 1;
}

open(INPUT, $input_file) or die "can't open file $input_file\n";

# skip the header
<INPUT>;

# define hashes to store sum of 2 gc values and count of them
my %gcsum = ();
my %gc3sum = ();
my %gccount = ();

while (my $line = <INPUT>) {
    my @array = split /\t/, $line;
    
    if (! exists $gcsum{$array[0]}) {
	$gcsum{$array[0]} = $array[1];
	$gc3sum{$array[0]} = $array[2];
	$gccount{$array[0]} = 1;
    } else {
	$gcsum{$array[0]} += $array[1];
	$gc3sum{$array[0]} += $array[2];
	$gccount{$array[0]}++;
    }	
}

foreach my $key (keys %gccount) {
    my $gcaverage = $gcsum{$key}/$gccount{$key};    
    my $gc3average = $gc3sum{$key}/$gccount{$key};
    print "$key\t$gcaverage\t$gc3average\n";
}

exit 0;

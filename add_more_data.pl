#!/usr/bin/perl

$start = 500;
$end = 5000;
$number_of_products_in_input_file = 500;

$input_file = "plw.csv";
$output_file = "out.csv";

`head -1 $input_file > $output_file`;

open (IN, $input_file) or die "cant open input file";
open (OUT, ">>$output_file") or die "can't open output file to write";

for ($i = $start; $i < $end; $i++) {

    $header = 1;
    while (<IN>) {
	chomp;

	if ($header == 1) {
	    $header = 0;
	    next;
	}
    
	m/^(\d+),(.*)$/;
	my $productid = $1 + $i;
	print OUT "$productid,$2\n";
    }

    $i += $number_of_products_in_input_file;
    $i--;

    seek IN, 0, 0
}

close IN;
close OUT;

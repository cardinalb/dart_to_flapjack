#!/usr/bin/perl -w

#===============================
# DArT to Flapjack matrix format
# v0.2 February 2015
#===============================

=licence	
The MIT License (MIT)

Copyright (c) 2015 Paul Shaw - Information and Computational Sciences, The James Hutton Institute, Scotland.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
=cut


=background

DArT (well a modified DArT) to Flapjack format.

Input file (Tab delimited text file) needs to be in this form which is how it has been supplied by CIMMYT in the past.

Allele_ID              		snp         	266759  194916  195959  191884  191481  206877  207069
1002968|F|0--60:C>T     	60:C>T             0       1      1        1      0       1       0
1002968|F|0--60:C>T-60:C>T      60:C>T             1       0      1        0      1       0       1	
The calls will be in pairs of lines, these should be sequential in the file.

Outputs this format
DArT Marker Name/Line 266759  194916  195959  191884  191481  206877  207069
1002968|F|0--60:C>T     T             C             C/T         C             T             C             T

The encoding is based on advice from CIMMYT

Allele CT
01  -> TT (i.e., homozygote for T)
-1  -> ?T (i.e., homozygote for T or heterozygote)
10  -> CC (i.e., homozygote for C)
1-  -> C? (i.e., homozygote for C or heterozygote)
11  -> CT (i.e., heterozygote)

This is Perl code. Requires input file in $ARGV[0] and output in $ARGV[1] which are passed as command line arguments as you would expect.

To run dart_to_matrix.pl inputfile.in outputfile.out.


=cut


use strict;

open(INPUT, $ARGV[0]);
open(OUTPUT, ">$ARGV[1]");

my $line_counter = 0;
my @line_names;

#===================================================================================
# Looks for duplicate line names in the data and assigns a numeric postfix to ensure
# uniqueness. There really shouldn't be duplicates but it happens....
#===================================================================================
FIRST_LOOP:
while(<INPUT>)
{
    if($line_counter == 0)
    {
	my($marker_name_header, $snp_position_header, @lines) = split(/\t/, $_);
	
	my %lineTrack;
	
	my $duplicatesTrack = 1;
	
	foreach(@lines)
	{
	    if(defined($lineTrack{$_}))
	    {
		push(@line_names, $_."_".$duplicatesTrack); # this tags on the postfix
		$duplicatesTrack++;
		$lineTrack{$_}++;
	    }
	    else
	    {
		push(@line_names, $_);
		$lineTrack{$_}++;
	    }  	    
	}
	$line_counter++;
	last FIRST_LOOP;
    }      
}
print OUTPUT join("\t", "DArT Marker Name/Line", @line_names);


my $counter2 = 0;
SECOND_LOOP:   
while(<INPUT>)
{
	#ASSUMES THAT MARKERS ARE IN PAIRS AND ORDERED IN THE INPUT FILE
	my $row1 = $_;
	my $row2 = <INPUT>; # this basically takes two rows at a time from the file. 
	
	chomp($row1);
	chomp($row2);
	
	my($marker_name_1, $snp_1, @genotypes_1) = split(/\t/, $row1);
	my($marker_name_2, $snp_2, @genotypes_2) = split(/\t/, $row2);

	# so we know what the SNP conversion is its in the snp_2 element'
	# For Example say we have 38:G>A in there we can dump the 38: bit
	# and we are on to just G>A which is the SNP (G to A ? Present | Absent)
	my $working_snp = $snp_2;
	
	$working_snp =~ s/\d+\://ig;

	my($allelic_state_1, $allelic_state_2) = split(/\>/, $working_snp);	
	
	print OUTPUT join("\t", $marker_name_1);
	
	my $trackcounter = 0;
	foreach my $g1(@genotypes_1)
	{
	    my $allele1 = "";
	    my $allele2 = "";
	
		if($g1 eq "\-")
		{
		    $allele1 = "\-";
		}
		elsif($g1 == 1)
		{
		    $allele1 = $allelic_state_1;    
		}
		elsif($g1 == 0)
		{
		    $allele1 = $allelic_state_2;
		}
		elsif($g1 == "")
		{
		    $allele1 = "\-";
		}
	
		my $genotypes_2;
		
		if(defined($genotypes_2[$trackcounter]))
		{
		    $genotypes_2 = $genotypes_2[$trackcounter];
		}
		else
		{
		    $genotypes_2 = "\-";
		}
	
			
		if($genotypes_2 eq "-" || $genotypes_2 eq "")
		{
		    $allele2 = "\-";
		}
		elsif($genotypes_2 == 1)
		{
		    $allele2 = $allelic_state_2;    
		}
		elsif($genotypes_2 == 0)
		{
		    $allele2 = $allelic_state_1;
		}
		elsif($genotypes_2 = "")
		{
		    $allele2 = "\-";
		}
	
		if($allele1 eq $allele2)
		{
		    print OUTPUT "\t".$allele1;
		}
		else
		{
		    print OUTPUT "\t".$allele1."/".$allele2;
		}
		$trackcounter++;
	    }
	    print OUTPUT "\n";
}

close OUTPUT;

print "Finished....\n";



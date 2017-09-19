# dart_to_flapjack
#H2 DArT (well a modified DArT) to Flapjack format.

Input file (*tab delimited text file but an easy tweak in the code to change to csv*) needs to be in this form which is how it has been supplied by CIMMYT in the past.
Allele_ID,snp,266759,194916,195959,191884,191481,206877,207069
1002968|F|0--60:C>T,60:C>T,0,1,1,1,0,1,0
1002968|F|0--60:C>T-60:C>T,60:C>T,1,0,1,0,1,0,1	

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

So to run this script you need Perl installed then...
```
perl dart_to_matrix.pl inputfile.in outputfile.out
```


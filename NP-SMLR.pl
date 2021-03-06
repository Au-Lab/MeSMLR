#!/usr/bin/perl

use strict;
require "getopts.pl";
use vars qw($opt_b $opt_e $opt_o $opt_h);

&Getopts('b:e:o:h');
my ( $bam, $event, $output )
    = ( $opt_b, $opt_e, $opt_o );

my $help_message = "--------------------------------------------\n";
$help_message .= "How to USE this program:\n";
$help_message
    .= "Command: \tNP-SMLR.pl -b sorted_bam_file -e event_align_scale -o output_dir\n\n";
$help_message .= "Parameters\n";
$help_message .= "\t-b\tName of the BAM file that records the alignment of reads. The BAM file must be sorted.\n";
$help_message .= "\t-e\tEvent alignment file generated by \"nanopolish eventalign\" (with flag --scale-events)\n";
$help_message .= "\t-o\tName of output folder\n\n";
$help_message .= "--------------------------------------------\n";

if ( $opt_h == 1 ) {
    die $help_message;
}
else {
    if( $opt_b && $opt_e && $opt_o) {
        print "[COMMAND]: NP-SMLR -b $bam -e $event -o $output\n"
    }
    else {
        die $help_message
    }
}


mkdir $output;


my $soft_dir = `which Detection | sed -e 's/Detection//g'`;
chomp($soft_dir);

system("samtools view $bam | awk '{if(\$2==\"0\") print \$1}' > $output/fwd_rdname.txt");

my $cmd_likelihood = "Likelihood $soft_dir/../par/parameters_Gaussian.txt $soft_dir/../par/parameters_EM.txt $event $soft_dir/../testdata/fwd_rdname.txt > $output/likelihood.txt";
print "Calculate Likelihood ...\n";
system($cmd_likelihood);

my $cmd_detection = "Detection $output/likelihood.txt $soft_dir/../par/overlap.txt > $output/detection.txt";
print "Calculate GpC methylation score ...\n";
system($cmd_detection);

my $cmd_bed = "bedtools bamtobed -i $bam > $output/alignment.bed";
print "Generate bed file ...\n";
system($cmd_bed);

my $cmd_ncls_pos = "NclsPos $output/detection.txt $output/alignment.bed > $output/ncls_pos.bed";
print "Nucleosome positioning ...\n";
system($cmd_ncls_pos);

print "Finished.\n";

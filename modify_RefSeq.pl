#!/usr/bin/env perl
###################################
# Author: Jiang Li
# Email: riverlee2008@gmail.com
# Date: Sun Nov 24 11:26:23 2013
###################################
use strict;
use warnings;

## The gtf file downloaded from UCSC table actually uses 'transcript id' ad gene id
## This script will replace it with genes to maintain the relationship between gene id and transcript id

#1) Get transcript id to gene id
my %t2g;
open(IN,"hg19RefSeq.txt") or die $!;
while(<IN>){
	next if (/^#/);
	my($bin,$name,$chrom,$strand,$txStart,$txEnd,$cdsStart,$cdsEnd,$exonCount,$exonStarts,$exonEnds,$score,$name2,$cdsStartStat,$cdsEndStat,$exonFrames) = split "\t";
	$t2g{$name}=$name2;	
}
close IN;

#2) modify hg19RefSeq.gtf
open(IN,"hg19RefSeq.gtf") or die $!;
open(OUT,">hg19RefSeq_modified.gtf") or die $!;
while(<IN>){
	s/\r|\n//g;
	my($chr,$source,$feature,$start,$end,$score,$strand,$frame,$details) = split "\t";
	
	# get gene id
	my $gid = "";
	if($details=~/gene_id "(.*?)";/){
			$gid = $1;
	}
	if(exists($t2g{$gid})){
		my $gid2=$t2g{$gid};
		$details=~s/gene_id "$gid"/gene_id "$gid2"/g;
		$details.="gene_name \"$gid2\"; ";
		print OUT join "\t",($chr,$source,$feature,$start,$end,$score,$strand,$frame,$details."\n");
	}else{
			print $_."\n";
	}

}


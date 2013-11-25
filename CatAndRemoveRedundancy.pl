#!/usr/bin/env perl
###################################
# Author: Jiang Li
# Email: riverlee2008@gmail.com
# Date: Sun Nov 24 11:47:53 2013
###################################
use strict;
use warnings;

## Cat the mRNA+lincRNA together
## lincRNA priority
## RefSeq, GENCODE, lincRNA catagory
## which means if the lincRNA is defined by RefSeq, then use it even if it is re-defined by GENCODE and lincRNA catagory
## If the lincRNA is defiined by GENCODE, then use it even if it is re-defined by lincRNA catagory

open(OUT,">hg19_mRNA-lincRNA.gtf") or die $!;
open(LOG,">cat.log");
my %refseq;

#1) Read refseq
open(IN,"hg19RefSeq_modified.gtf") or die $!;
while(<IN>){
	next if (/^#/);
	print OUT $_;
	my($chr,$source,$feature,$start,$end,$score,$strand,$frame,$details) = split "\t";

	# get gene id
	my $gid = "";
	if($details=~/gene_id "(.*?)";/){
			$gid = $1;
	}
	$refseq{$gid} = 1;
}
close IN;


# 2) Read GENCODE
open(IN,"gencode.v18.long_noncoding_RNAs.gtf") or die $!;
my %gencode;
while(<IN>){
	next if (/^#/);
	my($chr,$source,$feature,$start,$end,$score,$strand,$frame,$details) = split "\t";
	# get gene id
	my $gid = "";
	if($details=~/gene_name "(.*?)";/){
			$gid = $1;
	}
	$gencode{$gid}=1;

	if(exists($refseq{$gid})){
		# skip it
		print LOG "$gid removed from GENCODE\n";
	}else{
		print OUT  $_;
	}
}
close IN;

# 3) Read lincRNA catagory
open(IN,"lincRNAs_transcripts.gtf") or die $!;
while(<IN>){
	next if (/^#/);
	my($chr,$source,$feature,$start,$end,$score,$strand,$frame,$details) = split "\t";
	next if ($source eq "HAVANA" || $source eq "hg19_refGene" || $source eq "ENSEMBL"); # this lincRNAs has been defined by refseq and GENCODE

	# get gene name
	my $gid = "";
	if($details=~/gene_name "(.*?)";/){
			$gid = $1;
	}
	if($gid ne ""){

			if(exists($refseq{$gid}) || exists($gencode{$gid})){
					# skip it
					print LOG "$gid removed from lincRNA catagory\n";
			}else{
					print OUT  $_;
			}
	}else{
			print OUT $_;
	}
}
close IN;

#!/usr/bin/perl
#
#by Ryan Tewhey
use strict;
use warnings;

my $mapped = $ARGV[0];

open (MAPPED, "$mapped") or die("ERROR: can not read file (mapped): $!\n");

my @line;

my @ids;
my @cov;
#my @pass;

my $max;
my $i;
my $keep;
my $max_idx;

while (<MAPPED>)
	{
	chomp;
	my @line = split(/\t/);
	
	my @ids = split(/,/,$line[1]);
	my @cov = split(/,/,$line[2]);
	#my @pass = split(/,/,$line[5]);

	if(scalar(@ids) > 1)
		{
		$max = (sort {$a <=> $b} @cov)[-1];
		$keep = "0";
		$max_idx = "NA";
		
		for($i=0;$i<scalar(@cov);$i++)
			{
			if($cov[$i] == $max && $max_idx ne "NA")
				{
				$keep = 1;
				}
			elsif($cov[$i] == $max && $keep eq "0")
				{
				$max_idx = $i;
				}
			elsif($cov[$i]/$max > .1)
				{
				$keep = 1;
				}
			}	
		print join("\t",$line[0],$ids[$max_idx],$cov[$max_idx],$line[3],0)."\n" if($keep==0);	
		print join("\t",@line)."\n" if($keep==1);	

		}
	else
		{
		print join("\t",@line)."\n";	
		}
	}


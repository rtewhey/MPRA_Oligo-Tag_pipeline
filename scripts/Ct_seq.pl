#!/usr/bin/perl
#
#by Ryan Tewhey
use strict;
use warnings;
##################################
#
##################################

my $mapped = $ARGV[0];
my $CT_COL = $ARGV[1]-1;
my $CMP_COL = $ARGV[2]-1;

open (MAPPED, "$mapped") or die("ERROR: can not read file (mapped): $!\n");

my $first = 0;
my $tmp_line;
my @last;

my $next_line;
my @next;

my $cur_barcode;
my %cur_hits;

my %cur_hits_score;
my @print_score;
my @tmp_sort;
my @print_keys;
my @print_values;

my $key;
my $sum;
my $pass_flag; # 0 = ok, 1 = collision, 2 = other failure (mapping)


while (<MAPPED>)
	{
	$pass_flag = 2;
	chomp;
	my @line = split(/\t/);
	
	if($first == 0)
		{
		@last = @line;
		$first = 1;
		next;
		}

	$pass_flag = 0 if($last[10] eq "PASS");
	
	$cur_barcode = $last[$CT_COL];
	$cur_hits{$last[$CMP_COL]}++;
	push(@{$cur_hits_score{$last[$CMP_COL]}},$line[8]);

	while($last[$CT_COL] eq $line[$CT_COL] && !(eof))
		{
		$cur_hits{$line[$CMP_COL]}++;
		push(@{$cur_hits_score{$last[$CMP_COL]}},$line[8]);
		$pass_flag = 0 if($line[10] eq "PASS");
		$tmp_line=<MAPPED>;
		chomp $tmp_line;
		@line = split(/\t/,$tmp_line);
		}
	
	if(eof) ##If end of file process last two lines
		{
		if($line[$CT_COL] eq $last[$CT_COL])
			{
			$cur_hits{$line[$CMP_COL]}++ if($line[$CT_COL] eq $last[$CT_COL]);
			push(@{$cur_hits_score{$last[$CMP_COL]}},$line[8]);
			$pass_flag = 0 if($line[10] eq "PASS");	
			}
		else  ## Run normal loop on last line
			{
			print "$cur_barcode\t";
			print join(",",keys %cur_hits)."\t";
			print join(",",values %cur_hits)."\t";	
			$sum = 0;
			for $key (keys %cur_hits)
			{  
  			$sum += $cur_hits{$key};
			}
			print $sum."\t";
	
			$pass_flag = 1 if(scalar(keys %cur_hits) > 1);
			print $pass_flag."\n";
			%cur_hits = ();
			@last = @line;
			$pass_flag = 2;
			$pass_flag = 0 if($last[10] eq "PASS");
	
			$cur_barcode = $last[$CT_COL];
			$cur_hits{$last[$CMP_COL]}++;
			$cur_hits_score{$last[$CMP_COL]}+=$line[8];
			push(@{$cur_hits_score{$last[$CMP_COL]}},$line[8]);
			}
		
		}

	


	$sum = 0;
	@print_keys=();
	@print_values=();
	@print_score=();
	
	for $key (keys %cur_hits)
		{
		push(@print_keys,$key);
		push(@print_values, $cur_hits{$key});
  		$sum += $cur_hits{$key};
  		
  		push(@{$cur_hits_score{$key}},1);
  		#@tmp_sort = @{$cur_hits_score{$key}};
  		my @tmp_sort = sort {$a <=> $b} @{$cur_hits_score{$key}} if(scalar @{$cur_hits_score{$key}} > 1);
  		
  		push(@print_score,printf("%.3f",$tmp_sort[0]));
		}
	print "$cur_barcode\t";
	print join(",",@print_keys)."\t";
	print join(",",@print_values)."\t";		
	print $sum."\t";
	
	$pass_flag = 1 if(scalar(keys %cur_hits) > 1);
	print $pass_flag."\t";
	print join(",",@print_score)."\n";


	
	
	%cur_hits = ();
	%cur_hits_score = ();
	@last = @line;
	}

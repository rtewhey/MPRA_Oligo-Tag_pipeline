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
my %cur_pass_flag;
my @print_score;
my @tmp_sort;
my @print_keys;
my @print_values;
my @print_passflag;

my $key;
my $sum;
my $ct_pass_flag; # 0 = ok, 1 = collision, 2 = other failure (mapping)
my $cmp_pass_flag; #0 = ok, 2 = mapping

my $aln_score;

while (<MAPPED>)
	{
	chomp;
	my @line = split(/\t/);
	
	if($first == 0)
		{
		@last = @line;
		$first = 1;
		next;
		}
	
	$ct_pass_flag = 2;
	$cmp_pass_flag = 2;
	$ct_pass_flag = 0 if($last[10] eq "PASS");
	$cmp_pass_flag = 0 if($last[10] eq "PASS");
	
	$cur_barcode = $last[$CT_COL];
	$cur_hits{$last[$CMP_COL]}++;
	$aln_score=$last[8];
	$aln_score=1 if($last[8] eq "-");
	push(@{$cur_hits_score{$last[$CMP_COL]}},$aln_score);
	push(@{$cur_pass_flag{$last[$CMP_COL]}},$cmp_pass_flag);

	while($last[$CT_COL] eq $line[$CT_COL] && !(eof))
		{
		$cmp_pass_flag = 2;
		$cmp_pass_flag = 0 if($line[10] eq "PASS");
		$aln_score=$line[8];
		$aln_score=1 if($line[8] eq "-");
		
		$cur_hits{$line[$CMP_COL]}++;
		push(@{$cur_hits_score{$line[$CMP_COL]}},$aln_score);
		push(@{$cur_pass_flag{$line[$CMP_COL]}},$cmp_pass_flag);
		$ct_pass_flag = 0 if($line[10] eq "PASS");
		
		$tmp_line=<MAPPED>;
		chomp $tmp_line;
		@line = split(/\t/,$tmp_line);
		}
	
	if(eof) ##If end of file process last two lines
		{
		if($line[$CT_COL] eq $last[$CT_COL])
			{
			$cur_hits{$line[$CMP_COL]}++;
			push(@{$cur_hits_score{$line[$CMP_COL]}},$aln_score);
			push(@{$cur_pass_flag{$line[$CMP_COL]}},$cmp_pass_flag);
			$ct_pass_flag = 0 if($line[10] eq "PASS");	
			}
		else  ## Run normal loop on last line if unique
			{
				$sum = 0;
				@print_keys=();
				@print_values=();
				@print_score=();
				@print_passflag=();
	
				for $key (keys %cur_hits)
					{
					push(@print_keys,$key);
					push(@print_values, $cur_hits{$key});
  					$sum += $cur_hits{$key};
  	
  					#print STDERR join (",",$key,@{$cur_pass_flag{$key}})."\n";   		
  					@tmp_sort = @{$cur_pass_flag{$key}};
  					@tmp_sort = sort {$a <=> $b} @{$cur_pass_flag{$key}} if(scalar @{$cur_pass_flag{$key}} > 1); 	
  					push(@print_passflag, $tmp_sort[0]);
  		
  					@tmp_sort = @{$cur_hits_score{$key}};
  					@tmp_sort = sort {$a <=> $b} @{$cur_hits_score{$key}} if(scalar @{$cur_hits_score{$key}} > 1);
  					#print STDERR join (",",$key,@tmp_sort)."\n";
  					push(@print_score,sprintf("%.3f",$tmp_sort[0]));
					}
				print "$cur_barcode\t";
				print join(",",@print_keys)."\t";
				print join(",",@print_values)."\t";		
				print $sum."\t";
	
				$ct_pass_flag = 1 if(scalar(keys %cur_hits) > 1);
				print $ct_pass_flag."\t";
				print join(",",@print_passflag)."\t";
				print join(",",@print_score)."\n";

				%cur_hits = ();
				%cur_hits_score = ();
				%cur_pass_flag = ();
			
				@last = @line;
				$ct_pass_flag = 2;
				$ct_pass_flag = 0 if($last[10] eq "PASS");
				$cmp_pass_flag = 2;
				$cmp_pass_flag = 0 if($line[10] eq "PASS");
				
				$cur_barcode = $last[$CT_COL];
				$cur_hits{$last[$CMP_COL]}++;
				$aln_score=$last[8];
				$aln_score=1 if($last[8] eq "-");
				push(@{$cur_hits_score{$last[$CMP_COL]}},$aln_score);
				push(@{$cur_pass_flag{$line[$CMP_COL]}},$cmp_pass_flag);
			}
		
		}
	


	$sum = 0;
	@print_keys=();
	@print_values=();
	@print_score=();
	@print_passflag=();
	
	for $key (keys %cur_hits)
		{
		push(@print_keys,$key);
		push(@print_values, $cur_hits{$key});
  		$sum += $cur_hits{$key};
  	
  		#print STDERR join (",",$key,@{$cur_pass_flag{$key}})."\n";   		
  		@tmp_sort = @{$cur_pass_flag{$key}};
  		@tmp_sort = sort {$a <=> $b} @{$cur_pass_flag{$key}} if(scalar @{$cur_pass_flag{$key}} > 1); 	
  		push(@print_passflag, $tmp_sort[0]);
  		
  		#print STDERR join (",",$key,@{$cur_hits_score{$key}})."\n";
  		@tmp_sort = @{$cur_hits_score{$key}};
  		@tmp_sort = sort {$a <=> $b} @{$cur_hits_score{$key}} if(scalar @{$cur_hits_score{$key}} > 1);
  		push(@print_score,sprintf("%.3f",$tmp_sort[0]));
		}
	print "$cur_barcode\t";
	print join(",",@print_keys)."\t";
	print join(",",@print_values)."\t";		
	print $sum."\t";
	
	$ct_pass_flag = 1 if(scalar(keys %cur_hits) > 1);
	print $ct_pass_flag."\t";
	print join(",",@print_passflag)."\t";
	print join(",",@print_score)."\n";


	
	
	%cur_hits = ();
	%cur_hits_score = ();
	%cur_pass_flag = ();
	@last = @line;
	}

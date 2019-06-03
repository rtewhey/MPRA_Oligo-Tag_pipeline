####Example Oligo/Tag reconstruction workflow.

*../run.VectorReconstruction_MPRA.sh oligos/CMS_MRPA_092018_60K.balanced.collapsed.seqOnly Example_run 1 CMS-MPRA\:dGFP_rep1.1.sample.fastq.gz CMS-MPRA\:dGFP_rep1.2.sample.fastq.gz*

##Key files

#Subset of Illumina 2x150 bp reads of ∆GFP vector insert.
CMS-MPRA:dGFP_rep1.1.sample.fastq.gz & CMS-MPRA:dGFP_rep1.2.sample.fastq.gz

#FLASH overlapping reads
Example_run.merged.rc.fasta

#Final Tag/Oligo lookup table
Example_run.merged.rc.match.enh.mapped.barcode.ct
[Barcode, Oligo(s), Total BC reads, individual read count, pass flag

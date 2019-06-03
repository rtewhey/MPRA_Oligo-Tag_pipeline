gzip -dc /projects/tewhey-lab/sequencing/20181211_NovaSeq_BroadWalkup/reads/CMS-MPRA:dGFP_rep1.1.fastq.gz | head -n 10000 | gzip >  CMS-MPRA:dGFP_rep1.1.sample.fastq.gz
gzip -dc /projects/tewhey-lab/sequencing/20181211_NovaSeq_BroadWalkup/reads/CMS-MPRA:dGFP_rep1.2.fastq.gz | head -n 10000 | gzip >  CMS-MPRA:dGFP_rep1.2.sample.fastq.gz
../run.VectorReconstruction_MPRA.sh oligos/CMS_MRPA_092018_60K.balanced.collapsed.seqOnly Example_run 1 CMS-MPRA\:dGFP_rep1.1.sample.fastq.gz CMS-MPRA\:dGFP_rep1.2.sample.fastq.gz 

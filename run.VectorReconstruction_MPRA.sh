########
INSTALL_DIR="/home/tewher/scripts"

REF=$1
ID=$2
THREADS=$3
READA=$4
READB=$5

${INSTALL_DIR}/flash -r 175 -f 274 -s 20 -o ${ID}.merged -t $THREADS $READA $READB > ${ID}.merged.log
perl ${INSTALL_DIR}/rev_c.pl ${ID}.merged.extendedFrags.fastq > ${ID}.merged.rc.fastq
perl ${INSTALL_DIR}/fq2fa.pl ${ID}.merged.rc.fastq > ${ID}.merged.rc.fasta
perl ${INSTALL_DIR}/matchadapter_v3.pl ${ID}.merged.rc.fasta ${ID}.merged.rc
awk '{print ">"$1"#"$5"\n"$4}' ${ID}.merged.rc.match > ${ID}.merged.rc.match.enh.fa
bwa mem  -L 100 -k 8 -O 5 -t $THREADS -M $REF ${ID}.merged.rc.match.enh.fa > ${ID}.merged.rc.match.enh.sam 2> ${ID}.merged.rc.match.enh.bwa.log
perl ${INSTALL_DIR}/SAM2MPRA.pl ${ID}.merged.rc.match.enh.sam ${ID}.merged.rc.match.enh.mapped
	
###

grep PASS ${ID}.merged.rc.match.enh.mapped  | sort -S2G -k4 > ${ID}.merged.rc.match.enh.mapped.enh.pass.sort
sort -S2G -k2 ${ID}.merged.rc.match.enh.mapped > ${ID}.merged.rc.match.enh.mapped.barcode.sort
perl ${INSTALL_DIR}/Ct_seq.pl ${ID}.merged.rc.match.enh.mapped.barcode.sort 2 4 > ${ID}.merged.rc.match.enh.mapped.barcode.ct
perl ${INSTALL_DIR}/Ct_seq.pl ${ID}.merged.rc.match.enh.mapped.enh.pass.sort 4 2 > ${ID}.merged.rc.match.enh.mapped.enh.pass.ct
awk '{ct[$4]++}END{for (i in ct)print i "\t" ct[i]}' ${ID}.merged.rc.match.enh.mapped.barcode.ct | sort -k1n > ${ID}.merged.rc.match.enh.mapped.barcode.ct.hist

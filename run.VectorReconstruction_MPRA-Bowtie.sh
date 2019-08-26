INSTALL_PATH=" /projects/tewher/bin/MPRA_Oligo-Tag_pipeline/scripts"

REF=$1
ID=$2
THREADS=$3
READA=$4
READB=$5

flash2 -r 150 -f 274 -s 20 -o ${ID}.merged -t $THREADS $READA $READB > ${ID}.merged.log
perl ${INSTALL_PATH}/fq2RCfa.pl ${ID}.merged.extendedFrags.fastq > ${ID}.merged.rc.fasta
perl ${INSTALL_PATH}/matchadapter.pl ${ID}.merged.rc.fasta ${ID}.merged.rc
awk '{print ">"$1"#"$5"\n"$4}' ${ID}.merged.rc.match > ${ID}.merged.rc.match.enh.fa
bowtie2 --norc --gbar 1 --very-sensitive -p $THREADS -x ${REF} -f ${ID}.merged.rc.match.enh.fa -S ${ID}.merged.rc.match.enh.sam > ${ID}.merged.rc.match.enh.log 2>&1
perl ${INSTALL_PATH}/SAM2MPRA.pl ${ID}.merged.rc.match.enh.sam ${ID}.merged.rc.match.enh.mapped
	
###

grep PASS ${ID}.merged.rc.match.enh.mapped  | sort -S2G -k4 > ${ID}.merged.rc.match.enh.mapped.enh.pass.sort
sort -S2G -k2 ${ID}.merged.rc.match.enh.mapped > ${ID}.merged.rc.match.enh.mapped.barcode.sort
perl ${INSTALL_PATH}/Ct_seq.pl ${ID}.merged.rc.match.enh.mapped.barcode.sort 2 4 > ${ID}.merged.rc.match.enh.mapped.barcode.ct
perl ${INSTALL_PATH}/Ct_seq.pl ${ID}.merged.rc.match.enh.mapped.enh.pass.sort 4 2 > ${ID}.merged.rc.match.enh.mapped.enh.pass.ct
awk '{ct[$4]++}END{for (i in ct)print i "\t" ct[i]}' ${ID}.merged.rc.match.enh.mapped.barcode.ct | sort -k1n > ${ID}.merged.rc.match.enh.mapped.barcode.ct.hist
preseq lc_extrap -H ${ID}.merged.rc.match.enh.mapped.barcode.ct.hist -o ${ID}.merged.rc.match.enh.mapped.barcode.ct.hist.preseq -s 10000000 -n 1000 -e 100000000
awk '($5 == 0)' ${ID}.merged.rc.match.enh.mapped.barcode.ct | awk '{ct[$2]++}END{for(i in ct)print i "\t" ct[i]}' >  ${ID}.merged.rc.match.enh.mapped.barcode.ct.tagCt
perl ${INSTALL_PATH}/parse_map.pl ${ID}.merged.rc.match.enh.mapped.barcode.ct > ${ID}.merged.rc.match.enh.mapped.barcode.ct.parsed

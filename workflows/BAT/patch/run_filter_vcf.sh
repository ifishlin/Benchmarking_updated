#!/bin/bash

module load samtools/1.9
module load segemehl/0.3.4
module load bcftools/1.10.2
module load htslib/1.11.0
module load R/4.0.0

#cp header_chr $ID1"".methylcall.vcf
#haarz.x callmethyl -d /home/y306n/yuyu/results/index/hg_GRCh38_PhiX_Lambda.fa -b mapped_$ID1/$ID1-$subID1"".bam -t 10|grep -v "^\[" >> $ID1"".methylcall.vcf

#bcftools sort -m 2048M -o $ID1"".methylcall_sorted.vcf.gz -O z -T tmp$3 $ID1"".methylcall.vcf > $ID1"".methylcall.vcf.log
#tabix -p vcf $ID1"".methylcall.vcf.gz > $ID1"".methylcall.vcf.gz.log
BAT_FILTER_VCF_CMD="/omics/groups/OE0219/internal/yuyu/results/LSF/BAT_filter_vcf~"

for f in *sorted.vcf.gz; do
   cg_name=$(echo $f|cut -f 1,2 -d ".")_CG.vcf.gz
   if [ ! -e $cg_name ]; then
     echo $cg_name
     nohup $BAT_FILTER_VCF_CMD --vcf $f --out $cg_name --context CG --MDP_min 1 --MDP_max 100 & 
   fi
done

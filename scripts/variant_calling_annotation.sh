#!/bin/bash
# variant_calling_annotation.sh
# Script for paired tumour-normal variant calling and annotation
# VarScan calling and Annovar annotation/filtering

# 1. Copy VarScan jar (example path)
cp -vR /data/teaching/bci_teaching/DNAseq/VarScan.v2.4.3.jar ./

# Load modules
module load samtools
module load java

# 2. Variant calling using VarScan
samtools mpileup \
-q 20 \
-f reference.fa \
Alignment/tumour.recalib.bam | \
java -jar VarScan.v2.4.3.jar mpileup2snp \
--min-coverage 20 \
--min-avg-qual 20 \
--min-read2 4 \
--p-value 0.2 \
--min-var-freq 0.01 \
--strand-filter 1 \
--output-vcf 1 > VCF/tumour.vcf

# 3. Annotation using Annovar

# Convert VCF to Annovar input
convert2annovar.pl --format vcf4 \
VCF/tumour.vcf \
--includeinfo \
--filter PASS \
--outfile VCF/tumour_variants.pass

# Filter variants against e.g. 1000 Genomes Project
annotate_variation.pl -filter \
-dbtype 1000g2015aug_all \
-buildver hg38 \
-out VCF/tumour_variant \
VCF/tumour_variants.pass \
Reference/humandb/ \
-maf 0.01

# Final annotation table
table_annovar.pl \
VCF/tumour_variant.hg38_esp6500siv2_all_filtered \
Reference/humandb/ \
-buildver hg38 \
-out VCF/tumour_variant \
-remove \
-otherinfo \
-protocol refGene,avsnp150,cosmic92_coding \
-operation g,f,f \
-nastring .

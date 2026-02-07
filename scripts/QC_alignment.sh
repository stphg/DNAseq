#!/bin/bash
# QC_alignment.sh
# Tumour-Normal DNA-seq QC, alignment, duplicate marking, and BQSR

# 1. FASTQ QC
module load fastqc
fastqc -o QC/ *.fq.gz 

# MultiQC summary
module load miniforge
mamba create --name multiqc -c bioconda multiqc
mamba activate multiqc
multiqc . -o .
mamba deactivate

# 2. Alignment using Bowtie2
module load bowtie2 samtools
mkdir -p Alignment

# Tumour
time bowtie2 -p 4 \
--rg ID:tumour --rg SM:tumour --rg PL:ILLUMINA --rg LB:tumour \
-x GRCh38.108.chr17 \
-1 tumour_R1.fq.gz -2 tumour_R2.fq.gz | \
samtools sort -o Alignment/tumour.sorted.bam -
  
  samtools flagstat Alignment/tumour.sorted.bam

# Normal
time bowtie2 -p 4 \
--rg ID:germline --rg SM:germline --rg PL:ILLUMINA --rg LB:germline \
-x GRCh38.108.chr17 \
-1 germline_R1.fq.gz -2 germline_R2.fq.gz | \
samtools sort -o Alignment/germline.sorted.bam -
  
  samtools flagstat Alignment/germline.sorted.bam

# 3. Mark Duplicates
module load gatk

# Tumour
gatk --java-options "-Xmx4G" MarkDuplicates \
-I Alignment/tumour.sorted.bam \
-M QC/tumour.marked \
-O Alignment/tumour.marked.bam

# Normal
gatk --java-options "-Xmx4G" MarkDuplicates \
-I Alignment/germline.sorted.bam \
-M QC/germline.marked \
-O Alignment/germline.marked.bam

# 4. Base Quality Score Recalibration (BQSR)

# Tumour
gatk --java-options "-Xmx4G" BaseRecalibrator \
-I Alignment/tumour.marked.bam \
-R reference.fa \
--known-sites known_variants.vcf \
-O Alignment/tumour.table

gatk --java-options "-Xmx4G" ApplyBQSR \
-R reference.fa \
-I Alignment/tumour.marked.bam \
--bqsr-recal-file Alignment/tumour.table \
-O Alignment/tumour.recalib.bam

# Normal
gatk --java-options "-Xmx4G" BaseRecalibrator \
-I Alignment/germline.marked.bam \
-R reference.fa \
--known-sites known_variants.vcf \
-O Alignment/germline.table

gatk --java-options "-Xmx4G" ApplyBQSR \
-R reference.fa \
-I Alignment/germline.marked.bam \
--bqsr-recal-file Alignment/germline.table \
-O Alignment/germline.recalib.bam

# DNA-seq Tumour-Normal Variant Analysis

## Overview 
This project demonstrates a DNA-seq analysis workflow for paired tumour and matched germline samples, focusing on data quality control, alignment, duplicate handling, and high-confidence variant calling.
The emphasis is on minimising technical artefacts and false positives, particularly relevant for low-frequency variant detection.

## Data
Paired-end FASTQ files:
- Tumour sample
- Matched germline control
** Public or simulated data were used. No patient-identifiable data are included.

## Workflow Summary
1. Raw read quality control (FASTQC, MultiQC)
2. Alignment to GRCh38 reference genome
3. Duplicate marking
4. Base Quality Score Recalibration (BQSR)
5. Post-processing QC assessment
6. Somatic variant calling (VarScan, Annovar, Mutect2)
7. Further filtering of VAF and filtered against population databases: 1000 Genomes Project, Exome sequencing project
---

## Quality Control
Initial QC showed:
- High mean PHRED scores indicating accurate base calling
- Balanced read counts between forward and reverse pairs
- Acceptable GC content with no evidence of library bias
- Low duplication rates, indicating high library complexity

These metrics support reliable downstream variant analysis.

## Alignment
Reads were aligned using Bowtie2 to GRCh38 (chr17), followed by sorting and indexing with samtools. Read group information was included to support downstream GATK-based analyses.

Post-alignment QC demonstrated:
- >98% mapping rate for both tumour and germline samples
- High proportion of properly paired reads
- No evidence of alignment artefacts

## Duplicate Marking
Duplicates were marked using GATK MarkDuplicates to prevent PCR-amplified fragments from artificially inflating variant allele frequencies. Marking duplicates preserves read-level information while allowing variant callers to ignore non-independent reads.

## Base Quality Score Recalibration
BQSR was performed using known variant sites to model and correct systematic sequencing errors. This step improves base quality accuracy and reduces false-positive variant calls.

## Post-processing QC
Final BAM statistics showed:
- ~1.2M duplicates out of ~30M reads (tumour)
- ~1.3M duplicates out of ~26M reads (germline)
- >98% mapped reads in both samples
- High proper pairing rates

These results indicate high-quality, analysis-ready BAM files suitable for somatic variant calling.

## Somatic variant calling (paired tumour-normal)
Somatic variants were identified using a paired tumour–normal approach. Variants were filtered based on VarScan and Mutect2 metrics and annotated with Annovar. Population databases were used to exclude common germline variants, including:
- 1000 Genomes Project (1000g2015aug_all)
- Exome Sequencing Project (esp6500siv2_all)

Variant allele frequency (VAF) was used as a prioritisation metric, with particular attention to low-frequency variants while retaining biologically relevant higher-VAF candidates.

## R-based Somatic VAF extraction
To assess somatic variation, variant allele frequencies (VAFs) were extracted from the FORMAT fields of the tumour–normal paired MultiAnnovar output.

- `Otherinfo13` corresponds to the matched normal sample
- `Otherinfo14` corresponds to the tumour sample
- The third FORMAT field represents the allele frequency (AF)

Extracting and comparing tumour and normal VAFs enables discrimination between germline background and true somatic events.

### e.g. TP53 Somatic Variant

Filtering for variants annotated to TP53 identified a single candidate somatic mutation with a tumour VAF of approximately 0.36. 
This VAF is consistent with a heterozygous somatic event in a tumour sample and is absent or minimal in the matched germline control, supporting its classification as a somatic mutation.

## Working Scripts

- [QC & Alignment Pipeline](scripts/QC_alignment.sh) – Bash pipeline demonstrating DNA-seq QC, alignment, duplicate marking, and BQSR for paired tumour-normal samples.
- [Variant Calling & Annotation](scripts/variant_calling_annotation.sh) – Bash pipeline of VarScan variant calling and Annovar annotation for tumour-only and paired tumour-normal samples.


## 💡Summary
- Rigorous QC at each stage is essential for reliable variant detection
- Duplicate handling is critical in low-frequency variant contexts
- Tumour–normal designs enable robust discrimination of somatic variants from germline background


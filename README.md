# DNA-seq Tumour-Normal Variant Analysis

## Overview 
This project demonstrates a DNA-seq analysis workflow for paired tumour and matched germline samples, focusing on data quality control, alignment, duplicate handling, and high-confidence variant calling.
The emphasis is on minimising technical artefacts and false positives, particularly relevant for low-frequency variant detection.

## Data
** Public or simulated data were used. No patient-identifiable data are included.

Paired-end FASTQ files:
- Tumour sample
- Matched germline control


## Pipeline Summary
1. Raw read QC (FastQC, MultiQC)
2. Alignment to GRCh38 reference genome (Bowtie2)
3. Sorting, indexing, and read group assignment (samtools)
4. Duplicate marking (GATK MarkDuplicates)
5. Base Quality Score Recalibration (GATK BQSR)
6. Post-alignment QC
7. Paired tumour–normal somatic variant calling (Mutect2, VarScan)
8. Variant annotation and filtering (Annovar, population databases)
9. Somatic VAF extraction and prioritisation (R)
---

## Quality Control Highlights
- High mean PHRED scores across all read positions
- Balanced forward/reverse read representation
- Acceptable GC content with no library bias
- Low duplication rates, indicating good library complexity
- ~98% mapping rate for both tumour and germline samples

These metrics indicate high-quality, analysis-ready files suitable for downstream somatic variant calling.

## Alignment
Reads were aligned using Bowtie2 to GRCh38 (chr17), followed by sorting and indexing with samtools. Read group information was included to support downstream GATK-based analyses.

Post-alignment QC demonstrated:
- 98% mapping rate for both tumour and germline samples
- High proportion of properly paired reads
- No evidence of alignment artefacts

## Duplicate Marking
Duplicates were marked using GATK MarkDuplicates to prevent PCR-amplified fragments from artificially inflating variant allele frequencies. Marking duplicates preserves read-level information while allowing variant callers to ignore non-independent reads.

## Base Quality Score Recalibration
BQSR was performed using known variant sites to model and correct systematic sequencing errors. This step improves base quality accuracy and reduces false-positive variant calls.

## Somatic variant calling (paired tumour-normal)
Somatic variants were identified using a paired tumour–normal approach to distinguish true somatic events from germline background.

Filtering criteria included:
- Variant caller confidence metrics (Mutect2, VarScan)
- Population frequency filtering:
  - 1000 Genomes Project
  - Exome Sequencing Project
- Variant allele frequency (VAF), with attention to low-frequency candidates

Variants were annotated using Annovar and prioritised based on functional impact and tumour-specific enrichment, retaining biologically relevant higher-VAF candidates.

## Somatic VAF extraction (R)
Tumour and normal VAFs were extracted from FORMAT fields in MultiAnnovar output:

- `Otherinfo13`: matched normal sample
- `Otherinfo14`: tumour sample
- Third FORMAT field corresponds to allele frequency (AF)

Comparing tumour and normal VAFs enables robust discrimination of somatic variants (distinguishing between germline vs true somatic events).

### e.g. TP53 Somatic Variant
Filtering for variants in **TP53** identified a candidate somatic mutation with:
- Tumour VAF ~0.36
- Minimal or absent signal in the matched germline control

This VAF is consistent with a heterozygous somatic event in a tumour sample and is absent or minimal in the matched germline control, supporting its classification as a somatic mutation.

## Working Scripts

- [QC & Alignment Pipeline](scripts/QC_alignment.sh) – Bash pipeline demonstrating DNA-seq QC, alignment, duplicate marking, and BQSR for paired tumour-normal samples.
- [Variant Calling & Annotation](scripts/variant_calling_annotation.sh) – Bash pipeline of VarScan variant calling and Annovar annotation for tumour-only and paired tumour-normal samples.
- [Extract Somatic VAF](scripts/extract_somatic_VAF.R) – R script demonstrating extraction of tumour and normal VAFs from MultiAnnovar output, filtering for exonic, non-synonymous variants, and highlighting somatic mutations (e.g. TP53).

## 💡Summary
- Rigorous QC at each stage is essential for reliable variant detection
- Duplicate handling is critical in low-frequency variant contexts
- Tumour–normal designs enable robust discrimination of somatic variants from germline background


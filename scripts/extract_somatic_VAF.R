#!/usr/bin/env Rscript
# extract_somatic_VAF.R
# Script for extracting somatic variant allele frequencies (VAF) from MultiAnnovar output

library(tidyverse)

# 1. Load annotated variants
file_path <- "VCF/tumour_variant.hg38_multianno.txt"
variants <- read.delim(file_path, header = TRUE)

# 2. Add tumour and normal VAF columns (from Otherinfo fields)
variants$Norm_VAF <- sapply(strsplit(variants$Otherinfo13, ":"), `[`, 3) %>% as.numeric()
variants$Tum_VAF  <- sapply(strsplit(variants$Otherinfo14, ":"), `[`, 3) %>% as.numeric()

# 3. Filter exonic, non-synonymous variants
exonic_variants <- subset(variants,
                          Func.refGene == "exonic" &
                          ExonicFunc.refGene != "synonymous SNV")

# 4. Filter for VAF > 10%
high_vaf_variants <- subset(exonic_variants, Tum_VAF > 0.10)

# 5. e.g Extract TP53 somatic variants
TP53_somatic <- subset(high_vaf_variants, grepl("TP53", Gene.refGene))

# 6. Print results
print("High-VAF exonic variants:")
print(high_vaf_variants)

print("TP53 somatic variant(s):")
print(TP53_somatic)
print(paste("Tumour VAF:", TP53_somatic$Tum_VAF))

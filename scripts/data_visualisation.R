library(ggplot2)

# Example/mock data
variants <- data.frame(
  Gene = c("TP53", "EGFR", "KRAS", "BRCA1"),
  Tum_VAF = c(0.36, 0.25, 0.12, 0.05)
)

# Histogram of VAFs
ggplot(variants, aes(x = Tum_VAF)) +
  geom_histogram(binwidth = 0.05, fill="skyblue", color="black") +
  labs(title="Tumor Variant Allele Frequency Distribution",
       x="VAF", y="Count") +
  theme_minimal()

# Specific gene variants
ggplot(variants, aes(x=Gene, y=Tum_VAF, fill=Gene)) +
  geom_bar(stat="identity") +
  labs(title="VAF of Selected Genes") +
  theme_minimal()

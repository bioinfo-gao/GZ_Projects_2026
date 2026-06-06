# Bioinformatics Analysis Report

Date: 2026-06-05
Project: 2026_Item16_ZhenYan

## 1. Overview
This report summarizes the differential expression analysis and quality control metrics for the RNA-seq dataset.
- **Analysis Tool**: DESeq2
- **Normalization**: VST (Variance Stabilizing Transformation) for PCA/Heatmap, Median-of-ratios for DE
- **Significance Thresholds**: padj <= 0.05, |log2FoldChange| >= 0.263 (20% fold change)

## 2. Gene Filtering Statistics
Genes were filtered using a two-tiered approach to ensure high-quality analysis:
- **Original gene count**: 63187
- **After gene type filtering** (ribosomal and non-protein coding genes removed): 54484
- **After low count filtering** (<10 counts in more than 2 samples removed): 14982
- **Final gene count for analysis**: 14982

## 3. Quality Control (QC)
- QC reports were generated using MultiQC.

## 4. Differential Expression Analysis Results

### Contrast: SMA4_vs_CTRL
- Total Significant Genes: 3328
  - Upregulated: 1601
  - Downregulated: 1727
- Output File: `DEG_SMA4_vs_CTRL.csv`

### Contrast: SMC2_vs_CTRL
- Total Significant Genes: 4135
  - Upregulated: 2040
  - Downregulated: 2095
- Output File: `DEG_SMC2_vs_CTRL.csv`

### Contrast: ME13_vs_CTRL
- Total Significant Genes: 3750
  - Upregulated: 1759
  - Downregulated: 1991
- Output File: `DEG_ME13_vs_CTRL.csv`

## 5. Visualizations

### Principal Component Analysis (PCA)
- **File**: `PCA.pdf`
- **Description**: Shows sample clustering based on the top 500 most variable genes. Samples should cluster by biological group if the treatment effect is strong.

### Volcano Plots
- **Files**: `Volcano_*.png`
- **Description**: Displays the relationship between statistical significance (-log10 padj) and magnitude of change (log2FC). Red points indicate upregulated genes, blue points indicate downregulated genes.

### Heatmaps
- **Files**: `Heatmap_top50_*.pdf`
- **Description**: Hierarchical clustering of the top 50 differentially expressed genes for each contrast separately. Each heatmap shows expression patterns (Z-score normalized) for the most significant genes in that specific comparison across all samples.

## 6. Generated Data Files

| File Name | Description |
| :--- | :--- |
| `All_sample_gene_counts.tsv` | Raw count matrix for all samples. |
| `All_sample_gene_tpm.tsv` | TPM (Transcripts Per Million) matrix, if available. |
| `Normalized_Counts.csv` | DESeq2 normalized counts for downstream analysis. |
| `DEG_*.csv` | Detailed differential expression results including log2FC, p-values, and base means. |
| `PCA.pdf` | PCA plot showing sample relationships. |
| `Volcano_*.png` | Volcano plots for each contrast. |
| `Heatmap_top50_*.pdf` | Heatmaps of top 50 DEGs for each contrast separately. |
| `QC/` | Directory containing MultiQC and other QC reports. |

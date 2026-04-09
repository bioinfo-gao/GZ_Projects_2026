### Bioinformatics Analysis Report
Project: RNA-seq Differential Expression Analysis for Tropaeolum majus  
Client: Sebastian Martinez-Salazar  
Date: April 8, 2026  


##### 1. Reference Genome Information
Species: Tropaeolum majus L. (Nasturtium)  
Source: Braunschweig University of Technology (TU Braunschweig)  
Assembly Version: Draft v1 (Computational prediction)  
Public Link: https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078092  
Annotation Status: Gene identifiers follow the TMxxxxx nomenclature. Functional symbols (e.g., gene names) are currently limited to computational predictions. Genes lacking curated names are flagged as Predicted_TMxxxxx in the output tables.

##### 2. Analysis Workflow Overview
Raw Data QC & Trimming: FastQC + Trimgalore (adapter removal, quality trimming, poly-G tail removal for NovaSeq X Plus).  
Alignment & Quantification: STAR aligner (2-pass mode) + Salmon (quasi-mapping for transcript-level quantification).  
Count Matrix Generation: Salmon estimated counts merged per gene (salmon.merged.gene_counts.tsv). Counts were rounded to integers as required by downstream statistical models.  
Quality Control & Metrics: MultiQC (aggregate reports), RSeQC, Qualimap, Picard MarkDuplicates, DupRadar.  
Differential Expression: DESeq2 (R/Bioconductor) with variance stabilizing transformation (VST) for visualization and ashr for log2 fold-change shrinkage.  
Sample Design: 34 biological replicates across 4 experimental groups. Mixed controls (TperMix, TtriMix) were excluded from differential testing.
  
##### 3. Differential Expression Analysis Standards
| Parameter | Criterion | Rationale |
|:---|:---|:---|
| Statistical Test | Wald test with Benjamini-Hochberg FDR correction | Controls false discovery rate across ~20k genes |
| LFC Shrinkage | `ashr` (adaptive shrinkage) | Stabilizes fold-changes for low-count genes, reduces false positives |
| Significance Threshold | `padj < 0.05` | Standard FDR cutoff for transcriptomics |
| Fold Change Cutoff | `\|log2FoldChange\| ≥ 1.0` | Equivalent to ≥2-fold expression difference |
| Pre-filtering | Genes with <10 counts in ≥4 samples removed | Eliminates technical noise & improves model convergence |
| Strand Specificity | Processed as stranded per library protocol | Ensures accurate assignment of antisense/transcript reads |
`

Output Columns :
gene_id | gene_name | [8x Sample Counts] | baseMean | log2FoldChange | lfcSE | pvalue | padj | sig (padj<0.05 & |log2FC|>=1)

##### 4. Software & Core Code Summary
Environment: R 4.5.x, Bioconductor 3.20, nf-core/rnaseq 3.15.1
Key R Packages: DESeq2, ashr, tidyverse, ggplot2, ggrepel


##### 5. Important Notes & Limitations
1. Draft Genome Context: The current reference is a predicted draft assembly. Gene IDs (TMxxxxx) may not correspond to fully curated orthologs. Functional annotation (GO/KEGG/InterPro) can be added via homology searches (BLASTp/DIAMOND) upon request.
2. Biological Replicates: Each experimental group contains 4 independent replicates, providing robust statistical power for DE detection.
3. Data Delivery: All raw counts, normalized matrices, DEG tables, QC reports, and publication-ready figures (PCA, Volcano, Heatmaps) are provided in the DE_PCA_Results/ directory.
4. Prepared by: Bioinformatics Analysis Team, Contact: zorin.gao@gmail.com
5. This report reflects the analysis performed on the data delivered as of April 2026. Re-analysis with updated genome builds or additional annotations can be conducted upon request.  
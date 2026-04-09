#!/usr/bin/env Rscript
# env 
# setwd("")
# 跑完的输出文件：
# DEG_WTS4vsWhS4.csv
# DEG_Wh1vsWh2.csv
# DEG_Wh3vsWh4.csv
# DEG_Wh5vsWh6.csv
# Volcano_WTS4vsWhS4.png
# Volcano_Wh1vsWh2.png
# Volcano_Wh3vsWh4.png
# Volcano_Wh5vsWh6.png
# PCA.pdf

#!/usr/bin/env Rscript
# ==========================================================
# nf-core RNA-seq 下游分析：PCA + 差异表达 + 可视化 (最终修正版)
# 对比顺序: c("分组变量", "处理组/分子", "对照组/分母")
# log2FC = log2(处理组 / 对照组)
# 正数 = 在处理组中上调；负数 = 在对照组中上调
# ==========================================================

# ================= 0. 依赖加载 =================
if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")
# BiocManager::install(c("DESeq2", "ashr", "pheatmap"))
# install.packages(c("ggplot2", "dplyr", "readr", "readxl", "tidyr", "ggrepel"))

library(DESeq2)
library(ashr)
library(ggplot2)
library(pheatmap)
library(dplyr)
library(readr)
library(readxl)
library(tidyr)
library(ggrepel)

# ================= 1. 路径设置 =================
META_FILE   <- "Sample_plant.xlsx"
COUNT_FILE  <- "../output_results/star_salmon/salmon.merged.gene_counts.tsv" 
OUT_DIR     <- "DE_PCA_Results"
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# ================= 2. 读取并清洗元数据 =================
meta_raw <- read_excel(META_FILE, sheet = 1)
meta <- meta_raw %>%
  select(Group, `Name in File`) %>%
  rename(sample_id = `Name in File`) %>%
  filter(!is.na(Group)) %>%          
  mutate(Group = factor(Group, levels = unique(Group)))

cat("✅ 元数据加载完成，有效样本数:", nrow(meta), "\n")

# ================= 3. 读取表达矩阵 & 预处理 =================
counts_raw <- read_tsv(COUNT_FILE, col_types = cols())
all_sample_cols <- colnames(counts_raw)[3:ncol(counts_raw)]
valid_samples <- all_sample_cols[!all_sample_cols %in% c("TperMix", "TtriMix")]

meta <- meta[meta$sample_id %in% valid_samples, ]
counts_mat <- as.matrix(counts_raw[, valid_samples])
rownames(counts_mat) <- counts_raw$gene_id
counts_mat <- counts_mat[, meta$sample_id]

counts_mat <- round(counts_mat)
keep <- rowSums(counts_mat >= 10) >= 4
counts_mat <- counts_mat[keep, ]

cat("✅ 表达矩阵加载完成，过滤后保留基因数:", nrow(counts_mat), "\n")

# ================= 4. DESeq2 建模 =================
dds <- DESeqDataSetFromMatrix(countData = counts_mat,
                              colData = meta,
                              design = ~ Group)
dds <- DESeq(dds)
vsd <- vst(dds, blind = FALSE)

# ================= 5. PCA 分析 (🔻 字体已调整) =================
pca_data <- plotPCA(vsd, intgroup = "Group", returnData = TRUE)
percentVar <- round(100 * attr(pca_data, "percentVar"))

p_pca <- ggplot(pca_data, aes(PC1, PC2, color = Group, label = name)) +
  geom_point(size = 0.5, alpha = 0.8) +              # 🔻 点大小：0.6 → 0.5
  geom_text(vjust = 1.5, hjust = 0.5, size = 2) +    # 🔻 标签：2.5 → 2
  xlab(paste0("PC1: ", percentVar[1], "% variance")) +
  ylab(paste0("PC2: ", percentVar[2], "% variance")) +
  theme_bw(base_size = 10) +                          # 🔻 全局字体：12 → 10
  scale_color_brewer(palette = "Set2") +
  theme(legend.position = "bottom", 
        legend.text = element_text(size = 7),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 9))
ggsave(file.path(OUT_DIR, "PCA.pdf"), p_pca, width = 8, height = 6, dpi = 300)
cat("✅ PCA 图已保存（字体已缩小）\n")

# ================= 6. 差异表达分析 (4 组对比) =================
# ✅ 对比组定义：c("分组列名", "处理组/分子", "对照组/分母")
# log2FC = log2(处理组均值 / 对照组均值)
# 正数 = 在处理组(第一个)中上调；负数 = 在对照组(第二个)中上调

contrasts <- list(
  c("Group", "WhS4", "WTS4"),   # ✅ WhS4 vs WTS4 → log2FC>0 = WhS4 上调
  c("Group", "Wh1",  "Wh2"),    # ✅ Wh1 vs Wh2 → log2FC>0 = Wh1 上调
  c("Group", "Wh3",  "Wh4"),    # ✅ Wh3 vs Wh4 → log2FC>0 = Wh3 上调
  c("Group", "Wh5",  "Wh6")     # ✅ Wh5 vs Wh6 → log2FC>0 = Wh5 上调
)

res_list <- list()
sig_col_name <- "sig (padj<0.05 & |log2FC|>=1)"

for (comp in contrasts) {
  grp_treatment <- comp[2]  # 处理组（分子）
  grp_control <- comp[3]    # 对照组（分母）
  comp_name <- paste(grp_treatment, "vs", grp_control, sep = "_")
  cat(paste0("\n🔍 正在分析: ", comp_name, " (处理:", grp_treatment, " vs 对照:", grp_control, ")\n"))
  
  # 提取 DESeq2 结果并收缩
  res <- results(dds, contrast = comp)
  res <- lfcShrink(dds, contrast = comp, type = "ashr")
  
  res_df <- as.data.frame(res)
  res_df$gene_id <- rownames(res_df)
  
  # 提取当前对比两组的原始 reads (8列)
  samples_treatment <- meta$sample_id[meta$Group == grp_treatment]
  samples_control <- meta$sample_id[meta$Group == grp_control]
  raw_sub <- counts_raw[, c("gene_id", "gene_name", samples_treatment, samples_control), drop = FALSE]
  
  # 合并结果与原始计数
  res_df <- left_join(res_df, raw_sub, by = "gene_id")
  
  # ✅ 严格按指定顺序排列列（处理组在前，对照组在后）
  final_cols <- c("gene_id", "gene_name", samples_treatment, samples_control, 
                  "baseMean", "log2FoldChange", "lfcSE", "pvalue", "padj")
  res_df <- res_df[, final_cols]
  
  # ✅ 添加 sig 列（列名已含标准）
  res_df[[sig_col_name]] <- case_when(
    res_df$padj < 0.05 & res_df$log2FoldChange >= 1  ~ "Up",
    res_df$padj < 0.05 & res_df$log2FoldChange <= -1 ~ "Down",
    TRUE ~ "NS"
  )
  
  # 保存 CSV
  write_csv(res_df, file.path(OUT_DIR, paste0("DEG_", comp_name, ".csv")))
  res_list[[comp_name]] <- res_df
  
  # 🌋 火山图 (🔻 字体已调整，去除黑体)
  res_df$negLog10Padj <- -log10(res_df$padj)
  res_df$negLog10Padj[!is.finite(res_df$negLog10Padj)] <- NA
  
  # 选取 Top 10 显著基因用于标注
  top_labels <- res_df %>%
    filter(.data[[sig_col_name]] != "NS", !is.na(negLog10Padj)) %>%
    arrange(padj) %>%
    head(10) %>%
    mutate(label = ifelse(is.na(gene_name) | gene_name == "", gene_id, gene_name))
  
  p_vol <- ggplot(res_df, aes(x = log2FoldChange, y = negLog10Padj, color = .data[[sig_col_name]])) +
    geom_point(alpha = 0.7, size = 0.5) +            # 🔻 点大小：0.6 → 0.5
    scale_color_manual(values = c("Up" = "#E41A1C", "Down" = "#377EB8", "NS" = "grey80")) +
    theme_bw(base_size = 10) +                        # 🔻 全局字体：12 → 10
    labs(title = paste(grp_treatment, "vs", grp_control, 
                       "(log2FC > 0 =", grp_treatment, "上调)"), 
         x = "log2 Fold Change", y = "-log10(adj. P-value)") +
    theme(plot.title = element_text(hjust = 0.5, size = 9),
          legend.position = "bottom", 
          legend.text = element_text(size = 7),
          axis.text = element_text(size = 8),
          axis.title = element_text(size = 9)) +
    # ✅ 去除黑体，使用普通字体
    geom_text_repel(data = top_labels, aes(label = label), 
                    size = 2,                          # 🔻 标签大小：2.5 → 2
                    box.padding = 0.3, 
                    max.overlaps = 20, 
                    color = "black", fontface = "plain")  # ✅ 去除 bold
  
  ggsave(file.path(OUT_DIR, paste0("Volcano_", comp_name, ".png")), p_vol, width = 8, height = 6, dpi = 300)
  cat(paste0("✅ ", comp_name, " 完成，显著差异基因: ", sum(res_df[[sig_col_name]] != "NS"), "\n"))
}


# # ================= 7. 热图 (🔻 字体已调整，去除黑体) =================
# first_comp <- names(res_list)[1]
# top_genes <- res_list[[first_comp]] %>% 
#   filter(.data[[sig_col_name]] != "NS") %>% 
#   arrange(padj) %>% 
#   head(50) %>% 
#   pull(gene_id)

# mat <- assay(vsd)[top_genes, ]
# mat <- t(scale(t(mat)))
# pheatmap(mat,
#          annotation_col = meta,
#          filename = file.path(OUT_DIR, paste0("Heatmap_top50_", first_comp, ".pdf")),
#          show_rownames = FALSE,
#          main = paste("Top 50 DEGs:", first_comp),
#          fontsize = 7,              # 🔻 字体：8 → 7
#          fontsize_row = 5,
#          fontsize_col = 7,
#          fontfamily = "sans")       # ✅ 使用无衬线字体，去除黑体

# cat("\n🎉 全部分析完成！结果已保存至:", OUT_DIR, "\n")
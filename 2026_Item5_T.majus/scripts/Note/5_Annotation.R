#!/usr/bin/env Rscript
# ================= 基因功能注释与富集分析 =================
# 物种: Tropaeolum majus
# ==========================================================
# BiocManager::install("clusterProfiler")
# 1. 确保 BiocManager 已安装
# if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")

# # 2. 使用 BiocManager 安装 Bioconductor 核心包
# BiocManager::install(
#   c("clusterProfiler", "enrichplot", "ggtree", "org.At.tair.db"),
#   update = FALSE,    # 避免自动更新其他包导致依赖冲突
#   ask = FALSE,       # 静默安装，不中断脚本
#   force = TRUE       # 强制重新安装缺失依赖
# )

library(clusterProfiler)
library(org.At.tair.db) # 使用拟南芥作为参考
library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(enrichplot)
library(Biostrings)
library(rtracklayer)

# ================= 1. 设置路径 =================
DEG_DIR <- "DE_PCA_Results"
OUT_DIR <- "Gene_Annotation_Results"
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# 参考基因组注释文件路径（需下载）
#GTF_FILE <- "../references/Tropaeolum_majus/T_majus.final.gtf"
GTF_FILE <- "T_majus.final.gtf"

gtf <- rtracklayer::import(GTF_FILE)




# ================= 2. 读取差异表达基因 =================
# 以第一组对比为例


# deg_file <- list.files(DEG_DIR, pattern = "DEG_.*\\.csv$", full.names = TRUE)[1]
deg_file <- list.files(DEG_DIR, pattern = "DEG_.*\\.csv$", full.names = TRUE)[2]
# deg_file <- list.files(DEG_DIR, pattern = "DEG_.*\\.csv$", full.names = TRUE)[3]
# deg_file <- list.files(DEG_DIR, pattern = "DEG_.*\\.csv$", full.names = TRUE)[4]

deg_df <- read_csv(deg_file)

# 提取显著差异基因
sig_genes <- deg_df %>%
  filter(`sig (padj<0.05 & |log2FC|>=1)` != "NS") %>%
  pull(gene_id)

# 分别提取上调和下调基因
up_genes <- deg_df %>%
  filter(`sig (padj<0.05 & |log2FC|>=1)` == "Up") %>%
  pull(gene_id)

down_genes <- deg_df %>%
  filter(`sig (padj<0.05 & |log2FC|>=1)` == "Down") %>%
  pull(gene_id)

cat("✅ 提取基因完成:\n")
cat("   总差异基因:", length(sig_genes), "\n")
cat("   上调基因:", length(up_genes), "\n")
cat("   下调基因:", length(down_genes), "\n")

# ================= 3. 从 GTF 文件提取基因注释 =================
if (file.exists(GTF_FILE)) {
  cat("\n📖 读取 GTF 注释文件...\n")
  gtf <- rtracklayer::import(GTF_FILE)
  
  # 查看可用的列
  cat("   GTF 可用列:", paste(colnames(mcols(gtf)), collapse = ", "), "\n")

  # 提取基因信息（根据实际 GTF 结构调整）
  gene_annot <- as.data.frame(mcols(gtf)) %>%
    filter(type == "gene") %>%
    dplyr::select(
      gene_id = gene_id,
      transcript_id = transcript_id
    ) %>%
    distinct()

  # 如果后续需要 gene_name，可以使用 gene_id 代替
  # 因为 T. majus 的 GTF 可能没有标准的 gene_name 字段
  if (!"gene_name" %in% colnames(gene_annot)) {
    gene_annot$gene_name <- gene_annot$gene_id
    cat("   ⚠️  GTF 中无 gene_name 字段，使用 gene_id 替代\n")
  }

  # 合并注释信息
  deg_annot <- left_join(deg_df, gene_annot, by = "gene_id")

  # 保存带注释的结果
  write_csv(deg_annot, file.path(OUT_DIR, "DEG_with_annotation.csv"))
  cat("✅ 基因注释已保存\n")
} else {
  cat("⚠️  未找到 GTF 文件，跳过本地注释\n")
}

# ================= 4. GO/KEGG 富集分析 =================
# 使用拟南芥同源基因进行富集（需先建立 ID 映射）

# 方法 1: 如果有基因描述信息，提取 Arabidopsis 同源基因
if (exists("deg_annot") && "description" %in% colnames(deg_annot)) {
  cat("\n🔬 进行 GO 富集分析...\n")

  # 准备基因列表（使用 gene_id）
  gene_list <- deg_df$log2FoldChange
  names(gene_list) <- deg_df$gene_id

  # 按 log2FC 排序
  gene_list <- sort(gene_list, decreasing = TRUE)

  # 如果 T. majus 有对应的 org 数据库，使用以下代码：
  # ego <- enrichGO(gene = sig_genes,
  #                 OrgDb = org.Tm.db,  # 需要构建
  #                 keyType = "GENEID",
  #                 ont = "ALL",
  #                 pAdjustMethod = "BH",
  #                 qvalueCutoff = 0.05)

  # 方法 2: 使用 clusterProfiler 的 compareCluster 进行多组比较
  gene_clusters <- list(
    Up = up_genes,
    Down = down_genes
  )

  cat("✅ 富集分析准备完成\n")
}

# ================= 5. 可视化 =================
# 5.1 差异基因分布图
p1 <- ggplot(deg_df, aes(x = log2FoldChange, y = -log10(padj))) +
  geom_point(
    aes(color = `sig (padj<0.05 & |log2FC|>=1)`),
    alpha = 0.6,
    size = 1
  ) +
  scale_color_manual(
    values = c("Up" = "#E41A1C", "Down" = "#377EB8", "NS" = "grey80")
  ) +
  theme_bw() +
  labs(
    title = "Volcano Plot",
    x = "log2 Fold Change",
    y = "-log10(adj. P-value)"
  )
ggsave(file.path(OUT_DIR, "Volcano_all_genes.png"), p1, width = 8, height = 6)

# 5.2 显著基因数量统计
stats_df <- data.frame(
  Category = c("Up-regulated", "Down-regulated", "Not Significant"),
  Count = c(
    length(up_genes),
    length(down_genes),
    nrow(deg_df) - length(sig_genes)
  )
)

p2 <- ggplot(stats_df, aes(x = Category, y = Count, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("#E41A1C", "#377EB8", "grey80")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file.path(OUT_DIR, "DEG_summary.png"), p2, width = 6, height = 5)

cat("\n🎉 注释和可视化完成！结果保存在:", OUT_DIR, "\n")

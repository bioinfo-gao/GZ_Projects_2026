# manba activate regular_bioinfo, 
# use the R in this environment

# --- 1. 环境加载 ---
library(tidyverse)
library(DESeq2)
library(writexl)
library(rtracklayer)

# --- 2. 路径定义 (严格按照您的最新要求) ---
base_dir   <- "/home/gao/projects/2026_Item6_UIC_02122603"
count_file <- file.path(base_dir, "Final_Filtered_Results/counts/filtered_counts_v150_matrix.txt")
gtf_file   <- "/Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/gencode.v45.annotation.gtf"
output_dir <- file.path(base_dir, "Final_Filtered_Results", "DEG_Results")

dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# --- 3. 加载并清洗 Count 矩阵 ---
message("正在读取 Count 矩阵...")
raw_df <- read.table(count_file, header = TRUE, skip = 1, row.names = 1, check.names = FALSE)

# 物理剔除 featureCounts 前 5 列 (Chr, Start, End, Strand, Length)
raw_counts <- raw_df[, 6:ncol(raw_df)]

# 修正列名：将 "Mock_3_long_150.bam" 简化为 "Mock_3"
# 这里适配您提供的 Mock_3_long_150.bam 格式
colnames(raw_counts) <- gsub("_long_150.bam", "", colnames(raw_counts))

# --- 4. 构建样本元数据 (Metadata) ---
samples <- colnames(raw_counts)
# 自动提取下划线前的组名：Mock, WT, vpr, Q65R
conditions <- gsub("_\\d+", "", samples) 

metadata <- data.frame(
    sample = samples,
    condition = factor(conditions, levels = c("Mock", "WT", "vpr", "Q65R"))
)
rownames(metadata) <- metadata$sample

# --- 5. 过滤蛋白编码基因 (~20,000 genes) ---
message("正在解析 Gencode v45 GTF 过滤蛋白编码基因...")
# 使用修复后的 rtracklayer 导入
annot_gr <- rtracklayer::import(gtf_file)
annot <- as.data.frame(annot_gr) %>% 
    filter(type == "gene") %>% 
    select(gene_id, gene_name, gene_type)

coding_genes <- annot %>% 
    filter(gene_type == "protein_coding") %>% 
    pull(gene_id)

counts_coding <- raw_counts[rownames(raw_counts) %in% coding_genes, ]
message(paste(">>> 过滤完成：从原始", nrow(raw_counts), "个基因中提取出", nrow(counts_coding), "个蛋白编码基因。"))

# --- 6. 运行 DESeq2 标准流程 ---
dds <- DESeqDataSetFromMatrix(countData = counts_coding, colData = metadata, design = ~ condition)
# 过滤掉各样本总和小于 10 的超低表达基因
dds <- dds[rowSums(counts(dds)) >= 10, ]
dds <- DESeq(dds)

# --- 7. 执行指定的 6 组对比并保存 ---
# 定义对比组：c("condition", "处理组", "对照组")
contrast_list <- list(
    "WT-vs-Mock"   = c("condition", "WT",   "Mock"),
    "Q65R-vs-Mock" = c("condition", "Q65R", "Mock"),
    "vpr-vs-Mock"  = c("condition", "vpr",  "Mock"),
    "Q65R-vs-WT"   = c("condition", "Q65R", "WT"),
    "vpr-vs-WT"    = c("condition", "vpr",  "WT"),
    "Q65R-vs-vpr"  = c("condition", "Q65R", "vpr")
)

all_results <- list()

for (res_id in names(contrast_list)) {
    message(paste(">>> 正在生成对比报告:", res_id))
    
    # 提取差异结果 (padj < 0.05)
    res_obj <- results(dds, contrast = contrast_list[[res_id]], alpha = 0.05)
    
    # 转换为 Data Frame 并合并基因名称
    res_df <- as.data.frame(res_obj) %>%
        rownames_to_column("gene_id") %>%
        left_join(annot, by = "gene_id") %>%
        arrange(padj) # 按显著性排序
    
    # 导出 CSV 文件
    write.csv(res_df, file.path(output_dir, paste0("DEG_results_", res_id, ".csv")), row.names = FALSE)
    
    # 存入列表供 Excel 汇总
    all_results[[res_id]] <- res_df
}

# --- 8. 最终汇总导出 ---
write_xlsx(all_results, path = file.path(output_dir, "Detailed_Information.xlsx"))
message("--- 分析全部完成！请在 DEG_Results 目录下查看结果 ---")

# --- 9. (可选) PCA 验证 ---
vsd <- vst(dds, blind = FALSE)
pca_plot <- plotPCA(vsd, intgroup = "condition") + 
    geom_text(aes(label = name), vjust = 1.5, size = 3) +
    theme_bw() + 
    ggtitle("PCA after 150bp Salvage & Protein Coding Filter")

print(pca_plot)
ggsave(file.path(output_dir, "PCA_Final_Check.png"), pca_plot, width = 8, height = 6)

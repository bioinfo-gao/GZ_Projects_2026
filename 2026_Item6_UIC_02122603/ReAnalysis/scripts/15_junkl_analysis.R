library(tidyverse)
library(writexl)

# --- 1. 定义路径 ---
trash_dir <- "/home/gao/projects/2026_Item6_UIC_02122603/Final_Filtered_Results/trash_analysis"
# 正常样本的 Count（作为基准，取主矩阵的前几列）
# 假设您已经加载了 counts_coding

# --- 2. 读取并清洗垃圾片段统计数据 ---
load_trash_stats <- function(file_path) {
  df <- read.table(file_path, header = TRUE, skip = 1, row.names = 1)
  return(df[, 6, drop = FALSE]) # 只取 Count 列
}

wt2_trash <- load_trash_stats(file.path(trash_dir, "WT_2_trash_stats.txt"))
mock3_trash <- load_trash_stats(file.path(trash_dir, "Mock_3_trash_stats.txt"))

# --- 3. 核心诊断：查找垃圾片段中的“超级大户” ---
# 将 ID 转换成 Gene Name 方便阅读
diagnose_trash <- function(trash_counts, top_n = 20) {
  trash_counts %>%
    rownames_to_column("gene_id") %>%
    left_join(annot, by = "gene_id") %>%
    mutate(percentage = (.[, 2] / sum(.[, 2])) * 100) %>%
    arrange(desc(percentage)) %>%
    head(top_n)
}

wt2_report <- diagnose_trash(wt2_trash)
mock3_report <- diagnose_trash(mock3_trash)

print("--- WT_2 垃圾片段前20名大户 ---")
print(wt2_report[, c("gene_name", "percentage", "gene_type")])

print("--- Mock_3 垃圾片段前20名大户 ---")
print(mock3_report[, c("gene_name", "percentage", "gene_type")])

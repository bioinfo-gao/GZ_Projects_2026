library(tidyverse)
library(writexl)

# --- 1. 设置路径与加载注释 ---
trash_dir <- "/home/gao/projects/2026_Item6_UIC_02122603/Final_Filtered_Results/trash_analysis"
output_report <- file.path(base_dir, "Final_Filtered_Results", "DEG_Results", "Sample_Degradation_Forensic_Report.xlsx")

# --- 2. 自动化诊断函数 ---
generate_forensic_data <- function(file_name, sample_label) {
    file_path <- file.path(trash_dir, file_name)
    
    if (!file.exists(file_path)) {
        message(paste("警告: 找不到文件", file_path))
        return(NULL)
    }
    
    # 读取 featureCounts 输出
    df <- read.table(file_path, header = TRUE, skip = 1, row.names = 1)
    counts <- df[, 6, drop = FALSE]
    colnames(counts) <- "Trash_Count"
    
    # 计算百分比并合并基因信息
    report <- counts %>%
        rownames_to_column("gene_id") %>%
        left_join(annot, by = "gene_id") %>%
        mutate(
            Sample = sample_label,
            Percentage = round((Trash_Count / sum(Trash_Count)) * 100, 3)
        ) %>%
        select(Sample, gene_name, Trash_Count, Percentage, gene_type, gene_id) %>%
        arrange(desc(Percentage)) %>%
        head(20) # 提取前20名大户
    
    return(report)
}

# --- 3. 生成两个异常样本的报告 ---
wt2_trash_report <- generate_forensic_data("WT_2_trash_stats.txt", "WT_2 (Outlier)")
mock3_trash_report <- generate_forensic_data("Mock_3_trash_stats.txt", "Mock_3 (Outlier)")

# --- 4. 汇总并导出 ---
combined_report <- rbind(wt2_trash_report, mock3_trash_report)

# 同时保存为 Excel (方便客户查看) 和 CSV (备份)
write_xlsx(list("Trash_Top20_Diagnosis" = combined_report), path = output_report)
write.csv(combined_report, gsub(".xlsx", ".csv", output_report), row.names = FALSE)

message(">>> 证据文件已生成：Sample_Degradation_Forensic_Report.xlsx")
print(combined_report)
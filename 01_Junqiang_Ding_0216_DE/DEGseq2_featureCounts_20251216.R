#!/usr/bin/env Rscript

# ================================
#   DEG_pipeline.R
#   自动化差异表达分析与可视化
#   支持命令行参数和复杂输入文件处理
#   2025年12月16日更新
#   e.g.
#   Rscript DEGseq2_featureCounts_20251216.R --input featureCounts_output.txt --group_file sample_info.txt --output Set1_results --comparisons Set1-vs-Control
# ================================

# ----------- 加载依赖包 -----------
suppressMessages({
  library(DESeq2)
  library(ggplot2)
  library(pheatmap)
  library(RColorBrewer)
  library(optparse)
})

# ----------- 命令行参数设置 -----------
option_list <- list(
  make_option(c("-i", "--input"), type="character", default=NULL, 
              help="Input TSV file path", metavar="character"),
  make_option(c("-o", "--output"), type="character", default="DEG_results", 
              help="Output directory [default= %default]", metavar="character"),
  make_option(c("-s", "--skip_lines"), type="integer", default=0, 
              help="Number of lines to skip at the beginning of the file [default= %default]", metavar="integer"),
  make_option(c("-g", "--group_file"), type="character", default=NULL, 
              help="Group information file path (required)", metavar="character"),
  make_option(c("-p", "--padj_threshold"), type="numeric", default=0.05, 
              help="Adjusted p-value threshold for significance [default= %default]", metavar="numeric"),
  make_option(c("-f", "--fc_threshold"), type="numeric", default=1.1, 
              help="Fold change threshold for significance [default= %default]", metavar="numeric"),
  make_option(c("-c", "--comparisons"), type="character", default=NULL, 
              help="Specified comparisons in format GroupA-vs-GroupB (multiple comparisons separated by comma) [default: all pairwise comparisons]", metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# 检查必要参数
if (is.null(opt$input) || is.null(opt$group_file)){
  print_help(opt_parser)
  stop("Input file and group file must be provided.", call.=FALSE)
}

# ----------- 函数定义：处理输入文件 -----------
process_input_file <- function(file_path, skip_lines, out_dir) {
  # 读取文件，跳过头几行
  print(paste("Reading input file:", file_path))
  print(paste("Skipping", skip_lines, "lines"))
  
  counts_all <- read.table(file_path, header = TRUE, sep = "\t", 
                           skip = skip_lines, check.names = FALSE)
  
  print("Processing input file...")
  
  # 1. 处理Chr列：按照";"分割，取第一个值
  if ("Chr" %in% colnames(counts_all)) {
    counts_all$Chr <- sapply(strsplit(as.character(counts_all$Chr), ";"), "[[", 1)
    print("Chr column processed.")
  }
  
  # 2. 处理第7列到最后的bam文件名称
  if (ncol(counts_all) >= 7) {
    for (i in 7:ncol(counts_all)) {
      col_name <- colnames(counts_all)[i]
      # 用最后一个"/"后的内容
      filename <- basename(col_name)
      # 取第一个"."号前的部分
      sample_name <- strsplit(filename, "\\.")[[1]][1]
      # 替换列名
      colnames(counts_all)[i] <- sample_name
    }
    print("Sample columns renamed.")
  }
  
  # 3. 设置基因名作为行名
  if ("Geneid" %in% colnames(counts_all)) {
    rownames(counts_all) <- counts_all$Geneid
    print("Gene IDs set as row names.")
  }
  

# 4. 只保留Geneid和样品数据列（第7列开始）
  print("Filtering columns to keep only Geneid and sample data...")
  # 检查Geneid列是否存在
  if ("Geneid" %in% colnames(counts_all)) {
    # 保留Geneid列和从第7列开始的样品数据列
    filtered_counts <- counts_all[, c("Geneid", colnames(counts_all)[7:ncol(counts_all)])]
    print(paste("Kept columns:", paste(colnames(filtered_counts), collapse = ", ")))
  } else {
    # 如果没有Geneid列，只保留从第7列开始的样品数据列
    filtered_counts <- counts_all[, 7:ncol(counts_all)]
    print(paste("Kept columns:", paste(colnames(filtered_counts), collapse = ", ")))
  }
 
  # 5. 过滤条件：只保留在至少一个样本中计数 > 1 的基因
  print("Filtering rows where sum of 7 samples > 1...")
  # 计算每行的样品数值之和（排除Geneid列）
  if ("Geneid" %in% colnames(filtered_counts)) {
    # 计算第2列到最后一列的和
    keeps <- rowSums(round(filtered_counts[, 2:ncol(filtered_counts)]) > 1) > 0
  } else {
    # 计算所有列的和
    keeps <- rowSums(round(filtered_counts) > 1) > 0
  }
  
  # 过滤行
  filtered_counts <- filtered_counts[keeps, ]
  print(paste("Number of genes after filtering:", nrow(filtered_counts)))
  
  # 6. 保存处理后的数据到文件
  output_file <- file.path(out_dir, "All_samples_raw_counts.csv")
  print(paste("Saving processed data to:", output_file))
  write.table(filtered_counts, file = output_file, sep = ",", quote = FALSE, row.names = FALSE, col.names = TRUE)
  print("Data saved successfully.")

  # 7. 返回处理后的counts数据，用于下面的分析
  return(counts_all)
}

# ----------- 函数定义：读取分组文件 -----------
read_group_file <- function(group_file_path) {
  print(paste("Reading group file:", group_file_path))
  group_info <- read.table(group_file_path, header = TRUE, sep = ",", 
                           check.names = FALSE)
  
  # 确保文件格式正确
  if (ncol(group_info) < 2) {
    stop("Group file must have at least two columns: sample and condition.", call.=FALSE)
  }
  
  # 设置列名
  colnames(group_info)[1] <- "sample"
  colnames(group_info)[2] <- "condition"
  
  print("Group information loaded:")
  print(table(group_info$condition))
  
  return(group_info)
}

# ----------- 函数定义：执行差异分析并保存结果 -----------
run_deseq2_comparison <- function(dds, condition1, condition2, output_dir, padj_threshold, fc_threshold, counts_data, coldata) {
  # 设置比较条件
  comparison_name <- paste(condition1, "-vs-", condition2, sep = "")
  print(paste("Running comparison:", comparison_name))
  
  # 执行差异分析
  res <- results(dds, contrast = c("condition", condition2, condition1))  # 注意对比方向。第一个元素为分组变量，第二个元素为比较组，第三个元素为控制组。
  resOrdered <- res[order(res$padj), ]
  
  # 计算 Fold Change (非 log2)
  resOrdered$FoldChange <- 2^(resOrdered$log2FoldChange)
  
  # 添加上下调信息
  resOrdered$regulation <- ifelse(resOrdered$FoldChange >= fc_threshold & resOrdered$pvalue < 0.05, "Up",
                           ifelse(resOrdered$FoldChange < 1 & resOrdered$pvalue < 0.05, "Down", "No"))      # 1/fc_threshold 为下调阈值
  
  # 添加显著性标记
  resOrdered$significant <- ifelse(resOrdered$padj < padj_threshold & resOrdered$regulation != "No", "Yes", "Notsig")
  
  # 提取原始counts数据
  print(paste("Adding raw counts for condition1 (", condition1, ") and condition2 (", condition2, ")", sep = ""))
  
  # 获取control组和比较组的样品
  control_samples <- coldata$sample[coldata$condition == condition1]
  test_samples <- coldata$sample[coldata$condition == condition2]
  
  # 按照control组在前、比较组在后的顺序排列样品
  ordered_samples <- c(control_samples, test_samples)
  
  # 从counts_data中提取对应样品的counts
  raw_counts <- counts_data[rownames(resOrdered), ordered_samples]
  
  # 合并差异分析结果和原始counts
  res_df <- as.data.frame(resOrdered)
  res_df <- cbind(raw_counts, res_df)
  res_df$Geneid <- rownames(res_df)  # 将行名转换为gene_id列
  
  # 将Geneid列移到第一列
  res_df <- res_df[, c("Geneid", setdiff(colnames(res_df), "Geneid"))]
  
  # 输出结果文件
  res_file <- file.path(output_dir, paste0("DEG_results_", comparison_name, ".csv"))
  write.table(res_df, res_file, sep = ",", row.names = FALSE, quote = FALSE)  # 关闭行名输出
  
  cat(paste("Results saved to:", res_file, "\n"))
  
  return(resOrdered)
}






# ----------- 主程序 -----------
# 1. 创建输出目录
print(paste("Creating output directory:", opt$output))
dir.create(opt$output, showWarnings = FALSE, recursive = TRUE)

# 2. 处理输入文件
counts_all <- process_input_file(opt$input, opt$skip_lines, opt$output)

# 3. 提取计数数据（第7列及以后）
if (ncol(counts_all) >= 7) {
  counts_data <- counts_all[, 7:ncol(counts_all)]
  print(paste("Extracted", ncol(counts_data), "sample columns for analysis."))
  print("Sample names in counts file:")
  print(colnames(counts_data))
} else {
  stop("Input file must have at least 7 columns (Geneid, Chr, Start, End, Strand, Length, and sample data).", call.=FALSE)
}

# 4. 读取分组信息
group_info <- read_group_file(opt$group_file)

# 5. 构建样本信息表（metadata）
print("Preparing sample metadata...")

# 确保分组文件中的样本与counts文件中的样本匹配
common_samples <- intersect(colnames(counts_data), group_info$sample)

if (length(common_samples) == 0) {
  stop("No matching samples found between counts file and group file.", call.=FALSE)
}

if (length(common_samples) < length(colnames(counts_data))) {
  missing_samples <- setdiff(colnames(counts_data), group_info$sample)
  print(paste("Warning: The following samples in counts file are not in group file:", paste(missing_samples, collapse=", ")))
  print("These samples will be excluded from analysis.")
  
  # 只保留匹配的样本
  counts_data <- counts_data[, common_samples]
}

if (length(common_samples) < length(group_info$sample)) {
  extra_samples <- setdiff(group_info$sample, colnames(counts_data))
  print(paste("Warning: The following samples in group file are not in counts file:", paste(extra_samples, collapse=", ")))
  print("These samples will be excluded from analysis.")
}

# 构建coldata
coldata <- group_info[group_info$sample %in% common_samples, ]
coldata <- coldata[match(common_samples, coldata$sample), ]  # 确保顺序一致

# 设置因子水平
coldata$condition <- factor(coldata$condition)

rownames(coldata) <- coldata$sample

print("Sample metadata after filtering:")
print(coldata)

# 6. 构建 DESeq2 数据集
# 6. 构建 DESeq2 数据集前先过滤基因
print("Filtering genes with very low counts...")

# 过滤条件：只保留在至少一个样本中计数 > 1 的基因
keep <- rowSums(round(counts_data) > 1) > 0
filtered_counts <- counts_data[keep, ]

print(paste("Number of genes before filtering:", nrow(counts_data)))
print(paste("Number of genes after filtering:", nrow(filtered_counts)))
print(paste("Number of genes removed:", nrow(counts_data) - nrow(filtered_counts)))

# 使用过滤后的counts数据创建DESeqDataSet
print("Creating DESeq2 dataset with filtered genes...")
dds <- DESeqDataSetFromMatrix(countData = round(filtered_counts),
                              colData = coldata,
                              design = ~ condition)

# 同时更新传递给run_deseq2_comparison函数的counts_data
counts_data <- filtered_counts

# 7. 运行 DESeq2 分析
print("Running DESeq2 analysis...")
dds <- DESeq(dds)

# 8. 生成所有两两比较的组合
print("Generating comparisons...")

if (is.null(opt$comparisons)) {
  # 如果没有指定比较组，执行所有两两比较
  print("No specific comparisons specified, running all pairwise comparisons...")
  all_conditions <- levels(coldata$condition)
  all_comparisons <- combn(all_conditions, 2)
  
  # 循环执行所有两两比较
  for (i in 1:ncol(all_comparisons)) {
    condition1 <- all_comparisons[1, i]
    condition2 <- all_comparisons[2, i]
    run_deseq2_comparison(dds, condition1, condition2, opt$output, opt$padj_threshold, opt$fc_threshold, counts_data, coldata)
  }

} else {

  # 如果指定了比较组，按照参数执行比较
  print("Running specified comparisons...")
  specified_comparisons <- unlist(strsplit(opt$comparisons, ","))
  
  for (comp in specified_comparisons) {
    # 解析比较组
    groups <- unlist(strsplit(comp, "-vs-"))
    if (length(groups) != 2) {
      stop(paste("Invalid comparison format:", comp, ". Expected format: GroupA-vs-GroupB"), call.=FALSE)
    }
    
    condition1 <- groups[1]
    condition2 <- groups[2]
    
    # 检查组名是否存在
    if (!(condition1 %in% levels(coldata$condition)) || !(condition2 %in% levels(coldata$condition))) {
      stop(paste("Group names not found in condition levels:", comp), call.=FALSE)
    }
    
    run_deseq2_comparison(dds, condition1, condition2, opt$output, opt$padj_threshold, opt$fc_threshold, counts_data, coldata)
  }
}

# 9. 完成所有比较
print("All comparisons completed!")
print(paste("All results saved in:", opt$output))

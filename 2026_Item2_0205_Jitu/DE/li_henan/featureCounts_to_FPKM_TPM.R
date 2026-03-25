#!/usr/bin/env Rscript

## =========================
## 1. 解析命令行参数
## =========================

# 加载必要的包
library(optparse)

# 定义命令行参数
option_list <- list(
  make_option(c("-i", "--input"), type="character", default="gene_counts.txt", 
              help="Input featureCounts file [default: %default]"),
  make_option(c("-o", "--output_prefix"), type="character", default="Gene", 
              help="Output file prefix [default: %default]")
)

# 解析命令行参数
opt_parser <- OptionParser(option_list=option_list, description = "Calculate FPKM and TPM from featureCounts output")
opt <- parse_args(opt_parser)

# 获取输入文件路径
counts_file <- opt$input

## =========================
## 2. 读取数据
## =========================

fc <- read.delim(counts_file, comment.char = "#", check.names = FALSE)

## =========================
## 3. 处理Chr、Start、End、Strand列的分号分隔值
## =========================

# 处理Chr列，分割后取第一个值
fc$Chr <- sapply(strsplit(as.character(fc$Chr), ";"), function(x) x[1])

# 处理Start列，分割后取第一个值
fc$Start <- as.numeric(sapply(strsplit(as.character(fc$Start), ";"), function(x) x[1]))

# 处理End列，分割后取最后一个值
fc$End <- as.numeric(sapply(strsplit(as.character(fc$End), ";"), function(x) x[length(x)]))

# 处理Strand列，分割后取第一个值
fc$Strand <- sapply(strsplit(as.character(fc$Strand), ";"), function(x) x[1])

## =========================
## 4. 处理表头的样品名
## =========================

# 获取当前的列名
col_names <- colnames(fc)

# 提取counts数据列的索引（从第7列开始是样本）
count_cols <- 7:ncol(fc)

# 处理样品名：从路径中提取样品名（如XF01）
new_sample_names <- sapply(col_names[count_cols], function(name) {
  # 1. 首先提取文件名（处理可能包含完整路径的情况）
  filename <- basename(name)
  
  # 2. 提取第一个"."之前的部分作为样品名
  # 匹配任何前缀，只要它是第一个"."之前的部分
  sample_name <- regmatches(filename, regexpr("^[^.]+", filename))
  
  return(sample_name)
})

# 更新列名
colnames(fc)[count_cols] <- new_sample_names

## =========================
## 5. 过滤条件：每行中至少有一个样品的counts数据>=2
## =========================

# 过滤行：至少有一个样品的counts数据>=2
fc_filtered <- fc[apply(fc[, count_cols], 1, function(row) any(row >= 2)), ]

## =========================
## 6. 计算FPKM和TPM
## =========================

# 提取必要的信息
count_mat <- fc_filtered[, count_cols]

# 计算FPKM
lib_size <- colSums(count_mat)
fpkm <- sweep(count_mat, 2, lib_size / 1e6, "/")
fpkm <- sweep(fpkm, 1, fc_filtered$Length / 1e3, "/")
colnames(fpkm) <- paste0(colnames(fpkm), "_FPKM")            # 为FPKM列添加后缀_FPKM

# 计算TPM
rpk <- sweep(count_mat, 1, fc_filtered$Length / 1e3, "/")
rpk_sum <- colSums(rpk)
tpm <- sweep(rpk, 2, rpk_sum / 1e6, "/")
colnames(tpm) <- paste0(colnames(tpm), "_TPM")       # 为TPM列添加后缀_TPM

## =========================
## 7. 输出结果（保留所有列信息）
## =========================

# 构建输出文件名
fpkm_output <- paste0(opt$output_prefix, "_FPKM_matrix.csv")
tpm_output <- paste0(opt$output_prefix, "_TPM_matrix.csv")

# 输出FPKM结果：原始列 + FPKM列
fpkm_result <- cbind(fc_filtered, fpkm)
write.table(
  fpkm_result,
  file = fpkm_output,
  sep = ",",
  quote = FALSE,
  row.names = FALSE
)

# 输出TPM结果：原始列 + TPM列
tpm_result <- cbind(fc_filtered, tpm)
write.table(
  tpm_result,
  file = tpm_output,
  sep = ",",
  quote = FALSE,
  row.names = FALSE
)

cat(paste0("✔ FPKM and TPM calculation finished\n"))
cat(paste0("FPKM output file: ", fpkm_output, "\n"))
cat(paste0("TPM output file: ", tpm_output, "\n"))

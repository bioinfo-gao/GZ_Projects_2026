# mamba deactivate 
# 加入 --override-channels 确保它只走你配置好的清华源，不去撞墙
# --override-channels: 这一行是关键。它告诉 Mamba：“别去管那个报错的 anaconda.org 了，只看我给你的这几个清华镜像站。”
# 避免 SSL 错误: 因为清华源在境内，连接非常稳定，不会出现那种“unexpected eof”的断开情况。
# 缓存复用: 你刚才运行时的日志显示 Using cache，这意味着即使重新运行，它也会从上次下载进度继续。
# mamba create -n DE_R44 \
#     --override-channels \
#     -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/ \
#     -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ \
#     -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ \
#     r-base=4.4 \
#     bioconductor-deseq2 \
#     r-ggplot2 \
#     bioconductor-tximport \
#     r-pheatmap \
#     r-ggrepel
# 创建一个名为 DE_Final 的纯净 R 4.4 环境

# 创建一个名为 DE_Final 的纯净 R 4.5 环境, the following command run in BASH! <=======
# mamba create -y -n DE_R45 -c bioconda -c conda-forge \
#     r-base=4.5 \
#     bioconductor-deseq2 \
#     r-ggplot2 \
#     bioconductor-tximport \
#     r-pheatmap \
#     r-ggrepel

# mamba activate DE_R45
# 运行脚本
# Rscript DE_analysis.R

# 也可以进去“手动”操作（进入 R 交互界面）
# 1. 加载必要的包
library(DESeq2)
library(ggplot2) 

# 2. 读取数据
# 确保文件路径正确，就是我们刚刚合并出来的那个矩阵
#setwd("/home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216/")
#setwd("/home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216/results/star_salmon")
setwd("/home/gao/projects/2026_Item2_0205_Jitu/output/star_salmon")
counts_data <- read.table("salmon.merged.gene_counts.tsv", header = TRUE, row.names = 1, check.names = FALSE)
head(counts_data )
counts_data[1:5, 1:5]

# 3. 保存 gene_name 列以便后续 merge，然后对数值列取整 (DESeq2 要求整数计数)
# 检查是否存在 gene_name 列
if("gene_name" %in% colnames(counts_data)) {
    gene_name_column <- counts_data[, "gene_name", drop = FALSE]  # 保持数据框格式
    counts_data <- counts_data[, setdiff(colnames(counts_data), "gene_name"), drop = FALSE]
} else {
    gene_name_column <- NULL
    counts_data <- counts_data[, sapply(counts_data, is.numeric), drop = FALSE]
}
gene_name_column
dim(gene_name_column)

counts_data <- round(counts_data)
dim(counts_data)
counts_data

# 4. 构建样本信息表 (Coldata)
samples <- colnames(counts_data)

# 打印样本名称以确认顺序
cat("样本名称顺序:\n")
print(samples)

# 设置因子水平，第一个水平为参考水平（对照组）
# 当前设置：C1 是对照组（reference level），ch1/ch2/ch3 会与 C1 比较
# C2 和 C3 也是独立水平，但不是默认的参考对照
groups <- factor(
    c(rep("C1", 4), rep("C2", 4), rep("C3", 4), 
      rep("ch1", 4), rep("ch2", 4), rep("ch3", 4)),
    levels = c("C1", "C2", "C3", "ch1", "ch2", "ch3")  # C1 是参考水平 <<======
)

# 创建 coldata 并检查对应关系
col_data <- data.frame(row.names = samples, condition = groups)
cat("\n样本与分组对应关系:\n")
print(col_data)

# 5. 构建 DESeq2 对象
dds <- DESeqDataSetFromMatrix(countData = counts_data,
                              colData = col_data,
                              design = ~ condition)
# 6. 运行差异分析
dds <- DESeq(dds)

# --- 核心函数：调整列顺序并排序，并合并 gene_name ---
process_res_exact_samples <- function(res, counts, samples_to_keep, filename, gene_names = NULL) {
    res_df <- as.data.frame(res)
    
    # 统一命名 Q-value
    colnames(res_df)[colnames(res_df) == "padj"] <- "Q_value"
    
    # 核心修改：从原始矩阵中【只提取】参与当前比较的样本列
    subset_counts <- counts[, samples_to_keep]
    
    # 合并：[目标组别样本] + [统计指标]
    final_res <- cbind(subset_counts, res_df)
    
    # 如果有 gene_name，则合并到结果中
    if (!is.null(gene_names) && nrow(gene_names) > 0) {
        # 确保 gene_name 是数据框格式
        if (is.vector(gene_names)) {
            gene_names <- data.frame(gene_name = gene_names, row.names = rownames(counts))
        }
        # 按行名合并 gene_name
        final_res <- cbind(gene_names, final_res)
    }
    
    # 排序：Q_value 升序，abs(log2FoldChange) 降序
    final_res <- final_res[order(final_res$Q_value, -abs(final_res$log2FoldChange), na.last = TRUE), ]
    
    # 保存结果
    write.csv(final_res, filename, quote = FALSE)
    cat("生成文件:", filename, " (前 5 行显示):\n")
    print(head(final_res, 5))
    cat("\n")
}

# 4. 执行三次两两比较（配对设计：C1/C2/C3 为独立对照组，ch1/ch2/ch3 为对应处理组）
getwd()  # 检查当前工作目录
setwd("/home/gao/projects/2026_Item2_0205_Jitu/DE")

# 查看 DESeq2 的结果名称，确认可用的对比
print(resultsNames(dds))

# 打印实际样本名称用于核对
cat("\n实际样本列名:\n")
print(colnames(counts_data))

# 配对设计，而不是 所有组与 C1 相比
# 1) ch1 vs C1: 第一对独立对照 (C1: 前 4 个样本，ch1: 第 13-16 个样本)
res1 <- results(dds, contrast = c("condition", "ch1", "C1"))
process_res_exact_samples(res1, counts_data, 
                          colnames(counts_data)[c(1:4, 13:16)],  # C1 + ch1 的样本
                          "DE_ch1_vs_C1.csv",
                          gene_name_column)  # 传入 gene_name

# 2) ch2 vs C2: 第二对独立对照 (C2: 第 5-8 个样本，ch2: 第 17-20 个样本)
res2 <- results(dds, contrast = c("condition", "ch2", "C2"))
process_res_exact_samples(res2, counts_data, 
                          colnames(counts_data)[c(5:8, 17:20)],  # C2 + ch2 的样本
                          "DE_ch2_vs_C2.csv",
                          gene_name_column)  # 传入 gene_name

# 3) ch3 vs C3: 第三对独立对照 (C3: 第 9-12 个样本，ch3: 第 21-24 个样本)
res3 <- results(dds, contrast = c("condition", "ch3", "C3"))
process_res_exact_samples(res3, counts_data, 
                          colnames(counts_data)[c(9:12, 21:24)],  # C3 + ch3 的样本
                          "DE_ch3_vs_C3.csv",
                          gene_name_column)  # 传入 gene_name

# 9. 绘制 PCA 图检查样本聚类情况 - 为每组对比生成独立的 PCA 图
vsd <- vst(dds, blind = FALSE)

# 1) ch1 vs C1 的 PCA (只包含这两组的 8 个样本)
samples_ch1_c1 <- c(rownames(col_data)[1:4], rownames(col_data)[13:16])
vsd_ch1_c1 <- vsd[, samples_ch1_c1]
pca_ch1_c1 <- plotPCA(vsd_ch1_c1, intgroup = "condition") + 
              theme_minimal() + 
              ggtitle("PCA Plot: ch1 vs C1 (n=8)")
ggsave("PCA_ch1_vs_C1.png", pca_ch1_c1, width = 8, height = 6)

# 2) ch2 vs C2 的 PCA (只包含这两组的 8 个样本)
samples_ch2_c2 <- c(rownames(col_data)[5:8], rownames(col_data)[17:20])
vsd_ch2_c2 <- vsd[, samples_ch2_c2]
pca_ch2_c2 <- plotPCA(vsd_ch2_c2, intgroup = "condition") + 
              theme_minimal() + 
              ggtitle("PCA Plot: ch2 vs C2 (n=8)")
ggsave("PCA_ch2_vs_C2.png", pca_ch2_c2, width = 8, height = 6)

# 3) ch3 vs C3 的 PCA (只包含这两组的 8 个样本)
samples_ch3_c3 <- c(rownames(col_data)[9:12], rownames(col_data)[21:24])
vsd_ch3_c3 <- vsd[, samples_ch3_c3]
pca_ch3_c3 <- plotPCA(vsd_ch3_c3, intgroup = "condition") + 
              theme_minimal() + 
              ggtitle("PCA Plot: ch3 vs C3 (n=8)")
ggsave("PCA_ch3_vs_C3.png", pca_ch3_c3, width = 8, height = 6)

# 4) 所有样本的整体 PCA 图（24 个样本，独立坐标）
pca_all <- plotPCA(vsd, intgroup = "condition") + 
           theme_minimal() + 
           ggtitle("PCA Plot: All Samples (n=24)")
ggsave("PCA_all_samples.png", pca_all, width = 10, height = 8)

cat("DE Analysis Complete!\n")
cat("Files generated:\n")
cat("- 3 CSV files with differential expression results and gene names\n")
cat("- 4 independent PCA plots (each with its own axis scale):\n")
cat("  * PCA_ch1_vs_C1.png (8 samples)\n")
cat("  * PCA_ch2_vs_C2.png (8 samples)\n")
cat("  * PCA_ch3_vs_C3.png (8 samples)\n")
cat("  * PCA_all_samples.png (24 samples)\n")

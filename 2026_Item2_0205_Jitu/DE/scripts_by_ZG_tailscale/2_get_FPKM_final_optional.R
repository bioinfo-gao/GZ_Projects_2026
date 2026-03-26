# 在 nf-core/rnaseq 流程中（特别是使用 --aligner star_salmon 时），默认不会生成 FPKM (Fragments Per Kilobase Million) 矩阵，只提供 Raw Counts 和 TPM。

# 这是一个刻意的设计。在当前的生物信息学界，TPM 已经全面取代了 FPKM/RPKM，成为基因表达量标准化的首选指标。

# 以下是具体的解释以及如果你确实需要 FPKM 的解决方案：

# 1. 为什么流程抛弃了 FPKM，只给 TPM？
# 虽然 FPKM 和 TPM 都是为了消除测序深度和基因长度对表达量带来的影响，但它们的计算顺序不同，导致了统计学上的致命差异：

# FPKM 的缺陷：每个样本计算出来的 FPKM 总和是不一样的。这意味着你不能直接在两个样本之间比较同一个基因的 FPKM 值（比如样本 A 的 FPKM 是 10，样本 B 的 FPKM 是 10，并不代表该基因在两个样本中的绝对表达比例一样）。

# TPM 的优势：TPM 的计算机制保证了每个样本的 TPM 总和永远是 1,000,000。这使得不同样本之间的表达量比例可以直接横向比较，符合统计学直觉。

# 💡 行业现状：目前主流的高分文章和审稿人通常会要求提供 TPM 而不是 FPKM。如果不是为了复现非常老旧的文献或满足某个特定的老旧软件要求，强烈建议直接使用已经生成的 salmon.merged.gene_tpm.tsv。

# 2. 如果非要 FPKM，如何生成？
# 由于 nf-core 不会为你输出现成的 FPKM，最标准、最准确的方法是利用现有的输出结果，在 R 语言 中自己计算。

# 你手头已经拥有了计算 FPKM 所需的所有原始要素：

# Raw Counts: salmon.merged.gene_counts.tsv (基因的绝对 count 数)

# Effective Length: salmon.merged.gene_lengths.tsv (Salmon 计算出的基因有效长度)



# mamba inmamba install bioconductor-genomicfeatures bioconductor-txdbmaker -c bioconda -c conda-forge -y
# above 7 min
# mamba install bioconductor-genomicfeatures -c bioconda -c conda-forge -y # 10 min 
# mamba install bioconductor-txdbmaker -c bioconda -c conda-forge -y 
# install.packages("BiocManager", repos = "https://cran.rstudio.com/")
# BiocManager::install("txdbmaker") # 这个程序不应该用R安装，几十分钟很慢，所以用Python来处理


# =============================== gene and transcript TPM already produced =============================================
# =============================== lenths already produced =============================================
# ===== /home/gao/projects/2026_Item2_0205_Jitu/output/star_salmon/salmon.merged.gene_tpm.tsv    ==================
# ===== /home/gao/projects/2026_Item2_0205_Jitu/output/star_salmon/salmon.merged.gene_lengths.tsv  ==============
# ===== /home/gao/projects/2026_Item2_0205_Jitu/output/star_salmon/salmon.merged.transcript_tpm.tsv  ==============
# ===== /home/gao/projects/2026_Item2_0205_Jitu/output/star_salmon/salmon.merged.transcript_lengths.tsv  ==============
# =====================================================================================================================

library(BiocManager)
library(txdbmaker)
library(GenomicFeatures)

getwd() #setwd("/home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216/Final_Report") 
setwd("/home/gao/projects/2026_Item2_0205_Jitu/DE") 

# 1. 定义文件路径
#cat("正在解析 GRCm39.109 GTF 文件...\n")
gtf_path <- "/home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.gtf"

#counts_path <- "salmon.merged.gene_counts.tsv"
counts_path <- "samples.merged.gene_counts.tsv"


# 2. 构建 TxDb 并计算基因长度 (非重叠外显子之和)
txdb <- makeTxDbFromGFF(gtf_path, format="gtf")
exons_list <- exonsBy(txdb, by="gene")
gene_lengths <- sum(width(reduce(exons_list)))
length_df <- data.frame(gene_id = names(gene_lengths), length = gene_lengths)

# 3. 读取 Counts 数据
counts <- read.table(counts_path, header = TRUE, row.names = 1, check.names = FALSE)

# 4. 匹配基因 ID
# 注意：Ensembl 的 GTF 通常带有版本号 (如 ENSMUSG00000000001.4)
# 如果你的 Counts 表里没有小数点后的版本号，需要先剔除
# rownames(counts) <- gsub("\\..*", "", rownames(counts)) 

common <- intersect(rownames(counts), length_df$gene_id)
counts_final <- counts[common, ]
lengths_final <- length_df[match(common, length_df$gene_id), "length"]

cat(sprintf("成功匹配到 %d 个基因进行计算。\n", length(common)))

# 5. 计算 FPKM 和 TPM
calc_metrics <- function(counts, lengths) {
    total_reads <- colSums(counts) / 1e6
    gene_kb <- lengths / 1e3
    
    # FPKM
    fpkm <- counts / gene_kb
    fpkm <- t(t(fpkm) / total_reads)
    
#     # TPM
#     tpm <- t(t(fpkm) / colSums(fpkm)) * 1e6
  return(list(fpkm=fpkm))
}

results <- calc_metrics(counts_final, lengths_final)

# 6. 保存结果
#write.table(fpkm, "salmon.merged.gene_fpkm.tsv", sep="\t", quote=FALSE, col.names=NA)
write.table(results$fpkm, "salmon.merged.gene_fpkm.tsv", sep="\t", quote=FALSE, col.names=NA)
# write.table(results$tpm, "salmon.merged.gene_tpm.tsv", sep="\t", quote=FALSE, col.names=NA)

cat("计算完成！文件已生成：\n- salmon.merged.gene_fpkm.tsv\n- salmon.merged.gene_tpm.tsv\n")
# https://gemini.google.com/app/053e07830616e3cd?utm_source=app_launcher&utm_medium=owned&utm_campaign=base_all
在使用 DESeq2 进行差异表达分析之前，将 6 万多个基因（包含大量 lncRNA、假基因等）过滤到约 2 万个蛋白质编码基因 (Protein-coding genes) 是非常标准且推荐的做法。这能显著降低多重假设检验的惩罚（FDR 校正），提高统计灵敏度。

以下是使用 biomaRt 包进行精准过滤的完整 R 代码：

🛠️ 预备工作：安装必要包
如果你还没有安装这些包，请先运行：

R
if (!require("biocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install(c("biomaRt", "DESeq2"))
💻 R 代码实现
R
library(biomaRt)
library(DESeq2)

# 1. 加载你的表达量矩阵 (Raw Counts)
# 假设你的文件名为 salmon.merged.gene_counts.tsv，且第一列是 Ensembl ID (如 ENSG00000139618)
counts_data <- read.delim("salmon.merged.gene_counts.tsv", row.names = 1, check.names = FALSE)

# 如果你的 ID 带有版本号 (如 ENSG00000139618.15)，需要去掉小数点后缀
rownames(counts_data) <- gsub("\\..*$", "", rownames(counts_data))

# 2. 连接 Ensembl 数据库 (使用人类 GRCh38 基因组)
# 注意：连接可能受网络环境影响，建议多次尝试或使用镜像
mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")

# 3. 获取基因类型 (Biotype) 信息
# 我们根据 Ensembl ID 匹配对应的基因类型
genes_info <- getBM(
  attributes = c("ensembl_gene_id", "external_gene_name", "gene_biotype"),
  filters = "ensembl_gene_id",
  values = rownames(counts_data),
  mart = mart
)

# 4. 筛选蛋白质编码基因 (Protein-coding)
# 人类大约有 19,000 - 20,000 个此类基因
pc_genes <- genes_info[genes_info$gene_biotype == "protein_coding", ]

# 5. 根据筛选结果过滤原始矩阵
# 取交集，确保矩阵中只保留蛋白质编码基因
keep_ids <- intersect(rownames(counts_data), pc_genes$ensembl_gene_id)
filtered_counts <- counts_data[keep_ids, ]

# 打印过滤前后的基因数量对比
cat("过滤前基因数:", nrow(counts_data), "\n")
cat("过滤后蛋白质编码基因数:", nrow(filtered_counts), "\n")

# 6. 进入 DESeq2 流程
# 假设你已经准备好了样本信息表 colData
# dds <- DESeqDataSetFromMatrix(countData = round(filtered_counts), 
#                              colData = col_data, 
#                              design = ~ condition)
📝 核心要点说明
ID 版本号处理：biomaRt 的数据库通常不带版本号（如 .15），而 GENCODE 的 GTF 文件（如你之前用的 v45）通常带有版本号。使用 gsub("\\..*$", "", ...) 可以确保两者匹配。

基因类型筛选：gene_biotype == "protein_coding" 是最关键的过滤条件。如果你对长链非编码 RNA 感兴趣，也可以修改条件为 gene_biotype %in% c("protein_coding", "lncRNA")。

网络稳定性：biomaRt 需要连接海外服务器。如果遇到连接超时，可以尝试更换镜像源，例如：
mart <- useEnsembl(biomart = "genes", dataset = "hsapiens_gene_ensembl", mirror = "useast") (备选镜像：uswest, asia)。

💡 为什么这样做更科学？
如果你不进行这一步，DESeq2 在计算 results() 时的 padj (Adjusted P-value) 会因为测试了太多“永远不会显著”的假基因而变得非常保守。通过过滤，原本在 0.06 徘徊的 padj 很有可能降到 0.05 以下，从而为你多争取到几十甚至上百个显著差异基因。

你的样本信息表（Condition/Group）准备好了吗？如果需要，我可以接着为你写一套标准的 DESeq2 差异分析及火山图绘制流程。
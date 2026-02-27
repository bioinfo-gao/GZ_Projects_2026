# install.packages("SeuratData")
# # if (!require("BiocManager", quietly = TRUE))
# #     install.packages("BiocManager")
# BiocManager::install("SeuratData")
# remotes::install_github("satijalab/seurat-data") # 直接从 GitHub 安装最新版本的 SeuratData 包, This works !!
# 启动 R 后的操作
library(Seurat)
library(dplyr)
#library(SeuratData)

# 1. 传统流程（读取原始 10X 数据） (假设你解压了 pbmc3k 数据到 data/ 目录)
# pbmc.data <- Read10X(data.dir = "data/filtered_gene_bc_matrices/hg19/")
# pbmc <- CreateSeuratObject(counts = pbmc.data, project = "pbmc3k", min.cells = 3, min.features = 200)
# 这里得到的是：

# 🔹 只包含原始 counts
# 🔹 没有做标准化
# 🔹 没有 PCA
# 🔹 没有聚类
# 🔹 是一个“干净的初始对象”


InstallData("pbmc3k")
pbmc <- LoadData("pbmc3k")

# 这个返回的是：
# 🔹 已经 CreateSeuratObject
# 🔹 已经 NormalizeData
# 🔹 已经 FindVariableFeatures
# 🔹 已经 ScaleData
# 🔹 已经 RunPCA
# 🔹 甚至可能已经聚类
# 换句话说：
# 它是一个“处理过的完整对象”

# 1 “完全复现教程流程”
# 重置为只保留 counts, 这样就变成“原始状态”。
pbmc <- CreateSeuratObject(
  counts = pbmc@assays$RNA@counts,
  project = "pbmc3k",
  min.cells = 3,
  min.features = 200
)

# 2. 质控 (QC) - 对应 sc.pp.calculate_qc_metrics
pbmc[["percent.mt"]] <- PercentageFeatureSet(pbmc, pattern = "^MT-")

# 3. 过滤 - 对应 adata = adata[... , :]
pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5)

# 4. 归一化 - 对应 sc.pp.normalize_total 和 sc.pp.log1p
pbmc <- NormalizeData(pbmc, normalization.method = "LogNormalize", scale.factor = 10000)

# 5. 寻找高变基因 - 对应 sc.pp.highly_variable_genes
pbmc <- FindVariableFeatures(pbmc, selection.method = "vst", nfeatures = 2000)

# 6. 标准化（缩放）- 对应 sc.pp.scale
pbmc <- ScaleData(pbmc, features = rownames(pbmc))

# 7. 降维 (PCA) - 对应 sc.tl.pca
pbmc <- RunPCA(pbmc, features = VariableFeatures(object = pbmc))

# 8. 聚类 (Leiden/Louvain) - 对应 sc.tl.leiden
pbmc <- FindNeighbors(pbmc, dims = 1:10)
pbmc <- FindClusters(pbmc, resolution = 0.5)

# 9. UMAP 可视化 - 对应 sc.tl.umap 和 sc.pl.umap
pbmc <- RunUMAP(pbmc, dims = 1:10)
DimPlot(pbmc, reduction = "umap", label = TRUE)
FeaturePlot(pbmc, features = c("CST3", "NKG7"))
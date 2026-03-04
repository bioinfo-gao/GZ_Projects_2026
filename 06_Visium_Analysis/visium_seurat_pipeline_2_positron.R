# visium_seurat_pipeline.R
library(Seurat)
library(ggplot2)
library(patchwork)
library(dplyr)

# 1. 读取 Visium 真实数据
# 假设你从 10x 官网下载了小鼠大脑数据集，解压在 "mouse_brain_data" 文件夹中
# 该文件夹内必须包含：filtered_feature_bc_matrix.h5 和 spatial/ 文件夹
getwd()
setwd("~/GZ_Projects_2026/06_Visium_Analysis")
#data_dir <- "~/GZ_Projects_2026/06_Visium_Analysis/mouse_brain_data"
data_dir <- "mouse_brain_data"

# 使用专门的 Load10X_Spatial 函数，它会自动读取矩阵并对齐 H&E 图像
brain_spatial <- Load10X_Spatial(
  data.dir = data_dir,
  #filename = "filtered_feature_bc_matrix.h5",
  filename = "V1_Adult_Mouse_Brain_filtered_feature_bc_matrix.h5",
  assay = "Spatial"
)
print(dim(brain_spatial))
counts <- LayerData(brain_spatial, layer = "counts")
keep_genes <- rowSums(counts > 0) >= 3
brain_spatial <- brain_spatial[keep_genes, ]
print(dim(brain_spatial))
print(head(brain_spatial))
# 2. 数据质控 (QC)
# Visium 的 spot 可能会落入无组织的空白区域，需要过滤线粒体和低表达 spot
brain_spatial <- PercentageFeatureSet(
  brain_spatial,
  "^mt-",
  col.name = "percent.mt"
)
brain_spatial <- subset(
  brain_spatial,
  subset = nFeature_Spatial > 200 & percent.mt < 20
)
print(dim(brain_spatial))

# 3. 归一化与数据缩放 (强烈推荐对空间数据使用 SCTransform，能更好地处理测序深度差异)
# brain_spatial <- SCTransform(brain_spatial, assay = "Spatial", return.only.var.genes = FALSE, verbose = FALSE)
# `vst.flavor` is set to 'v2' but could not find glmGamPoi installed.
# Please install the glmGamPoi package for much faster estimation.
# --------------------------------------------
# install.packages('BiocManager')
# BiocManager::install('glmGamPoi')
# --------------------------------------------
# Falling back to native (slower) implementation.
## ====> # 使用 mamba 安装 Bioconductor 包，这比 R 内部安装快得多且更稳定
#mamba install bioconductor-glmgampoi -c conda-forge -c bioconda

# 尝试使用 v1 模式，它对极小数据集的兼容性更好
brain_spatial <- SCTransform(
  brain_spatial,
  assay = "Spatial",
  vst.flavor = "v1", # 临时切换到 v1 绕过统计学崩溃
  verbose = TRUE
)

# 1. 查看每个 Spot 平均检测到多少个基因
mean_features_per_spot <- mean(brain_spatial$nFeature_Spatial)
print(paste("平均每个 Spot 检测到的基因数:", mean_features_per_spot))

# 2. 查看每个 Spot 平均有多少个 UMI (分子计数)
mean_counts_per_spot <- mean(brain_spatial$nCount_Spatial)
print(paste("平均每个 Spot 的总 UMI 数:", mean_counts_per_spot))

# 3. 检查零表达比例 (极重要)
zero_count_percent <- sum(LayerData(brain_spatial, layer = "counts") == 0) /
  (19652 * 2312) *
  100
print(paste("矩阵中 0 的比例:", round(zero_count_percent, 2), "%"))

# [1] "平均每个 Spot 检测到的基因数: 6261.10423875433"
# [1] "平均每个 Spot 的总 UMI 数: 34356.035467128"
# [1] "矩阵中 0 的比例: 63.75 %"

# 4. 降维与聚类 (这部分与 scRNA-seq 一模一样)
brain_spatial <- RunPCA(brain_spatial, assay = "SCT", verbose = FALSE)
brain_spatial <- FindNeighbors(brain_spatial, reduction = "pca", dims = 1:30)
brain_spatial <- FindClusters(brain_spatial, verbose = FALSE, resolution = 0.8)
brain_spatial <- RunUMAP(brain_spatial, reduction = "pca", dims = 1:30)

# 5. 可视化 (空间专属)
# 5.1 在 UMAP 上看分群
p1 <- DimPlot(brain_spatial, reduction = "umap", label = TRUE)

# 5.2 将分群结果投射回真实的组织切片(H&E图像)上
# 这一步是 Visium 最惊艳的功能
p2 <- SpatialDimPlot(brain_spatial, label = TRUE, label.size = 3)

# 5.3 观察特定基因（比如海马体 marker 基因 Hpca）在组织上的空间表达分布
p3 <- SpatialFeaturePlot(brain_spatial, features = "Hpca") # 选择一个在大脑中特异表达的基因

p1 + p2 / p3

# 将图谱保存到服务器
ggsave(
  "visium_analysis_results.pdf",
  plot = p1 + p2 / p3,
  width = 15,
  height = 10
)

print("Visium pipeline completed successfully!")

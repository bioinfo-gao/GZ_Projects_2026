# 1. 加载核心库
library(Seurat)
library(BPCells)
library(ggplot2)

# 2. 读取数据 (10x Visium 标准路径)
#data_path <- "~/GZ_Projects_2026/data/visium_brain/outs"
#raw_spatial <- Load10X_Spatial(data.dir = data_path)
data_path <- "/home/zhen/GZ_Projects_2026/data/visium_brain/outs"
# 2. 读取数据
# 我们显式指定 filename 为刚才重命名的文件夹
raw_spatial <- Load10X_Spatial(
  data.dir = data_path,
  filename = "filtered_feature_bc_matrix"  # 确保这个名字和 outs 下的文件夹名一致
)
# 3. 核心内存优化：将矩阵转为磁盘存储 (BPCells)
# 这一步非常关键，它会让你的 10G 内存感觉像 64G 一样宽裕
# 矩阵会被存在 'brain_counts_bin' 文件夹下
counts_bp <- write_matrix_dir(mat = raw_spatial[["RNA"]]$counts, dir = "brain_counts_bin")
brain <- CreateSeuratObject(counts = counts_bp, assay = "RNA")
brain[["Slice1"]] <- raw_spatial[["Slice1"]]
rm(raw_spatial); gc() # 释放初始内存

# 4. 运行标准化 (针对笔记本 CPU 优化)
# method = "glmGamPoi" 需要安装该包，如果没装会自动跳过
brain <- SCTransform(brain, assay = "RNA", verbose = TRUE)

# 5. 降维与聚类
brain <- RunPCA(brain, assay = "SCT", verbose = FALSE)
brain <- FindNeighbors(brain, reduction = "pca", dims = 1:30)
brain <- FindClusters(brain, verbose = FALSE)
brain <- RunUMAP(brain, reduction = "pca", dims = 1:30)

# 6. 可视化 (RStudio 内部画图面板)
# 空间聚类图
SpatialDimPlot(brain, label = TRUE, label.size = 3)

# 标志基因空间表达图
SpatialFeaturePlot(brain, features = c("Hpca", "Ttr"))
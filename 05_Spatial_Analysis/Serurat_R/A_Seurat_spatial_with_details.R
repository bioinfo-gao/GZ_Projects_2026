library(Seurat)
library(BPCells)
library(ggplot2)

# 1. 设置路径（请务必使用绝对路径）
base_path <- "/home/zhen/GZ_Projects_2026/data/visium_brain/outs"
matrix_path <- file.path(base_path, "filtered_feature_bc_matrix")
spatial_path <- file.path(base_path, "spatial")

# 2. 读取矩阵 (MTX 格式文件夹)
# 注意：Read10X 专门处理包含三个 .gz 文件的文件夹
message("正在读取矩阵...")
counts <- Read10X(data.dir = matrix_path) # seurat

# 3. 核心内存优化：立即将矩阵写入磁盘
# 这一步将 9.7G 内存压力转移到硬盘，防止 R 崩溃
message("正在转换为 BPCells 磁盘存储...")
counts_bp <- write_matrix_dir(mat = counts, dir = "brain_counts_bp")
rm(counts); gc() # 立即清理内存中的原始矩阵

# 4. 创建 Seurat 对象
brain <- CreateSeuratObject(counts = counts_bp, assay = "RNA")
sc_obj <- brain
getwd()
setwd("/home/zhen/GZ_Projects_2026/03_Panel_Design")
# dir.create("/home/zhen/GZ_Projects_2026/data/saved_rds/", recursive = TRUE) 
# data_path = "/home/zhen/GZ_Projects_2026/data/saved_rds/"
# # saveRDS(sc_obj, file = "../your_scRNA_data.rds") data_path
# saveRDS(brain, file = paste0(data_path, "/your_scRNA_data.rds"))
# sc_obj <- readRDS("../your_scRNA_data.rds")
summary(brain)

# 查看整体维度 (返回：基因总数 行 x 细胞/Spot总数 列)
dim(sc_obj)
#[1] 32285  4992

# 查看 Seurat 对象的简要结构报告
sc_obj
# An object of class Seurat 
# 32285 features across 4992 samples within 1 assay 
# Active assay: RNA (32285 features, 0 variable features)
#1 layer present: counts

# 查看细胞级别的宏观统计 (Metadata)
# Metadata 是最核心的表格，记录了每个细胞的测序深度、所属聚类等
head(sc_obj@meta.data)
# orig.ident nCount_RNA nFeature_RNA
# AAACAACGAATAGTTC-1 SeuratProject       7259         2963
# AAACAAGTATCTCCCA-1 SeuratProject      20935         5230

# 查看细胞/Spot 的总 UMI 数量的最小值、中位数、均值、最大值
summary(sc_obj$nCount_RNA)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 77    2144   15070   18740   30340  156413 
sc_obj@meta.data
sc_obj_max = sc_obj@meta.data
sc_obj_max
sc_obj_max[sc_obj_max$nCount_RNA==77, ]
sc_obj_max[sc_obj_max$nCount_RNA==156413, ]

sc_obj@images
sc_obj$nCount_RNA



# 方法 A：Seurat 官方捷径（最推荐）
# Seurat 内部的寻找高变基因函数，其实就已经帮你把每个基因的 Mean 和 Variance 算得清清楚楚了：
# 
# R
# 运行高变基因计算 (如果之前跑过可省略)
sc_obj1 <- FindVariableFeatures(sc_obj, selection.method = "vst")

# 直接提取每个基因的 Mean(均值) 和 Variance(方差/标准化方差)
gene_stats <- HVFInfo(sc_obj1)
head(gene_stats) 
# 输出结果将包含：mean, variance, variance.standardized


# 方法 B：硬核矩阵提取法（适用于自定义算法）
# 如果你想自己写公式算，你需要把隐藏在对象深处的“稀疏矩阵 (Sparse Matrix)”抽出来：
# 
# R
library(Matrix) # 处理稀疏矩阵必需

# 1. 提取原始 Count 矩阵 (Seurat V5 标准写法)
# 如果你还在用 V4，写法是: counts_mat <- GetAssayData(sc_obj, assay = "RNA", slot = "counts")
counts_mat <- LayerData(sc_obj, assay = "RNA", layer = "counts")

# 2. 计算每个基因的均值 (Mean)
gene_means <- rowMeans(counts_mat)
# 3. 计算每个基因检测到的细胞比例 (检测率)
gene_detection_rate <- rowSums(counts_mat > 0) / ncol(counts_mat)
gene_detection_rate
# Xkr4        Gm1992       Gm19938       Gm37381           Rp1         Sox17 
# 0.0625000000  0.0008012821  0.0663060897  0.0000000000  0.0006009615  0.0691105769 

# 4. 计算每个基因的方差 (Variance)
# 注意：直接算稀疏矩阵的方差会很慢，我们通常手动使用公式 E(X^2) - (E(X))^2
gene_vars <- rowMeans(counts_mat^2) - (gene_means)^2

# 5. 将你的统计结果合并成一个直观的数据框查看
my_gene_stats <- data.frame(
  Mean = gene_means,
  Variance = gene_vars,
  Detection_Rate = gene_detection_rate
)
head(my_gene_stats[order(-my_gene_stats$Mean), ]) # 按均值从高到低排序查看


# 查看细胞/Spot 检测到的基因数量的统计信息
summary(sc_obj$nFeature_RNA)




# 5. 手动加载并添加空间图像信息
# Read10X_Image 专门处理 spatial 文件夹
message("正在加载空间图像...")
image <- Read10X_Image(image.dir = spatial_path)
DefaultAssay(image) <- "RNA" # 确保图像与 RNA 层关联
brain[["Slice1"]] <- image

# 6. 验证对象
print(brain)
# An object of class Seurat 
# 32285 features across 4992 samples within 1 assay 
# Active assay: RNA (32285 features, 0 variable features)
# 1 layer present: counts
# 1 spatial field of view present: Slice1
# 7. 运行后续分析 # 大约10分钟
message("开始标准化...")
brain <- SCTransform(brain, assay = "RNA", verbose = TRUE)
brain <- RunPCA(brain, verbose = FALSE)
brain <- RunUMAP(brain, reduction = "pca", dims = 1:30)

# 8. 绘图测试
SpatialDimPlot(brain)

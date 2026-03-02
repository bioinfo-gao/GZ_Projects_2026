#library(Seurat)
library(BPCells)
library(ggplot2)

# 1. 设置路径（请务必使用绝对路径）
base_path <- "/home/zhen/GZ_Projects_2026/data/visium_brain/outs"
matrix_path <- file.path(base_path, "filtered_feature_bc_matrix")
spatial_path <- file.path(base_path, "spatial")

# 2. 读取矩阵 (MTX 格式文件夹)
# 注意：Read10X 专门处理包含三个 .gz 文件的文件夹
message("正在读取矩阵...")
counts <- Read10X(data.dir = matrix_path)

# 3. 核心内存优化：立即将矩阵写入磁盘
# 这一步将 9.7G 内存压力转移到硬盘，防止 R 崩溃
message("正在转换为 BPCells 磁盘存储...")
counts_bp <- write_matrix_dir(mat = counts, dir = "brain_counts_bp")
rm(counts); gc() # 立即清理内存中的原始矩阵

# 4. 创建 Seurat 对象
brain <- CreateSeuratObject(counts = counts_bp, assay = "RNA")

# 5. 手动加载并添加空间图像信息
# Read10X_Image 专门处理 spatial 文件夹
message("正在加载空间图像...")
image <- Read10X_Image(image.dir = spatial_path)
DefaultAssay(image) <- "RNA" # 确保图像与 RNA 层关联
brain[["Slice1"]] <- image

# 6. 验证对象
print(brain)

# 7. 运行后续分析
message("开始标准化...")
brain <- SCTransform(brain, assay = "RNA", verbose = TRUE)
brain <- RunPCA(brain, verbose = FALSE)
brain <- RunUMAP(brain, reduction = "pca", dims = 1:30)

# 8. 绘图测试
SpatialDimPlot(brain)
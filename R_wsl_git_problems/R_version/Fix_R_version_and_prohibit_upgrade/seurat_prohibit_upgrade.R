# # 在生信环境管理中，防止 Mamba 自动升级 R 版本是维持环境稳定的最高优先级任务。

# 为了确保在安装 tidyverse 和 janitor 时 R 版本绝不动摇，您必须使用**“强制版本锁死”**安装指令。
# mamba install r-tidyverse r-janitor r-base=4.3.3 -c conda-forge --strict-channel-priority -y

# 2. 为什么这样写能保证 R 不变？
# r-base=4.3.2：这是向 Mamba 下达的“死命令”。它告诉解算器（Solver）：“你寻找的任何依赖方案，都必须建立在 R 4.3.2 的基础之上。如果为了装 tidyverse 必须升级 R，那就报错，不准执行。”
# --strict-channel-priority：强制只从 conda-forge 获取二进制包。这能防止 Mamba 跑到别的频道去抓一个“看起来更先进”但会破坏版本的 R 包。

# install.packages("tidyverse", dependencies = TRUE)
# install.packages("janitor", dependencies = TRUE)
# install.packages("SeuratData")
# # if (!require("BiocManager", quietly = TRUE))
# #     install.packages("BiocManager")
# BiocManager::install("SeuratData")
# remotes::install_github("satijalab/seurat-data") # 直接从 GitHub 安装最新版本的 SeuratData 包, This works !!
# 启动 R 后的操作

# R has been updated to 4.5.2, some library has to be reinstall
options(
  repos = c(
    satijalab = "https://satijalab.r-universe.dev",
    CRAN = "https://cloud.r-project.org"
  )
)
remotes::install_github("satijalab/seurat-data", quiet = TRUE)

library(Seurat)
library(dplyr)

# 🛠️ 解决方案：跳过自动转换或手动转换
# 既然 LoadData 报错，我们换一种“温柔”一点的方式来加载数据。
# 方法 A：设置更新选项（最快）
# 在加载之前，告诉 Seurat 不要强制升级旧对象：

# 1. 禁用自动升级（针对当前会话）
options(Seurat.object.assay.version = "v3")

library(SeuratData)
# 1. 传统流程（读取原始 10X 数据） (假设你解压了 pbmc3k 数据到 data/ 目录)
# pbmc.data <- Read10X(data.dir = "data/filtered_gene_bc_matrices/hg19/")
# pbmc <- CreateSeuratObject(counts = pbmc.data, project = "pbmc3k", min.cells = 3, min.features = 200)
# 这里得到的是：

# 🔹 只包含原始 counts
# 🔹 没有做标准化
# 🔹 没有 PCA
# 🔹 没有聚类
# 🔹 是一个“干净的初始对象”

#getwd()
# InstallData("pbmc3k")
pbmc <- LoadData("pbmc3k")
pbmc


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
# 或者V5官方推荐： GetAssayData(pbmc, layer = "counts")
pbmc <- CreateSeuratObject(
  # counts = pbmc@assays$RNA@counts, ＃V4
  counts = pbmc@assays$RNA$counts, #V5
  project = "pbmc3k",
  min.cells = 3,
  min.features = 200
)

# 2. 质控 (QC) - 对应 sc.pp.calculate_qc_metrics
pbmc[["percent.mt"]] <- PercentageFeatureSet(pbmc, pattern = "^MT-")

# 3. 过滤 - 对应 adata = adata[... , :]
pbmc <- subset(
  pbmc,
  subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5
)

# 4. 归一化 - 对应 sc.pp.normalize_total 和 sc.pp.log1p
pbmc <- NormalizeData(
  pbmc,
  normalization.method = "LogNormalize",
  scale.factor = 10000
)

# 5. 寻找高变基因 - 对应 sc.pp.highly_variable_genes
pbmc <- FindVariableFeatures(pbmc, selection.method = "vst", nfeatures = 2000)
# PC_ 1
# Positive:  CST3, TYROBP, LST1, AIF1, FTL, FTH1, LYZ, FCN1, S100A9, TYMP
#            FCER1G, CFD, LGALS1, S100A8, CTSS, LGALS2, SERPINA1, IFITM3, SPI1, CFP
#            PSAP, IFI30, SAT1, COTL1, S100A11, NPC2, GRN, LGALS3, GSTP1, PYCARD
# Negative:  MALAT1, LTB, IL32, IL7R, CD2, B2M, ACAP1, CD27, STK17A, CTSW
#            CD247, GIMAP5, AQP3, CCL5, SELL, TRAF3IP3, GZMA, MAL, CST7, ITM2A
#            MYC, GIMAP7, HOPX, BEX2, LDLRAP1, GZMK, ETS1, ZAP70, TNFAIP8, RIC3
# PC_ 2
# Positive:  CD79A, MS4A1, TCL1A, HLA-DQA1, HLA-DQB1, HLA-DRA, LINC00926, CD79B, HLA-DRB1, CD74
#            HLA-DMA, HLA-DPB1, HLA-DQA2, CD37, HLA-DRB5, HLA-DMB, HLA-DPA1, FCRLA, HVCN1, LTB
#            BLNK, P2RX5, IGLL5, IRF8, SWAP70, ARHGAP24, FCGR2B, SMIM14, PPP1R14A, C16orf74
# Negative:  NKG7, PRF1, CST7, GZMB, GZMA, FGFBP2, CTSW, GNLY, B2M, SPON2
#            CCL4, GZMH, FCGR3A, CCL5, CD247, XCL2, CLIC3, AKR1C3, SRGN, HOPX
#            TTC38, APMAP, CTSC, S100A4, IGFBP7, ANXA1, ID2, IL32, XCL1, RHOC
# PC_ 3
# Positive:  HLA-DQA1, CD79A, CD79B, HLA-DQB1, HLA-DPB1, HLA-DPA1, CD74, MS4A1, HLA-DRB1, HLA-DRA
#            HLA-DRB5, HLA-DQA2, TCL1A, LINC00926, HLA-DMB, HLA-DMA, CD37, HVCN1, FCRLA, IRF8
#            PLAC8, BLNK, MALAT1, SMIM14, PLD4, P2RX5, IGLL5, LAT2, SWAP70, FCGR2B
# Negative:  PPBP, PF4, SDPR, SPARC, GNG11, NRGN, GP9, RGS18, TUBB1, CLU
#            HIST1H2AC, AP001189.4, ITGA2B, CD9, TMEM40, PTCRA, CA2, ACRBP, MMD, TREML1
#            NGFRAP1, F13A1, SEPT5, RUFY1, TSC22D1, MPP1, CMTM5, RP11-367G6.3, MYL9, GP1BA
# PC_ 4
# Positive:  HLA-DQA1, CD79B, CD79A, MS4A1, HLA-DQB1, CD74, HIST1H2AC, HLA-DPB1, PF4, SDPR
#            TCL1A, HLA-DRB1, HLA-DPA1, HLA-DQA2, PPBP, HLA-DRA, LINC00926, GNG11, SPARC, HLA-DRB5
#            GP9, AP001189.4, CA2, PTCRA, CD9, NRGN, RGS18, CLU, TUBB1, GZMB
# Negative:  VIM, IL7R, S100A6, IL32, S100A8, S100A4, GIMAP7, S100A10, S100A9, MAL
#            AQP3, CD2, CD14, FYB, LGALS2, GIMAP4, ANXA1, CD27, FCN1, RBP7
#            LYZ, S100A11, GIMAP5, MS4A6A, S100A12, FOLR3, TRABD2A, AIF1, IL8, IFI6
# PC_ 5
# Positive:  GZMB, NKG7, S100A8, FGFBP2, GNLY, CCL4, CST7, PRF1, GZMA, SPON2
#            GZMH, S100A9, LGALS2, CCL3, CTSW, XCL2, CD14, CLIC3, S100A12, RBP7
#            CCL5, MS4A6A, GSTP1, FOLR3, IGFBP7, TYROBP, TTC38, AKR1C3, XCL1, HOPX
# Negative:  LTB, IL7R, CKB, VIM, MS4A7, AQP3, CYTIP, RP11-290F20.3, SIGLEC10, HMOX1
#            LILRB2, PTGES3, MAL, CD27, HN1, CD2, GDI2, CORO1B, ANXA5, TUBA1B
#            FAM110A, ATP1A1, TRADD, PPA1, CCDC109B, ABRACL, CTD-2006K23.1, WARS, VMO1, FYB

pbmc


# 6. 标准化（缩放）- 对应 sc.pp.scale
pbmc <- ScaleData(pbmc, features = rownames(pbmc))

# 7. 降维 (PCA) - 对应 sc.tl.pca
pbmc <- RunPCA(pbmc, features = VariableFeatures(object = pbmc))

Reductions(pbmc)

# 8. 聚类 (Leiden/Louvain) - 对应 sc.tl.leiden
pbmc <- FindNeighbors(pbmc, dims = 1:10)
pbmc <- FindClusters(pbmc, resolution = 0.5)

# # 9. UMAP 可视化 - 对应 sc.tl.umap 和 sc.pl.umap
# pbmc <- RunUMAP(pbmc, dims = 1:10)
# DimPlot(pbmc, reduction = "umap", label = TRUE)
# FeaturePlot(pbmc, features = c("CST3", "NKG7"))

# 只有运行了这些步骤，才能画 UMAP
pbmc <- NormalizeData(pbmc)
pbmc <- FindVariableFeatures(pbmc)
pbmc <- ScaleData(pbmc)
pbmc <- RunPCA(pbmc)
# PC_ 1
# Positive:  CST3, TYROBP, LST1, AIF1, FTL, FTH1, LYZ, FCN1, S100A9, TYMP
# FCER1G, CFD, LGALS1, S100A8, CTSS, LGALS2, SERPINA1, IFITM3, SPI1, CFP
# PSAP, IFI30, SAT1, COTL1, S100A11, NPC2, GRN, LGALS3, GSTP1, PYCARD
# Negative:  MALAT1, LTB, IL32, IL7R, CD2, B2M, ACAP1, CD27, STK17A, CTSW
# CD247, GIMAP5, AQP3, CCL5, SELL, TRAF3IP3, GZMA, MAL, CST7, ITM2A
# MYC, GIMAP7, HOPX, BEX2, LDLRAP1, GZMK, ETS1, ZAP70, TNFAIP8, RIC3
pbmc <- RunUMAP(pbmc, dims = 1:10) # 假设用前10个主成分

# 现在再尝试绘图
#DimPlot(pbmc, reduction = "umap")

library(ggplot2)

# 1. 检查是否存在 UMAP 坐标
if ("umap" %in% names(pbmc@reductions)) {
  # 提取 UMAP 坐标
  umap_coords <- as.data.frame(Embeddings(pbmc, reduction = "umap"))
  # 提取聚类信息 (Idents)
  umap_coords$Cluster <- Idents(pbmc)

  # 2. 使用原生 ggplot2 绘图
  p <- ggplot(umap_coords, aes(x = umap_1, y = umap_2, color = Cluster)) +
    geom_point(size = 0.5, alpha = 0.8) +
    theme_bw() +
    labs(title = "Manual UMAP Plot", x = "UMAP 1", y = "UMAP 2") +
    theme(panel.grid = element_blank())

  # 3. 显示图形 (如果你在 VS Code 里)
  print(p)

  # 4. 同时保存一份到服务器目录，防止 VS Code 绘图窗弹出失败
  ggsave("manual_umap_plot.png", plot = p, width = 8, height = 6)
  print("Plot saved to manual_umap_plot.png")
} else {
  stop("错误：对象中不存在 umap 降维结果，请先运行 RunUMAP(pbmc, dims = 1:10)")
}

# 10. 保存结果
library(ggplot2)


# 提取 UMAP 坐标和聚类标签
plot_data <- Embeddings(pbmc, reduction = "umap") %>%
  as.data.frame() %>%
  mutate(Cluster = Idents(pbmc))

# 原生绘图
p_manual <- ggplot(plot_data, aes(x = umap_1, y = umap_2, color = Cluster)) +
  geom_point(size = 0.6, alpha = 0.8) +
  theme_classic() +
  scale_color_brewer(palette = "Set3") +
  labs(
    title = "Manual UMAP Plot (Bypassing DimPlot Error)",
    x = "UMAP 1",
    y = "UMAP 2"
  )

# 在服务器上保存图片
ggsave("pbmc_umap_fixed.png", plot = p_manual, width = 8, height = 6)

library(Seurat)
library(ggplot2)
library(patchwork)

# 1. 彻底清除可能导致报错的元数据
pbmc@project.name <- "PBMC"

# 2. 分开获取图像，并手动移除它们内部可能携带的标题
p_cst3 <- FeaturePlot(pbmc, features = "CST3") + labs(title = "CST3")
p_nkg7 <- FeaturePlot(pbmc, features = "NKG7") + labs(title = "NKG7")

# 3. 使用最原始的拼图方式，不加任何 annotation
# 注意：这里我们不用 + plot_annotation
p2_final <- p_cst3 + p_nkg7

library(grDevices)
library(graphics)

# 再次检查 pdf 函数是否存在
exists("pdf")
# 如果返回 TRUE，说明手术成功

# 4. 保存时强制指定 plot 对象
# 如果 ggsave 依然报错，请尝试使用 pdf() 这种更底层的 R 设备
pdf("umap_features_final.pdf", width = 10, height = 5)
print(p2_final)
dev.off()

# panel_design.R
# follow ~/GZ_Projects_2026/05_Spatial_Analysis/A_Seurat_spatial.R
library(Seurat)
library(dplyr)
# 假设你已经加载了之前跑好的 scRNA-seq 对象
# saveRDS(brain, file = paste0(data_path, "/your_scRNA_data.rds"))
sc_obj <- readRDS("/home/zhen/GZ_Projects_2026/data/saved_rds/your_scRNA_data.rds")


# 1. 提取所有细胞群的特异性 Marker (Target Ranking)
markers <- FindAllMarkers(sc_obj, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.5)
markers 

# 2. 建立防拥挤与高特异性过滤框架
panel_candidates <- markers %>%
  #group_by(cluster) %>% ??
  # 过滤掉 P 值不显著的
  filter(p_val_adj < 0.01) %>%
  # 【核心防拥挤机制】：剔除表达细胞比例极高且丰度爆表的管家基因/核糖体基因
  # 这里假设表达量超过某个阈值的基因会导致 Optical Crowding
  filter(!grepl("^RP[SL]|^MT-", gene)) %>%
  # 按特异性倍数排序
  arrange(desc(avg_log2FC), .by_group = TRUE) %>%
  # 每个 cluster 只挑选最特异的 Top 20 基因，控制总体 Plex 数量
  slice_head(n = 20) %>%
  ungroup()

# 3. 提取最终的 Panel 基因列表 (例如 300 Plex)
final_panel_genes <- unique(panel_candidates$gene)
print(paste("Total genes in custom Panel:", length(final_panel_genes)))

# 导出给探针设计步骤使用
write.csv(final_panel_genes, "custom_panel_targets.csv", row.names = FALSE)
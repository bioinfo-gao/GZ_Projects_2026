| 分析步骤 | Scanpy (Python) | Seurat (R) |
| :--- | :--- | :--- |
| **数据容器** | `AnnData` (adata) | `Seurat Object` (pbmc) |
| **质控变量** | `sc.pp.calculate_qc_metrics` | `PercentageFeatureSet` |
| **高变基因** | `sc.pp.highly_variable_genes` | `FindVariableFeatures` |
| **数据缩放** | `sc.pp.scale` | `ScaleData` |
| **邻居搜索** | `sc.pp.neighbors` | `FindNeighbors` |
| **聚类算法** | `sc.tl.leiden` | `FindClusters` |
| **热点图** | `sc.pl.umap` | `FeaturePlot` |
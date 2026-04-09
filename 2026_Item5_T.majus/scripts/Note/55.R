# ================= 3. 客户友好型注释表生成 (替代 GTF 解析) =================
cat("\n📄 正在生成客户交付版注释表...\n")

# 从差异结果中提取核心列，并按显著性排序
client_annot <- deg_df %>%
  select(
    gene_id,
    gene_name,
    baseMean,
    log2FoldChange,
    padj,
    `sig (padj<0.05 & |log2FC|>=1)`
  ) %>%
  mutate(
    # 1. 统一基因名：若 gene_name 缺失或与 ID 相同，标注为预测基因
    gene_name = ifelse(
      is.na(gene_name) | gene_name == "" | gene_name == gene_id,
      paste0("Predicted_", gene_id),
      gene_name
    ),

    # 2. 添加参考基因组状态说明（客户必看）
    reference_status = "Draft Assembly (Braunschweig Univ.) | No mature reference genome available",

    # 3. 功能注释占位符（后续可对接 BLAST/InterProScan 结果）
    functional_annotation = "Pending (BLASTp/GO/KEGG)"
  ) %>%
  arrange(padj) # 按显著性从高到低排序，方便客户直接查看 Top 基因

# 保存为客户端可直接打开的 CSV（Excel 兼容）
write_csv(client_annot, file.path(OUT_DIR, "Client_DEG_Annotation_Table.csv"))

# 生成一份简短的交付说明文件
readme_text <- paste0(
  "# 📊 差异表达基因注释表说明\n",
  "## 数据背景\n",
  "- 物种: Tropaeolum majus (旱金莲)\n",
  "- 参考基因组: 草图预测版本 (Braunschweig 大学公开数据)\n",
  "- 注释状态: 当前为转录本预测 ID，暂无成熟功能注释\n",
  "## 字段说明\n",
  "- gene_id: 基因组组装预测 ID (TMxxxxx)\n",
  "- gene_name: 预测基因名 (若与原 ID 相同则标记为 Predicted_)\n",
  "- log2FoldChange: 处理组 vs 对照组的表达倍数变化 (对数尺度)\n",
  "- padj: FDR 校正后显著性 P 值\n",
  "- sig: 差异判定标准 (padj<0.05 & |log2FC|>=1)\n",
  "## 后续建议\n",
  "如需功能注释 (GO/KEGG/蛋白结构域)，可提供 FASTA 序列进行 BLASTp/InterProScan 比对。\n"
)
writeLines(readme_text, file.path(OUT_DIR, "README_Client_Delivery.txt"))

cat("✅ 客户交付文件已生成:\n")
cat("   📁", file.path(OUT_DIR, "Client_DEG_Annotation_Table.csv"), "\n")
cat("   📖", file.path(OUT_DIR, "README_Client_Delivery.txt"), "\n")

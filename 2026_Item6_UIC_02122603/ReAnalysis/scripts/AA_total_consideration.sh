# 方案 B：BAM 插入片段过滤法 (Post-alignment - 强烈推荐)
# 这是解决 PCA 噪音的“手术刀”方案。我们先按常规 PE150 比对，然后利用 samtools 过滤掉物理长度小于 250bp 的 Pairs。
# 步骤 1：常规比对 (STAR)
# 使用你之前的比对代码产生 BAM。
# 步骤 2：使用 Samtools 过滤插入片段长度 (>= 250)
# 在比对后的 BAM 文件中，第九列（TLEN）记录了片段长度。我们用一段简单的代码只保留 
# ∣TLEN∣≥250 的片段。

# 进入比对目录
cd ${OUT_ALIGN}

for SAMPLE in "${SAMPLES[@]}"; do
    echo "Filtering $SAMPLE for fragment size >= 250bp..."
    
    # 核心脚本：利用 samtools expr 过滤
    # abs(isize) >= 250 确保只保留插入片段大于 250 的 pair
    samtools view -h -e 'abs(isize) >= 250' ${SAMPLE}_Aligned.sortedByCoord.out.bam \
    -b -o ${SAMPLE}_filtered_250bp.bam
    
    # 重新建立索引
    samtools index ${SAMPLE}_filtered_250bp.bam
done


# 步骤 3：重新计算 Count 并做 PCA
# 使用过滤后的 BAM 重新运行 featureCounts，你会发现 WT_2 和 Mock_3 的噪音被物理隔离了。

# 为什么选择 250bp？
# 在 PE150 测序中，如果你保留 250bp 以上的片段，意味着 R1 和 R2 的重叠区域最多只有 50bp (
# 150+150−250=50)。这可以有效避开因降解导致的“读穿接头”核心区域，PCA 应该会显著好转。
# 数据量警告（Data Loss）：
# 由于 WT_2 和 Mock_3 的大部分片段都小于 250bp（从你的 RSeQC 图看，峰值在 150bp 左右），执行此过滤后，这两个样本的 Reads 可能会损失 80%-90%。
# 后果：即使样本在 PCA 上聚类了，但因为 Reads 太少，后续差异分析（DEGs）的 P-value 会很难看。
# 补救：在 DESeq2 中，一定要使用 minReplicatesForReplace=Inf 来防止异常值替换。
# 最终诊断提示：
# 观察 YF123（Mock3）和 YF128（WT2）提取出来的短片段。
# 如果多为线粒体基因（MT-）：说明细胞在处理过程中发生了严重的应激或坏死。
# 如果多为内含子序列（Introns）：说明发生了 DNA 污染。
# 如果多为基因 3' 端截断：说明发生了从 5' 端开始的 RNA 降解。
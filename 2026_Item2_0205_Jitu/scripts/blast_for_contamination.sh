cd /Work_bio/dropbox/Dropbox_Data/Quote_02052601_lnc/Raw/C1_A
# 提取前 20 条 reads 并显示序列
zcat C1_A_CKDL260002520-1A_23757VLT4_L4_1.fq.gz | head -n 80 | awk 'NR%4==2' # the normal 1.2G file
zcat C1_A_CKDL260002520-1A_2372W3LT4_L5_1.fq.gz | head -n 80 | awk 'NR%4==2' # the small 50M file 

# 复制其中 3-5 条序列。
# 打开 NCBI BLAST Nucleotide。
# 粘贴序列，点击 BLAST。
# 看结果（Descriptions 模块）：

“初步诊断显示，样本 ch_2B 的 Mapping 率低（10%）并非物种选择错误，而是因为严重的 rRNA 残留。
BLAST 结果证实序列主要为人类 28S 核糖体 RNA。
样本 GC 含量高达 62%，远超正常转录组范围（~45%），符合 rR的NA 污染特征。 (60% 以上的 GC 含量，是 rRNA 污染的教科书级特征。)
人类 rRNA 的 GC 含量通常在 55%-65% 之间），进一步支持这些序列来源于 rRNA。

预计该样本有效数据量仅占总测序量的 10% 左右。
结论：rRNA 减除实验失败，建议反馈给实验室端，并评估该样本的数据量是否满足后续分析要求（可能需要重测或补测）。”
cd /home/gao/projects/2026_Item5_T.majus/working_split/WhS4_1
zcat WhS4_1_CKDL260004732-1A_235Y7KLT3_L7_1.fq.gz | head -n 400000 | sed -n '2~4p' | cut -c 21-50 | sort | uniq -c | sort -rn | head -n 10

#    1353 CGTGCCCAGCAAGCCCGAGCCAGTTTTAGA
#    1189 CGAAGAGAAAGTTCCTGTCGCGGTTTTAGA
#     919 CGCGACGATGACTCCTCCTCGGGTTTTAGA
#     223 CGAGTATCGTGAATAACGACTAGTTTTAGA
#     149 CGTCACTCGGAACCACTGCTCTGTTTTAGA
#     144 CGGATATCGGGTCAGAGAGCCAGTTTTAGA
#     141 CGCTTGCCAGAATCACCTCCTGGTTTTAGA
#     100 CGGTACTGTACATACTAGATCCGTTTTAGA
#      97 CGTCTGGGTGTCCTTGGAGCTAGTTTTAGA
#      96 CGTACCTACTTAGACCCTGCCCGTTTTAGA

# 结论：
# 支架序列（Scaffold）的起点： 所有的序列都在末尾对齐到了 GTTTTAGA。
# sgRNA 的长度： 在这批数据中，sgRNA（变化的序列）大约是 23-24bp。
# 固定部分： GTTTTAGA 是标准 Cas9 支架序列（Scaffold）的起始部分（完整序列通常是 GTTTTAGAGCTAGAAATAGCAAGTTAAAATAAGG...）。
# 为什么你的统计结果里前面不一样？ 因为你的 cut -c 21-50 刚好切到了 sgRNA 的尾巴 + 支架的头。前 20 多个碱基是随 sgRNA 变化的，所以它们每个看起来都不一样，导致你的 uniq -c 计数只有 1000 多。
# 2. 获取真正的“拆分键”
# 为了让拆分 100% 准确，我们需要提取 GTTTTAGA 之后的序列。请运行下面这个改进的命令：
# 我们往后多切一点，看 25 到 60 位
zcat WhS4_1_CKDL260004732-1A_235Y7KLT3_L7_1.fq.gz | head -n 400000 | sed -n '2~4p' | cut -c 25-60 | sort | uniq -c | sort -rn | head -n 5
#    1364 CCCAGCAAGCCCGAGCCAGTTTTAGAGCTAGAAATA
#    1213 GAGAAAGTTCCTGTCGCGGTTTTAGAGCTAGAAATA
#     940 ACGATGACTCCTCCTCGGGTTTTAGAGCTAGAAATA
#     231 TATCGTGAATAACGACTAGTTTTAGAGCTAGAAATA
#     150 TATCGGGTCAGAGAGCCAGTTTTAGAGCTAGAAATA

# 从你统计的结果来看，每一行都在同样的位置出现了 TTTTAGAGCTAGAAATA。这是标准的 Cas9 支架序列。
# 1. 最终确定的“拆分键”（Scaffold Key）
# 基于你的输出，最稳妥的特征序列是：
# GTTTTAGAGCTAGAAATA
# （注：我在前面加了一个 G，因为标准的支架序列起始是 GTTTTAGA...，你之前的 cut 命令可能刚好切到了它后一个碱基。）
# 2. 最终全自动拆分脚本
# 我为你编写了这个生产级别的脚本。它会遍历你提到的五个文件夹，并按照你的命名要求（Real_xxx 和 YFxxx）进行精准拆分。



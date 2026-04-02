tmux new -s rnaseq_uic
# 通过指定 --star_index，流程将跳过数小时的索引构建时间，直接开始比对。
# 运行 nf-core
nextflow run nf-core/rnaseq \
    -r 3.15.1 \
    -profile singularity \
    -resume \
    --input /home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis/scripts/Sample_Sheet_UIC.csv \
    --outdir /home/gao/projects/2026_Item6_UIC_02122603/output_nf_core \
    --fasta /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/GRCh38.primary_assembly.genome.fa \
    --gtf /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/gencode.v45.annotation.gtf \
    --star_index /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/star_index \
    --gencode \
    --aligner star_salmon \
    --remove_ribo_rna \
    --save_non_ribo_reads \
    --max_cpus 32 \
    --max_memory '80.GB'

# Ctrl + b， then  d
# tmux a

# 2. 当初可以加快速度的 4 个方案

# 方案 A：判断是否真的需要这一步（最有效的加速是“不跑”）
# 专家判断：查看你的建库方式。
# 如果是 PolyA 捕获（mRNA-seq）：通常不需要跑 --remove_ribo_rna。因为磁珠捕获 PolyA 尾巴的过程已经去除了 99% 的 rRNA。
# 如果是 核糖体去除（Ribo-zero / Total RNA-seq）：才需要跑这步来清理残留。
# 结论：如果你的实验是标准的 mRNA-seq，去掉这个参数，流程能在 1-2 小时内跑完。

# 方案 B：限制并行样本数，增加单样本 CPU（Local 优化）
# 与其让 12 个样本慢速爬行，不如让 3 个样本全速冲刺。你可以通过设置 fork 来优化：
# 在运行命令中加入以下参数（虽然 nf-core 不直接暴露，但可以通过 config 注入）
# 或者通过限制 max_cpus 强制让样本排队

# # 在运行命令中加入以下参数（虽然 nf-core 不直接暴露，但可以通过 config 注入）
# # 或者通过限制 max_cpus 强制让样本排队
# 建议做法：手动指定每个进程的 CPU。如果给每个 SortMeRNA 任务分配 8 个 CPU，一次跑 4 个样本，总时间通常比 12 个样本同时分 32 个 CPU 快得多。

# 方案 C：指定特定的 rRNA 数据库（减少计算量）
# nf-core 默认会比对 5-8 个 数据库（包括细菌、古菌、真核等）。
# 加速方法：由于你的样本是 Human，你原本可以自定义一个只包含人类 rRNA 的 fasta 文件，并使用 --sortmerna_index 指向它。这样比对范围缩小了 80%，速度会提升数倍。

# 方案 D：调低采样比例
# 你可以通过参数设置只对部分数据进行核糖体评估，但在 nf-core 中，为了物理剔除，它必须跑全量数据，所以这招效果有限。

# 专家级操作建议：
# 既然你的样品是 PolyA 制备，SortMeRNA 确实是完全多余的。我建议你采取以下“手术式”的操作逻辑：
# 1. 停止当前运行 (CTRL+C)
# 由于 SortMeRNA 至少还要跑 4-6 小时，而这步对你的实验并没有科学贡献。果断停止它。
# 2. 修改并重启流程 (跳过 rRNA 去除)
# 由于你已经有了 STAR Index，跳过 SortMeRNA 后，流程会变得极其精简。2 小时内完成是完全现实的。
# 请使用以下优化后的命令（去掉了 remove_ribo_rna）：


# 建议先运行这个清理命令，确保没有残留的僵尸进程占用内存 #pkill -u gao -f nextflow  #(慎用，确保只杀掉你自己的任务)

#tmux new -s rnaseq_uic
tmux a

cd /home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis/scripts
nextflow run nf-core/rnaseq -c local_optimized.config \
    -r 3.15.1 \
    -profile singularity \
    --input /home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis/scripts/Sample_Sheet_UIC.csv \
    --outdir /home/gao/projects/2026_Item6_UIC_02122603/output_nf_fast \
    --fasta /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/GRCh38.primary_assembly.genome.fa \
    --gtf /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/gencode.v45.annotation.gtf \
    --star_index /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/star_index \
    --gencode \
    --aligner star_salmon \
    --max_cpus 32 \
    --max_memory '85.GB' \
    -resume 

# 使用 resume 会跳过已经做完的 FastQC 和 TrimGalore

# The specified configuration file does not exist: /home/gao/local_optimized.config
# 为什么这个版本会快得多？
# 跳过 SortMeRNA：直接节省了 4-6 小时的比对时间。
# 利用 Resume：因为你之前的任务已经完成了 FastQC 和 TrimGalore（100% 完成），Nextflow 的缓存机制会瞬间跳过这些步骤，直接进入 STAR_ALIGN。
# 预生成的 Index：STAR 会直接加载索引进行比对，每个样本通常只需 15-20 分钟。
# 内存管理：将 --max_memory 设为 85.GB，给系统留一点余地。
# 预估时间表（重启后）：
# 快照/缓存识别：5 分钟（Nextflow 检查之前做完的步骤）。
# STAR 比对 (12 样本串行/小规模并行)：约 1 - 1.5 小时。
# 定量与 MultiQC：20 分钟。
# 总计：约 1.5 - 2 小时。
# 专家提醒：
# 由于 96GB 内存跑人类 STAR 依然比较紧（特别是并行跑的时候），如果报错内存不足，你可以添加 --aligner_star_bins 1 或者限制并行度。但按照 12 个样本的规模，-resume 后你应该很快就能看到 STAR_ALIGN 的进度条在跳动。
# 现在就 CTRL+C 停掉旧的，运行新的命令吧！这是最高效率的做法。    
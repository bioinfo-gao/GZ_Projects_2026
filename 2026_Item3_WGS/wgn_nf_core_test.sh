# WGS 标准分析流程详解
# Sarek 默认执行以下步骤 ：

# 准备参考基因组：BWA 索引、FASTA 索引、GATK 字典
# 质控：FastQC 原始数据质量报告
# 比对：BWA MEM 将 FASTQ 比对到参考基因组
# 标记重复：GATK MarkDuplicates
# 碱基质量重校准：GATK BaseRecalibrator + ApplyBQSR
# 比对质量评估：samtools stats + mosdepth 深度统计
# 变异检测（默认 Strelka，可配置 DeepVariant、GATK HaplotypeCaller、Mutect2 等）
# 结果汇总：MultiQC 生成统一报告


# Sarek 是 DNA WGS 流程，使用 BWA/BWA-MEM2 进行比对，不使用 STAR（STAR 是 RNA-seq 剪接比对工具）。
# 如果您要进行 WGS 分析，需要 BWA-MEM 或 BWA-MEM2 索引，而不是 STAR。

# Method1: use sigularity,  docker, or conda 
# Here we use sigularity to run the pipeline, not docker
nextflow run nf-core/sarek \
   -r 3.8.1 \
   -profile sigularity \
   --input samplesheet.csv \
   --outdir ./results \
   --genome GATK.GRCh38 \
   --tools strelka,deepvariant,haplotypecaller \
   --max_cpus 16 \
   --max_memory 80.GB



# Method2: use params.yaml as following:

# input: './samplesheet.csv'
# outdir: './results/'
# genome: 'GATK.GRCh38'
# tools:
#   - 'strelka'
#   - 'deepvariant'
# max_cpus: 16
# max_memory: '64.GB'

# nextflow run nf-core/sarek -r 3.8.1 -profile docker -params-file params.yaml   

# 使用内置测试配置（最简单）
# 运行官方测试数据集,无需准备 --input 和 --genome，系统会自动使用测试配置
# test profile 会自动下载测试数据（chr22 的小片段数据）和小型参考基因组


tmux new -s wgn_nf_core_test

# 使用 Singularity/Apptainer（HPC 环境推荐）
nextflow run nf-core/sarek -r 3.8.1 -profile test,singularity --outdir ./results

# 继续之前的运行（不会重复计算已完成的步骤）
nextflow run nf-core/sarek -r 3.8.1 \
  -profile test,docker \
  --outdir ./results \
  -resume


nf-amazon 插件未安装（用于访问 AWS S3 存储的注释缓存），以及测试数据 URL 路径问题。以下是解决方案：
# 安装 nf-amazon 插件（如需使用 S3）
# bash
# 复制
# # 安装插件
# nextflow plugin install nf-amazon

# # 然后再运行
# nextflow run nf-core/sarek -r 3.8.1 -profile test,docker --outdir ./results

方法 1：自动下载缓存到本地（推荐）， 但网络不佳不 optimal 
添加 --download_cache 参数，让流程自动下载 S3 缓存到本地： 
# 运行结果保存在 ./test_full_results/work/ 下
# cash 文件保存在 ./test_full_results/work/cache/ 下, 下次运行时会自动使用本地缓存，避免重复下载
#singularity pull --name sarek.img docker://nfcore/sarek:3.8.1

rm -rf results work

nextflow run nf-core/sarek -r 3.8.1 \
  -profile test,singularity \
  --outdir ./results \
  --download_cache \
  --max_cpus 4 \
  --max_memory 8.GB

方法 2： Singularity + 离线环境解决方案
# 使用 test_cache profile（跳过 S3 依赖）
# 使用 test_cache 替代 test，它使用本地缓存路径：
rm -rf results work
nextflow run nf-core/sarek -r 3.8.1 \
  -profile test_cache,singularity \
  --outdir ./results \
  --max_cpus 4 \
  --max_memory 8.GB

tmux attach -t wgn_nf_core_test

tmux kill-session -t wgn_nf_core_test

方法 3： Singularity + 跳过 S3 依赖

rm -rf results work

nextflow run nf-core/sarek -r 3.8.1 \
  -profile test,singularity \
  --outdir ./results \
  --tools strelka \
  --skip_tools bcftools,vcftools \
  --max_cpus 4 \
  --max_memory 8.GB

#   关键参数说明：
# --tools strelka：只运行 Strelka 变异检测（不依赖 S3）
# --skip_tools snpeff,vep：跳过注释步骤（避免 S3 缓存依赖）
# -profile test,singularity：使用标准测试数据 + Singularity

export APPTAINER_CACHEDIR=/Work_bio/singularity_cache
export NXF_SINGULARITY_PULL_TIMEOUT=30m
mkdir -p $APPTAINER_CACHEDIR

rm -rf results work
nextflow run nf-core/sarek -r 3.8.1 -profile test,singularity --outdir ./results --tools strelka

# mosdepth 镜像下载失败
# 快速测试流程是否工作，使用 方法 1（跳过 mosdepth）：
rm -rf results work
export APPTAINER_CACHEDIR=/Work_bio/singularity_cache
nextflow run nf-core/sarek -r 3.8.1 -profile test,singularity --outdir ./results --tools strelka --skip_tools mosdepth


# 网络环境不稳定，强烈建议：
今晚：使用 方案 2 (conda) 快速验证流程逻辑是否正确
明天：在好网络环境下用 方案 1 下载完整镜像集，用于正式分析

# 最快验证命令（conda 模式）
# 激活环境
mamba activate regular_bioinfo

# 安装核心软件（sarek 必需）
mamba install -c bioconda -c conda-forge \
  bwa-mem2 \
  samtools=1.21 \
  gatk4=4.5 \
  strelka=2.9.10 \
  python=3.10 \
  pandas \
  numpy

# 可选 QC 工具（建议安装，如果报错再装）
mamba install -c bioconda \
  fastqc \
  mosdepth \
  multiqc \
  bcftools \
  vcftools \
  tabix \
  gawk

rm -rf results work
nextflow run nf-core/sarek -r 3.8.1 \
  -profile conda \
  --input your_samplesheet.csv \
  --fasta /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/GRCh38.primary_assembly.genome.fa \
  --fai /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/GRCh38.primary_assembly.genome.fa.fai \
  --dict /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/GRCh38.primary_assembly.genome.dict \
  --bwa /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/ \
  --aligner bwa-mem2 \
  --tools strelka \
  --outdir ./results


# 运行结果
# 运行结果保存在 ./test_results/work/ 下

# 真实规模的数据集，可使用完整测试：

# 30x WGS Germline 测试（NA12878）
nextflow run nf-core/sarek -r 3.8.1 \
  -profile test_full_germline,singularity \
  --outdir ./test_full_results

# # 肿瘤-正常配对测试（SEQ2C 数据集）
# nextflow run nf-core/sarek -r 3.8.1 \
#   -profile test_full,singularity \
#   --outdir ./test_somatic_results

mamba install -c bioconda -c conda-forge \
  bwa-mem2 \
  samtools=1.21 \
  gatk4=4.5 \
  python=3.10 \
  pandas \
  numpy \
  fastqc \
  multiqc \
  mosdepth

# mamba activate tools
# 然后运行 sarek 不选 strelka，改用 GATK haplotypecaller：

# 运行前检查清单
# 创建文件后，确认：
# 1. 检查文件存在
cat local_exec.config

mamba activate regular_bioinfo
# 2. 确认软件在 PATH 中（当前环境）
which bwa-mem2 samtools gatk
# /Work_bio/gao/configs/.conda/envs/regular_bioinfo/bin/bwa-mem2
# /Work_bio/gao/configs/.conda/envs/regular_bioinfo/bin/samtools
# /Work_bio/gao/configs/.conda/envs/regular_bioinfo/bin/gatk

# 3. 确认参考文件存在
ls /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/GRCh38.primary_assembly.genome.fa
ls /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/*.bwt.2bit.64  # bwa-mem2 索引


# 最终运行命令
nextflow run nf-core/sarek -r 3.8.1 \
  -c local_exec.config \
  --input samplesheet.csv \
  --outdir ./results \
  --fasta /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/GRCh38.primary_assembly.genome.fa \
  --fai /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/GRCh38.primary_assembly.genome.fa.fai \
  --dict /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/GRCh38.primary_assembly.genome.dict \
  --bwa /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/ \
  --aligner bwa-mem2 \
  --tools haplotypecaller \
  --skip_tools fastqc,mosdepth,multiqc \
  --max_cpus 4
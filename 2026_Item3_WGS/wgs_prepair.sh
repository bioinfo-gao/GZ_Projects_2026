# 如果还没有 mamba，先安装 miniforge
# wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
# bash Miniforge3-Linux-x86_64.sh

# 1) 创建环境并安装
mamba activate regular_bioinfo
mamba install -c bioconda bwa-mem2 samtools gatk4
# 验证安装
bwa-mem2 version
# Looking to launch executable "/Work_bio/gao/configs/.conda/envs/regular_bioinfo/bin/bwa-mem2.avx2", simd = .avx2
# Launching executable "/Work_bio/gao/configs/.conda/envs/regular_bioinfo/bin/bwa-mem2.avx2"
# 2.2.1

# 2) 下载 GATK hg38 参考文件

mkdir -p /Work_bio/references/Homo_sapiens/GRCh38/gatk_bundle
cd /Work_bio/references/Homo_sapiens/GRCh38/gatk_bundle

# 下载 dbsnp（版本 138 或 146）
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/dbsnp_146.hg38.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/dbsnp_146.hg38.vcf.gz.tbi

# 下载 Mills indels
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi

# 3) 构建 bwa-mem2 索引
cd /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/

# 检查是否已有索引
ls GRCh38.primary_assembly.genome.fa.* 2>/dev/null | head -5

# 如果没有，构建索引（需要 ~30GB 内存，生成 ~10GB 索引文件） 2h
bwa-mem2 index GRCh38.primary_assembly.genome.fa

# samtools faidx 和 bwa-mem2 index 是完全不同的两种索引，用途不同：
# 表格
# 索引类型	命令	输出文件	用途
# FASTA 索引	samtools faidx	.fai	快速定位 FASTA 序列位置（如提取 chr1:1000-2000）
# 比对索引	bwa-mem2 index	.bwt.2bit.64, .ann, .amb, .pac	短序列比对（将 reads 比对

# 生成文件应包括：
# GRCh38.primary_assembly.genome.fa.bwt.2bit.64
# GRCh38.primary_assembly.genome.fa.ann
# GRCh38.primary_assembly.genome.fa.amb 等

# 4) 构建 GATK 字典
# GATK 字典（.dict） 是 GATK 工具链要求的特殊文件，包含参考基因组的序列元数据（染色体名称、长度、MD5 校验等）。
# GATK 专用，验证 BAM 文件染色体顺序、长度是否匹配参考基因组
# GATK 必须同时有 .fai 和 .dict，否则会报错：
# 使用 GATK4（推荐，您已安装）

cd /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/

gatk CreateSequenceDictionary \
  -R GRCh38.primary_assembly.genome.fa \
  -O GRCh38.primary_assembly.genome.dict

# 生成后检查：
ls -lh GRCh38.primary_assembly.genome.dict

# 内容应该是纯文本，包含 @HD 和 @SQ 行
head GRCh38.primary_assembly.genome.dict

# 示例输出：
# @HD	VN:1.6
# @SQ	SN:chr1	LN:248956422	M5:6aef897c3d6ff0c78aff06ac189178dd	UR:file:/path/to/GRCh38.primary_assembly.genome.fa
# @SQ	SN:chr2	LN:242193529	M5:f98db672eb0993dcfdabafe2a882905c	UR:file:/path/to/GRCh38.primary_assembly.genome.fa
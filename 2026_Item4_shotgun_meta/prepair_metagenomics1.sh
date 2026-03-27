# 
# nf-core/mag is a bioinformatics best-practise analysis pipeline for assembly, binning and annotation of metagenomes.

# Pipeline summary
# By default, the pipeline currently performs the following: it supports both short and long reads, quality trims the reads and adapters with fastp and Porechop, and performs basic QC with FastQC, and merge multiple sequencing runs.

# The pipeline then:

# assigns taxonomy to reads using Centrifuge and/or Kraken2
# performs assembly using MEGAHIT and SPAdes, and checks their quality using Quast
# (optionally) performs ancient DNA assembly validation using PyDamage and contig consensus sequence recalling with Freebayes and BCFtools
# predicts protein-coding genes for the assemblies using Prodigal, and bins with Prokka and optionally MetaEuk
# performs metagenome binning using MetaBAT2, MaxBin2, and/or with CONCOCT, and checks the quality of the genome bins using Busco, or CheckM, and optionally GUNC.
# Performs ancient DNA validation and repair with pyDamage and freebayes
# optionally refines bins with DAS Tool
# assigns taxonomy to bins using GTDB-Tk and/or CAT and optionally identifies viruses in assemblies using geNomad, or Eukaryotes with Tiara
# Furthermore, the pipeline creates various reports in the results directory specified, including a MultiQC report summarizing some of the findings and software versions.

# 方案一：全能型流程（nf-core/mag）—— 推荐
# 适用于：从原始数据到物种组成、功能注释、以及提取单菌基因组（MAGs）。

# 2. 运行命令
# 这个流程非常吃内存，建议在你的 96G 服务器上严格限制资源。

nextflow run nf-core/mag \
    -r 3.2.1 \
    -profile singularity \
    --input samples.csv \
    --outdir ./results_mag \
    --lsb_cpu 32 \
    --max_memory '80.GB' \
    --clip_tool fastp \
    --host_genome GRCh38 \
    --host_removal_save_ids \
    --busco_db_path /Work_bio/references/busco_db \
    --kraken2_db /Work_bio/references/kraken2_db \
    --skip_concoct \
    -resume

# --host_genome GRCh38: 极重要！如果是人类样本，必须比对回人类基因组并切除这些 Reads，否则结果全是人。
# --kraken2_db: 指定物种鉴定的数据库。
# --skip_concoct: Concoct 对内存要求极高，如果 96G 内存跑不动组装后的分箱，可以跳过它。


# 方案二：快速物种与功能谱（MetaPhlAn + HUMAnN）
# 如果你不关心组装成新的基因组（MAGs），只想要“样里有什么物种？这些物种在干什么（通路）？”，这是最高效的方法。
# 通常使用 bioBakery 3 工具包。
# 1. 创建环境

mamba create -n biobakery3 -c bioconda metaphlan humann -y
conda activate biobakery3

# 1. 合并双端序列 (HUMAnN 要求)
cat S1_R1.fastq.gz S1_R2.fastq.gz > S1_merged.fastq.gz

# 2. 运行 MetaPhlAn (物种鉴定)
metaphlan S1_merged.fastq.gz --input_type fastq --nproc 32 > S1_profile.txt

# 3. 运行 HUMAnN 3 (功能注释)
humann --input S1_merged.fastq.gz --output ./humann_out --threads 32 --metaphlan-stats S1_profile.txt

# 优点： 速度极快，内存占用低（30-60G 足够）。
# 缺点： 无法获得具体的 bin（单菌基因组）。

# 方案三：如果你想针对特定的数据库进行比对
# 如果你有特定的参考序列（比如几千个细菌的基因组），想看样本里这些细菌的丰度，可以使用 Kraken2 + Bracken。

# 物种分类
kraken2 --db /path/to/db --threads 32 --paired --check-names \
        --report S1.report --output S1.output \
        S1_R1.fastq.gz S1_R2.fastq.gz

# 丰度校正 (得到更准确的物种占比)
bracken -d /path/to/db -i S1.report -o S1.bracken -l S


# 运行 Shotgun 分析的避坑指南：

# 内存是死穴（OOM）：
# 组装（Assembly） 步骤（如 MEGAHIT 或 SPAdes）非常耗内存。在 96G 的服务器上，如果你跑的是几十个 G 的大样本，可能会崩溃。
# 解决： 使用 nf-core/mag 时，通过 --max_memory '80.GB' 限制，Nextflow 会在内存不足时自动重试或排队。

# 宿主污染清理（Host Removal）：
# 肠道、唾液、血液样本中含有大量人类 DNA。必须先用 Bowtie2 或 BWA 比对到人类基因组并删掉这些 Reads，再进行后续分析，否则物种分类会满地报错。

# 数据库非常巨大：
# Kraken2 的标准数据库大约 70G-100G。
# GTDB-Tk（用于 MAGs 鉴定）的数据库约 80G。
# 建议： 先确认你们实验室的公共存储（/Work_bio/references/）里是否已经有人下载好了这些库。

# 分析逻辑：
# 如果你是做差异丰度分析：用方案二（MetaPhlAn + HUMAnN）得到物种和通路矩阵，然后进 R 语言跑 Maaslin2 或 DESeq2。
# 如果你是想发现新种：必须用方案一。

# 建议你的第一步：
# 去查看 /Work_bio/references/ 下有没有 kraken2, metaphlan, humann 或者 gtdbtk 命名的文件夹。

# 如果有，直接复用它们的路径；如果没有，你需要预留 500G 以上的磁盘空间来下载这些数据库。

# 建立一个 Metagenomics 顶级目录，并按照工具名称分子目录。这样不仅整洁，也方便以后其他同事复用。
# 1. 推荐的目录结构设计
# code
# Text
# /Work_bio/references/
# ├── Homo_sapiens/       # 已有
# ├── Mus_musculus/       # 已有
# └── Metagenomics/       # 新建：宏基因组专用
#     ├── metaphlan/      # MetaPhlAn 数据库 (Marker genes)
#     └── humann/         # HUMAnN 数据库 (pangenomes & proteins)
#         ├── chocophlan/
#         └── uniref/

# create and 激活环境
# 建议先清理一下失败的尝试
conda deactivate
mamba env remove -n mag_biobakery

# 使用正确的包名和频道顺序重新创建
# 核心点：指定 python=3.9 使用“黄金组合”命令重新安装
mamba create -n mag_biobakery python=3.9 -c conda-forge -c bioconda humann metaphlan -y
# Note: humann version 3 still names as humann
conda activate mag_biobakery

# 检查 humann 库是否能被识别
python -c "import humann; print(humann.__version__)"
# 验证 MetaPhlAn (应该是 4.x 版本)
metaphlan --version
# 验证 HUMAnN (应该是 3.x 版本)
humann --version

# 依然报错 (备选方案：手动修复库连接)
pip install humann --no-deps

# 创建目录
mkdir -p /Work_bio/references/Metagenomics/metaphlan
mkdir -p /Work_bio/references/Metagenomics/humann
#  修改权限确保你可以写入（假设你的组是 lhn 或 gao）
# sudo chown -R $USER:$USER /Work_bio/references/Metagenomics/

tmux new -s db_download

# 1. 激活环境
conda activate mag_biobakery

# 2. 一键启动所有下载 (MetaPhlAn + HUMAnN Chocophlan + HUMAnN UniRef)
# 我添加了 --update-config 确保下载完自动配置好路径
# 执行修正后的命令
metaphlan --install --db_dir /Work_bio/references/Metagenomics/metaphlan --nproc 8 && \
humann_databases --download chocophlan full /Work_bio/references/Metagenomics/humann/ --update-config yes && \
humann_databases --download uniref uniref90_diamond /Work_bio/references/Metagenomics/humann/ --update-config yes
# --db_dir: 替换了报错的 --bowtie2db。它现在统一用来指定数据库文件（包括 marker 文件和 bowtie2 索引）的存放位置。
# --nproc 8: 在下载和构建索引时会用到多线程。

Detach 会话：按下 Ctrl + B 然后按 D。
tmux a # tmux attach -t db_download

# # 下载 MetaPhlAn 数据库 (约 5GB)
# metaphlan --install \
#   --bowtie2db /Work_bio/references/Metagenomics/metaphlan \
#   --nproc 8

# # 第三步：下载 HUMAnN3 数据库 (分两部分，共约 100GB+)
# # HUMAnN 需要核酸库 (Chocophlan) 和 蛋白质库 (UniRef)。建议下载 full 版本以保证分析完整性。
# # 1. 下载核酸数据库 (Chocophlan, 约 20GB):  

# humann_databases --download chocophlan full   /Work_bio/references/Metagenomics/humann/
# tmux a # tmux attach -t db_download

# 3. 核心操作：配置工具默认路径（非常重要！）
# 下载完后，你必须告诉 humann 和 metaphlan 去哪里找这些文件，否则下次运行它们还会去 envs 默认路径找。

# 配置 MetaPhlAn 默认路径
metaphlan --config_file /Work_bio/references/Metagenomics/metaphlan/metaphlan_config.txt --bowtie2db /Work_bio/references/Metagenomics/metaphlan

# 配置 HUMAnN3 默认路径
humann_config --update database_folders nucleotide /Work_bio/references/Metagenomics/humann/chocophlan
humann_config --update database_folders protein /Work_bio/references/Metagenomics/humann/uniref

# 4. 运行试验：如何调用这些自定义路径？
# 当你运行分析时，命令如下：

# 运行 MetaPhlAn
metaphlan input.fastq.gz --input_type fastq \
  --bowtie2db /Work_bio/references/Metagenomics/metaphlan \
  --nproc 32 \
  -o species_profile.txt

# 运行 HUMAnN3
humann --input input.fastq.gz \
  --output ./output \
  --nucleotide-database /Work_bio/references/Metagenomics/humann/chocophlan \
  --protein-database /Work_bio/references/Metagenomics/humann/uniref \
  --threads 32

# 专家提示：关于“宿主剔除”
# 由于你处理的可能是 Homo sapiens (人) 的样本，在跑上述命令前，请务必先用你之前找到的 /Work_bio/references/Homo_sapiens/GRCh38/ 索引过滤掉人的序列。
# 如果不做过滤，直接跑 mag_biobakery：
# metaphlan 会比较聪明，因为它只比对细菌特异性 Marker，受影响较小。
# humann 会非常慢，且会产生大量无关的 mapping 错误。
# 建议流程：
# 用 Bowtie2 对着 /Work_bio/references/Homo_sapiens/.../star_index（或 bowtie2 index）比对。
# 提取 Unmapped reads (不比对到人的 reads)。
# 将这些 Unmapped reads 输入到 metaphlan 或 humann。  
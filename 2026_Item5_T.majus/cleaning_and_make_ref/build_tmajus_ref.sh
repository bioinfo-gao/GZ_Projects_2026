#!/bin/bash

# ==============================================================================
# REFERENCE GENOME DIRECTORY STANDARD (MARKDOWN TABLE):
# | 物种     | 根路径 (/Work_bio/references/) | 基因组版本 | 注释来源/版本        | 核心文件名示例                     |
# | :------- | :--------------------------- | :--------- | :------------------ | :------------------------------- |
# | **人** | `Homo_sapiens`               | `GRCh38`   | `human_gencode_v45` | `GRCh38.primary_assembly.genome.fa` |
# | **小鼠** | `Mus_musculus`               | `GRCm39`   | `mouse_gencode_M35` | `GRCm39.primary_assembly.genome.fa` |
# | **旱金莲**| `Tropaeolum_majus`          | `T_majus_v1`| `schmidt_et_al_2024`| `T_majus.primary_assembly.genome.fa` |
# ==============================================================================

# Project: Tropaeolum majus Reference Genome Construction
# Date: 2026-03-28
# Author: Gao

# 注释文件名作用与区别...
# genomic.fasta.gz  必选    基因组全序列。包含所有染色体和 Scaffolds，是 STAR 建索引的底图。...
# genomic.gff.gz    必选    结构注释文件。记录了基因、转录本、外显子在基因组上的精确坐标。你的人类参考库用的是 GTF，这个 GFF 需要转换。
# cds.fasta.gz      可选    编码区序列。只包含从起始密码子到终止密码子的碱基，不含内含子。如果你直接用 Salmon 跑准比对（Mapping-based）才需要。
# pep.fasta.gz      不选    蛋白质序列。这是氨基酸序列，用于蛋白质组学或同源搜索（如 BLAST），RNA-seq 比对用不到。
# anno.txt.gz       不选    功能描述文件。通常是表格，记录这个基因叫什么名字、有什么功能（GO/KEGG），仅用于下游分析时的信息注释。


set -e  # 脚本中任何命令失败即退出
set -u  # 使用未定义变量即报错

# 1. 路径与环境配置
BASE_DIR="/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024"
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

# 2. 下载核心组件 (使用 curl -L 处理 Servlet 重定向)
echo "------------------------------------------------------------"
echo "Step 1: 正在使用 curl 下载旱金莲基因组与注释..."
# 基因组序列
curl -L -o T_majus.raw.fa.gz "https://leopard.tu-braunschweig.de/servlets/MCRFileNodeServlet/dbbs_derivate_00056259/Tropeaeolum_majus_v1.genomic.fasta.gz"
# GFF3 注释
curl -L -o T_majus.raw.gff.gz "https://leopard.tu-braunschweig.de/servlets/MCRFileNodeServlet/dbbs_derivate_00056259/Tropeaeolum_majus_v1.genomic.gff.gz"

# 3. MD5 完整性校验 (以官方提供的值为准，此处为示例)
echo "Step 2: 正在验证文件 MD5..."
# 假设官方 MD5 如下 (请根据网页实际值替换)
# echo "e08a688b77053e16053331b262f39281  T_majus.raw.fa.gz" > checks.md5
# md5sum -c checks.md5 || { echo "MD5 校验失败！"; exit 1; }

# 4. 解压并标准化命名 (与人类基因组格式对齐)
echo "Step 3: 正在解压并标准化命名..."
gunzip -c T_majus.raw.fa.gz > T_majus.primary_assembly.genome.fa
gunzip -c T_majus.raw.gff.gz > T_majus.annotation.gff3

# 5. GFF3 转 GTF (使用独立的 gff_tools 环境)
echo "Step 4: 正在转换注释格式 (GFF3 -> GTF)..."
# 使用 mamba run 避免激活环境的权限问题
#mamba run -n gff_tools gffread T_majus.annotation.gff3 -T -o T_majus.annotation.gtf
# 生成的 GTF 文件更规范（包含显式的 exon 行），请重新运行 gffread，但加上 -y 参数：
# mamba run -n base gffread T_majus.annotation.gff3 -T -y T_majus.annotation.gtf -o T_majus.annotation.gtf
# gffread 在执行 -y（生成外显子/CDS 序列或相关记录）等高级操作时，必须读取基因组的 FASTA 文件
mamba run -n base gffread T_majus.annotation.gff3 -g T_majus.primary_assembly.genome.fa -T -y T_majus.annotation.gtf -o T_majus.annotation.gtf
#FASTA index file T_majus.primary_assembly.genome.fa.fai created.
# 6271 字节（约 6KB） 说明你的基因组包含大约 100-200 条 序列（染色体或 Scaffolds），这对于一个现代植物基因组组装来说是非常合理的数值。
# 6. 使用 tmux 启动 STAR 索引构建 (使用 32 核)
echo "Step 5: 准备构建 STAR 索引..."
mkdir -p star_index


# mamba run -n regular_bioinfo STAR \
#     --runThreadN 32 \
#     --runMode genomeGenerate \
#     --genomeDir ./star_index \
#     --genomeFastaFiles T_majus.primary_assembly.genome.fa \
#     --sjdbGTFfile T_majus.annotation.gtf \
#     --sjdbOverhang 100


# 确保在 tmux 中运行，并使用了两个核心修正参数
# tmux new-session -d -s index_tmajus "mamba run -n regular_bioinfo STAR \
#     --runThreadN 32 \
#     --runMode genomeGenerate \
#     --genomeDir ./star_index \
#     --genomeFastaFiles T_majus.primary_assembly.genome.fa \
#     --sjdbGTFfile T_majus.annotation.gtf \
#     --sjdbOverhang 100 \
#     --sjdbGTFfeatureExon exon \
#     --genomeSAindexNbases 12"
    

mamba run -n regular_bioinfo STAR \
    --runThreadN 32 \
    --runMode genomeGenerate \
    --genomeDir ./star_index \
    --genomeFastaFiles T_majus.primary_assembly.genome.fa \
    --sjdbGTFfile T_majus.annotation.gtf \
    --sjdbOverhang 100 \
    --sjdbGTFfeatureExon CDS \
    --genomeSAindexNbases 12

echo "脚本执行完毕。"
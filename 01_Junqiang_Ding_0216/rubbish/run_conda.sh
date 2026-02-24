#!/bin/bash

# 1. 进入工作目录
PROJECT_DIR="/home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216"
cd $PROJECT_DIR || { echo "无法进入目录 $PROJECT_DIR"; exit 1; }

# 2. 清除 VS Code 干扰
unset PROMPT_COMMAND; __vsc_prompt_cmd_original() { :; }

# 3. 定义外部资源路径
PIPELINE_DIR="/home/songz/.nextflow/assets/nf-core/rnaseq_backup_20260219_055913"
MOUSE_FASTA="/home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.fasta"
MOUSE_GTF="/home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.gtf"

# 4. 运行 Nextflow (切换到 -profile conda)
# 注意：这会自动根据流程需求创建 Conda 环境
nextflow run $PIPELINE_DIR \
    -profile conda \
    --input ./samplesheet.csv \
    --outdir ./results \
    --fasta $MOUSE_FASTA \
    --gtf $MOUSE_GTF \
    -work-dir /home/songz/gaoz/work/01_Junqiang_Ding_0216 \
    --download_fastp_bin false \
    --skip_dupradar true \
    --max_cpus 8 \
    --max_memory '32.GB' \
    -resume
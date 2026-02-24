#!/bin/bash

# 1. 基础环境清理
PROJECT_DIR="/home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216"
cd $PROJECT_DIR || exit 1
unset PROMPT_COMMAND; __vsc_prompt_cmd_original() { :; }

# 2. 针对老旧服务器的 Singularity 兼容性设置
export APPTAINER_TIMEOUT=1200
export SINGULARITY_TIMEOUT=1200
# 强行给 Singularity 引擎塞入参数
export NXF_SINGULARITY_RUN_OPTIONS="-p -s -C"
# 增加超时阈值到 20 分钟，给老服务器响应时间
export APPTAINER_TIMEOUT=1200
export SINGULARITY_TIMEOUT=1200


# 3. 运行命令（增加了特权避让参数）
PIPELINE_DIR="/home/songz/.nextflow/assets/nf-core/rnaseq_backup_20260219_055913"
MOUSE_FASTA="/home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.fasta"
MOUSE_GTF="/home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.gtf"

nextflow run $PIPELINE_DIR \
    -profile singularity \
    --input ./samplesheet.csv \
    --outdir ./results \
    --fasta $MOUSE_FASTA \
    --gtf $MOUSE_GTF \
    -work-dir /home/songz/gaoz/work/01_Junqiang_Ding_0216 \
    --download_fastp_bin false \
    --skip_dupradar true \
    --max_cpus 8 \
    --max_memory '32.GB' \
    --singularity_run_options "-p -C" \
    -resume
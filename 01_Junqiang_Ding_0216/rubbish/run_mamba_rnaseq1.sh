#!/bin/bash
# 进入项目目录
cd /home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216 || exit

# 1. 强行锁定环境变量（这是解决报错 127 的绝杀）
export PATH="/home/songz/miniforge3/envs/R44_RNA/bin:$PATH"
export NXF_OFFLINE=true

# 2. 运行 Nextflow (重点：绝对不加 -profile conda)
nextflow run /home/songz/gaoz/GZ_Project_2026/rnaseq-3.12.0 \
    --input ./samplesheet.csv \
    --outdir ./results \
    --fasta /home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.fasta \
    --gtf /home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.gtf \
    -work-dir /home/songz/gaoz/work/01_Junqiang_Ding_0216 \
    --max_cpus 8 \
    --max_memory '32.GB' \
    -resume
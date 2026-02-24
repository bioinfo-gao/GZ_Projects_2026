#!/bin/bash
# 确保在项目目录
cd /home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216 || exit

# 显式指定 mamba 路径并清理旧日志
export CONDA_EXE=$(which mamba)
rm -f .nextflow.log*

# 运行手术后的 v3.12.0 版本（不依赖外部插件，离线友好）
nextflow run /home/songz/gaoz/GZ_Project_2026/rnaseq-3.12.0 \
    -profile conda \
    --input ./samplesheet.csv \
    --outdir ./results \
    --fasta /home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.fasta \
    --gtf /home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.gtf \
    -work-dir /home/songz/gaoz/work/01_Junqiang_Ding_0216 \
    --skip_fastq_lint \
    --max_cpus 8 \
    --max_memory '32.GB' \
    -resume
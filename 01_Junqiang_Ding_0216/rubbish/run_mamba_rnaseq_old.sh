#!/bin/bash
# 确保在项目目录
cd /home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216 || exit

# 显式指定 mamba 路径
export CONDA_EXE=$(which mamba)

# delete uncessary strict lint
nextflow run /home/songz/.nextflow/assets/nf-core/rnaseq_backup_20260219_055913 \
    -profile conda \
    --input ./samplesheet.csv \
    --outdir ./results \
    --fasta /home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.fasta \
    --gtf /home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.gtf \
    -work-dir /home/songz/gaoz/work/01_Junqiang_Ding_0216 \
    --skip_fastq_lint \
    --download_fastp_bin false \
    --skip_dupradar true \
    --extra_fq_lint_args "--disable-validator S007" \
    --max_cpus 8 \
    --max_memory '32.GB' \
    --aligner star \
    --skip_rsem \
    -resume
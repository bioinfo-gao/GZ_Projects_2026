# 0. conda activation
mamba activate R44_RNA
# 1. 进入项目目录
cd /home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216

# 2. 启动 Nextflow 补跑任务（已调整为 16核/64GB）
nohup nextflow run /home/songz/gaoz/GZ_Project_2026/rnaseq-3.12.0/main.nf \
    -profile conda \
    --input /home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216/samplesheet_full.csv \
    --outdir /home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216/results \
    --fasta /home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.fasta \
    --gtf /home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.gtf \
    -work-dir /home/songz/gaoz/work/01_Junqiang_Ding_0216 \
    --aligner star_salmon \
    --max_cpus 16 \
    --max_memory '64.GB' \
    -resume \
    --skip_dupradar --skip_rseqc --skip_biotype_qc \
    -with-report D6_final_v2.html > D6_manual.log 2>&1 &

 # 3 monitoring  
 tail -f D6_manual.log 
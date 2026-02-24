# 1. 激活环境
mamba activate R44_RNA

# 2. 进入项目目录
cd /home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216

# 3. 环境变量“焊死”：切断网络，强制使用本地 R44_RNA 软件路径
export PATH="/home/songz/miniforge3/envs/R44_RNA/bin:$PATH"
export NXF_OFFLINE=true

# 4. 执行本地离线断点续传命令
nextflow run /home/songz/gaoz/GZ_Project_2026/rnaseq-3.12.0/main.nf \
    --input ./samplesheet.csv \
    --outdir ./results \
    --fasta /home/songz/gaoz/reference/Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.fa \
    --gtf /home/songz/gaoz/reference/Homo_sapiens/NCBI/GRCh38/Annotation/Genes/genes.gtf \
    --star_index /home/songz/gaoz/reference/Homo_sapiens/NCBI/GRCh38/Sequence/STAR_Index/ \
    -work-dir /home/songz/gaoz/work/01_Junqiang_Ding_0216 \
    --aligner star_salmon \
    --max_cpus 16 \
    --max_memory '64.GB' \
    --skip_dupradar \
    --skip_rseqc \
    --skip_biotype_qc \
    -resume
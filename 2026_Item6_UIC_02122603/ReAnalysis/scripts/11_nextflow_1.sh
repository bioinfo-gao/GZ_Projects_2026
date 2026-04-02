tmux new -s rnaseq_uic
# 通过指定 --star_index，流程将跳过数小时的索引构建时间，直接开始比对。
# 运行 nf-core
nextflow run nf-core/rnaseq \
    -r 3.15.1 \
    -profile singularity \
    -resume \
    --input /home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis/scripts/Sample_Sheet_UIC.csv \
    --outdir /home/gao/projects/2026_Item6_UIC_02122603/output_nf_core \
    --fasta /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/GRCh38.primary_assembly.genome.fa \
    --gtf /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/gencode.v45.annotation.gtf \
    --star_index /Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/star_index \
    --gencode \
    --aligner star_salmon \
    --remove_ribo_rna \
    --save_non_ribo_reads \
    --max_cpus 32 \
    --max_memory '80.GB'

# Ctrl + b， then  d
# tmux a
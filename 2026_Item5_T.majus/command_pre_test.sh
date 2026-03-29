# 建议先进入你的项目工作目录
cd /home/gao/Code/Bioinfo_Analysis_Projects

# 启动 tmux 以防网络中断
# tmux new -s rnaseq_tmajus

nextflow run nf-core/rnaseq \
    -profile docker \
    --input ./samplesheet.csv \
    --outdir ./results \
    --genome 'G-Zone_Tmajus_v1' \
    --fasta ./T_majus.primary_assembly.genome.fa \
    --gtf ./T_majus.annotation.gtf \
    --star_index ./star_index \
    --save_reference \
    --max_cpus 32 \
    --max_memory '120GB' \
    --skip_dupradar \
    --skip_multiqc
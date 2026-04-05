# 进入工作目录
cd /home/gao/projects/2026_Item5_T.majus/scripts

# 启动并进入 Tmux 会话, 如果已经存在，则加入
tmux new-session -A -s rnaseq_majus 

# 修正后的运行命令
# 请根据您第一步 ls 看到的结果，替换下方具体的 FASTA 和 GTF 文件名
nextflow run nf-core/rnaseq \
    -r 3.15.1 \
    -profile singularity \
    -c local_plant_small.config \
    --input nf_core_samplesheet.csv \
    --outdir ../output_results \
    --fasta "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/T_majus.primary_assembly.genome.fa" \
    --gtf "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/T_majus.annotation.gtf" \
    --star_index "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/star_index" \
    --aligner star_salmon \
    --max_cpus 32 \
    --max_memory '85.GB' \
    -resume

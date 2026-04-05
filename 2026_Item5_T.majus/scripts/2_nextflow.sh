# 1. 确保进入工作目录
cd /home/gao/projects/2026_Item5_T.majus/scripts

# 2. 启动并进入 Tmux 会话 (如果会话已存在则直接进入)
tmux new-session -A -s rnaseq_majus 

# 3. 运行 nf-core 3.15.1 极速版
nextflow run nf-core/rnaseq \
    -r 3.15.1 \
    -profile singularity \
    -c local_plant_small.config \
    --input nf_core_samplesheet.csv \
    --outdir ../output_results \
    --fasta "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/*.fasta" \
    --gtf "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/*.gtf" \
    --star_index "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/star_index" \
    --aligner star_salmon \
    --max_cpus 32 \
    --max_memory '85.GB' \
    -resume


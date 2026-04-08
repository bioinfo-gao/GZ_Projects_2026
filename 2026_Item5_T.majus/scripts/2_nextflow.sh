# 1. 进入您的脚本工作目录
cd /home/gao/projects/2026_Item5_T.majus/scripts

# 2. 启动/进入 Tmux 会话
# tmux new-session -A -s rnaseq_majus 
# 重新进入（挂载）名为 rnaseq_majus 的会话
tmux a -t rnaseq_majus 

# 3. 启动 nf-core 3.15.1
# 路径校对记录：
# Tropaeolum_majus (确认拼写)
# T_majus.primary_assembly.genome.fa (确认文件名)
# T_majus.annotation.gtf (确认文件名)
# star_index (确认子目录名)
# 运行 nf-core 3.15.1 极速版
# 路径说明：
# --gtf: 使用刚才校验通过的 55M 完美版
# --star_index: 使用预构建索引
nextflow run nf-core/rnaseq \
    -r 3.15.1 \
    -profile singularity \
    -c local_plant_small.config \
    --input nf_core_samplesheet.csv \
    --outdir ../output_results \
    --fasta "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/T_majus.primary_assembly.genome.fa" \
    --gtf "T_majus.final.gtf" \
    --star_index "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/star_index" \
    --aligner star_salmon \
    --max_cpus 32 \
    --max_memory '85.GB' \
    -resume

nextflow run nf-core/rnaseq \
    -r 3.15.1 \
    -profile singularity \
    -c local_plant_small.config \
    --input nf_core_samplesheet.csv \
    --outdir ../output_results \
    --fasta "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/T_majus.primary_assembly.genome.fa" \
    --gtf "T_majus.final.gtf" \
    --star_index "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/star_index" \
    --aligner star_salmon \
    --max_cpus 32 \
    --max_memory '90.GB' \
    -resume   


export NXF_OPTS="-Xms512m -Xmx2g"
nextflow run nf-core/rnaseq \
    -r 3.15.1 \
    -profile singularity \
    -c local_plant_small.config \
    --input nf_core_samplesheet.csv \
    --outdir ../output_results \
    --fasta "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/T_majus.primary_assembly.genome.fa" \
    --gtf "T_majus.final.gtf" \
    --star_index "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/star_index" \
    --aligner star_salmon \
    --max_cpus 32 \
    --max_memory '90.GB' \
    -resume

nextflow run nf-core/rnaseq \
    -r 3.15.1 \
    -profile singularity \
    -c local_plant_small.config \
    --input nf_core_samplesheet.csv \
    --outdir ../output_results \
    --fasta "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/T_majus.primary_assembly.genome.fa" \
    --gtf "T_majus.final.gtf" \
    --star_index "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/star_index" \
    --aligner star_salmon \
    --strandedness reverse \
    --max_cpus 32 \
    --max_memory '90.GB' \
    -resume    


# 限制 Nextflow 自身的内存开销，确保它不被 Killed
export NXF_OPTS="-Xms512m -Xmx2g"

nextflow run nf-core/rnaseq \
    -r 3.15.1 \
    -profile singularity \
    -c local_plant_small.config \
    --input nf_core_samplesheet.csv \
    --outdir ../output_results \
    --fasta "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/T_majus.primary_assembly.genome.fa" \
    --gtf "T_majus.final.gtf" \
    --star_index "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/star_index" \
    --aligner star_salmon \
    --strandedness reverse \
    --max_cpus 32 \
    --max_memory '90.GB' \
    -resume


export NXF_OPTS="-Xms512m -Xmx2g"
nextflow run nf-core/rnaseq \
    -r 3.15.1 \
    -profile singularity \
    -c local_plant_small.config \
    --input nf_core_samplesheet.csv \
    --outdir ../output_results \
    --fasta "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/T_majus.primary_assembly.genome.fa" \
    --gtf "T_majus.final.gtf" \
    --star_index "/Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/star_index" \
    --aligner star_salmon \
    --strandedness reverse \
    -resume
    
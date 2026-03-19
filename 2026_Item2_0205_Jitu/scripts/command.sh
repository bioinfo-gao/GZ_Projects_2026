conda config --add channels conda-forge
conda config --add channels bioconda # Nextflow is available via the Bioconda channel.

mamber install nextflow 
nextflow -version
# export NXF_SINGULARITY_CACHEDIR=/Work_bio/gao/projects/singularity_cache
# mkdir -p $NXF_SINGULARITY_CACHEDIR
# # 如果这个目录为空或不存在，说明镜像尚未完全下载。不用担心，下一次运行时会自动下载。
# # 首先确定你的工作目录正确不正确， 且其中有无 
# ls -lh $NXF_SINGULARITY_CACHEDIR

tmux new -s rnaseq  d

nextflow run nf-core/rnaseq \
    -r 3.14.0 \
    -profile singularity \
    -resume \
    --input /home/gao/projects/2026_Item2_0205_Jitu/scripts/Sample_Sheet2.csv \
    --outdir /home/gao/projects/2026_Item2_0205_Jitu/output \
    --fasta /Work_bio/references/Homo_sapiens/GRCh38/GENCODE/human_gencode_v45/GRCh38.primary_assembly.genome.fa \
    --gtf /Work_bio/references/Homo_sapiens/GRCh38/GENCODE/human_gencode_v45/gencode.v45.annotation.gtf \
    --gencode \
    --aligner star_salmon \
    --remove_ribo_rna \
    --save_reference \
    --save_nonrRNA_reads \
    --max_cpus 32 \
    --max_memory '64.GB'

# 在 nf-core/rnaseq 命令里，把 --fasta 换成 --star_index /你的路径/star_index 
# --star_index /Work_bio/references/Mus_musculus/GRCm39/GENCODE_M35/star_index \ 会正常快30min 以上，应该使用这个
# Ctrl+B, D     # detach the tmux, let it run in the background

tmux a  # return the last tmux 

exit  # exit from the current tmux # or Ctrl D. BUT I recommend exit
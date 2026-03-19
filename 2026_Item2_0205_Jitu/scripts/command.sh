# export NXF_SINGULARITY_CACHEDIR=/Work_bio/gao/projects/singularity_cache
# mkdir -p $NXF_SINGULARITY_CACHEDIR
# # 如果这个目录为空或不存在，说明镜像尚未完全下载。不用担心，下一次运行时会自动下载。
# # 首先确定你的工作目录正确不正确， 且其中有无 
# ls -lh $NXF_SINGULARITY_CACHEDIR

tmux new -s rnaseq  

echo $TMUX
# 如果输出类似 /tmp/tmux-1000/default,12345,0 的字符串（包含 tmux 服务路径和会话信息），说明你在 tmux 中。
# 如果没有输出（空行），说明不在 tmux 中。
# tmux info 命令
tmux info 2>/dev/null
# 如果在 tmux 内，会显示当前会话的详细信息。
# 如果不在 tmux 内，会提示 no server running on /tmp/tmux-... 或 can't find server（错误信息会被重定向到 /dev/null 则不显示）。
# 查看终端窗口标题（某些终端）
# 有些终端会在标题栏显示 [tmux] 或当前会话名,需要用鼠标悬停或查看标题栏才能看到。

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


# Ctrl+B, D     

tmux a

exit 
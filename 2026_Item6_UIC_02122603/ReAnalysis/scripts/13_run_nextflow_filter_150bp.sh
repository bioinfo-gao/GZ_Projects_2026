tmux new -s bam 
cd /home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis/scripts

# nextflow run 12_nextflow_filter_150bp.nf \
#     -profile singularity \
#     --outdir /home/gao/projects/2026_Item6_UIC_02122603/Final_Filtered_Results \
#     -resume

# tmux a
nextflow run 12_nextflow_filter_150bp.nf -profile conda --outdir /home/gao/projects/2026_Item6_UIC_02122603/Final_Filtered_Results -resume
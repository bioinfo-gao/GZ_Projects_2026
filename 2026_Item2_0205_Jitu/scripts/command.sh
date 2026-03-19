export NXF_SINGULARITY_CACHEDIR=/Work_bio/gao/projects/singularity_cache
mkdir -p $NXF_SINGULARITY_CACHEDIR

ls -lh $NXF_SINGULARITY_CACHEDIR

tmux new -s rnaseq  

nextflow run nf-core/rnaseq \
    -r 3.14.0 \
    -profile singularity \
    -resume \
    --input Sample_Sheet2.csv \
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
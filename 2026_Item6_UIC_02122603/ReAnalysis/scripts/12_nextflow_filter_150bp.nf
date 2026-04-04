nextflow.enable.dsl=2

params.bam_dir = "/Work_bio/gao/projects/2026_Item6_UIC_02122603/output_nf_fast/star_salmon"
params.gtf     = "/Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/gencode.v45.annotation.gtf"
params.outdir  = "/Work_bio/gao/projects/2026_Item6_UIC_02122603/Final_Filtered_Results"
params.cutoff  = 150

// 定义 Conda 依赖字符串
def SAMTOOLS_ENV = "bioconda::samtools=1.17"
def SUBREAD_ENV  = "bioconda::subread=2.0.1"

process FILTER_BAM {
    tag "$sample_id"
    conda SAMTOOLS_ENV
    publishDir "${params.outdir}/filtered_bams", mode: 'copy'
    input: tuple val(sample_id), path(bam)
    output: tuple val(sample_id), path("${sample_id}_long_150.bam"), emit: filtered_bam
    script:
    """
    samtools view -h -e 'tlen >= ${params.cutoff} || tlen <= -${params.cutoff}' $bam -b -o ${sample_id}_long_150.bam
    """
}

process REQUANTIFY_MATRIX {
    tag "Matrix_Gen"
    conda SUBREAD_ENV
    publishDir "${params.outdir}/counts", mode: 'copy'
    input: path bams
    output: path "filtered_counts_v150_matrix.txt"
    script:
    """
    featureCounts -p -T 16 -s 2 -a ${params.gtf} -o filtered_counts_v150_matrix.txt ${bams}
    """
}

process EXTRACT_TRASH_BAM {
    tag "Extract_$sample_id"
    conda SAMTOOLS_ENV
    input: tuple val(sample_id), path(bam)
    output: tuple val(sample_id), path("${sample_id}_trash.bam"), emit: trash_bam
    script:
    """
    samtools view -h -e 'tlen < ${params.cutoff} && tlen > -${params.cutoff} && tlen != 0' $bam -b -o ${sample_id}_trash.bam
    """
}

process QUANTIFY_TRASH {
    tag "Quant_$sample_id"
    conda SUBREAD_ENV
    publishDir "${params.outdir}/trash_analysis", mode: 'copy'
    input: tuple val(sample_id), path(trash_bam)
    output: path "${sample_id}_trash_stats.txt"
    script:
    """
    featureCounts -p -T 8 -s 2 -a ${params.gtf} -o ${sample_id}_trash_stats.txt ${trash_bam}
    """
}

workflow {
    bam_ch = Channel.fromPath("${params.bam_dir}/*.markdup.sorted.bam")
                    .map { it -> [ it.baseName.replace('.markdup.sorted', ''), it ] }

    FILTER_BAM(bam_ch)
    REQUANTIFY_MATRIX(FILTER_BAM.out.filtered_bam.map{it[1]}.collect())

    trash_targets = bam_ch.filter { it[0] =~ /WT_2|Mock_3/ }
    EXTRACT_TRASH_BAM(trash_targets)
    QUANTIFY_TRASH(EXTRACT_TRASH_BAM.out.trash_bam)
}
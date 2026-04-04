nextflow.enable.dsl=2

// --- 路径参数校准 ---
params.bam_dir = "/Work_bio/gao/projects/2026_Item6_UIC_02122603/output_nf_fast/star_salmon"
params.gtf     = "/Work_bio/references/Homo_sapiens/GRCh38/human_gencode_v45/gencode.v45.annotation.gtf"
params.outdir  = "/Work_bio/gao/projects/2026_Item6_UIC_02122603/Final_Filtered_Results"
params.cutoff  = 150

process FILTER_BAM {
    tag "$sample_id"
    container 'biocontainers/samtools:v1.17_cv1'
    publishDir "${params.outdir}/filtered_bams", mode: 'copy'

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id), path("${sample_id}_long_150.bam"), emit: filtered_bam
    path "${sample_id}_long_150.bam.bai"

    script:
    """
    # 使用 tlen 变量代替 isize，并增加正负值判断以增强兼容性
    samtools view -h -e 'tlen >= ${params.cutoff} || tlen <= -${params.cutoff}' $bam -b -o ${sample_id}_long_150.bam
    samtools index ${sample_id}_long_150.bam
    """
}

process REQUANTIFY {
    tag "Matrix_Generation"
    container 'biocontainers/subread:v2.0.1_cv1'
    publishDir "${params.outdir}/counts", mode: 'copy'

    input:
    path bams

    output:
    path "filtered_counts_v150_matrix.txt"
    path "filtered_counts_v150_matrix.txt.summary"

    script:
    """
    featureCounts -p -T 16 -s 2 \\
        -a ${params.gtf} \\
        -o filtered_counts_v150_matrix.txt \\
        ${bams}
    """
}

process TRASH_ANALYSIS {
    tag "Trash_$sample_id"
      // 核心修正：添加容器镜像
    container 'biocontainers/subread:v2.0.1_cv1' 
    publishDir "${params.outdir}/trash_analysis", mode: 'copy'

    input:
    tuple val(sample_id), path(bam)

    output:
    path "${sample_id}_trash_stats.txt"

    script:
    """
    # 同样在 Trash 分析中使用 tlen 逻辑
    samtools view -h -e '(tlen < ${params.cutoff} && tlen > 0) || (tlen > -${params.cutoff} && tlen < 0)' $bam -b -o ${sample_id}_trash.bam
    featureCounts -p -T 8 -s 2 -a ${params.gtf} -o ${sample_id}_trash_stats.txt ${sample_id}_trash.bam
    """
}

workflow {
    def bam_pattern = "${params.bam_dir}/*.markdup.sorted.bam"
    
    bam_ch = Channel.fromPath(bam_pattern)
                    .ifEmpty { error "Cannot find BAM files in ${params.bam_dir}" }
                    .map { it -> [ it.baseName.replace('.markdup.sorted', ''), it ] }

    FILTER_BAM(bam_ch)
    REQUANTIFY(FILTER_BAM.out.filtered_bam.map{it[1]}.collect())
    
    trash_targets = bam_ch.filter { it[0] =~ /WT_2|Mock_3/ }
    TRASH_ANALYSIS(trash_targets)
}
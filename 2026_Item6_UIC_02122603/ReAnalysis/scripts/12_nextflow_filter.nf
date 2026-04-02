nextflow.enable.dsl=2

// 输入：nf-core 输出的原始 BAM 路径
params.bam_dir = "/home/gao/projects/2026_Item6_UIC_02122603/output_nf_core/star_salmon"
params.gtf     = "/Work_bio/references/Homo_sapiens/GRCh38/GENCODE/human_gencode_v45/gencode.v45.annotation.gtf"
params.outdir  = "/home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis/Final_Filtered_Results"

process FILTER_AND_INDEX {
    tag "$sample_id"
    container 'biocontainers/samtools:v1.17_cv1' // 或者使用 singularity
    publishDir "${params.outdir}/filtered_bams", mode: 'copy'

    input:
    tuple val(sample_id), path(bam)

    output:
    path "${sample_id}_v250.bam", emit: filtered_bam
    path "${sample_id}_v250.bam.bai"

    script:
    """
    # 核心过滤：只保留插入片段 >= 250bp 的 pair
    samtools view -h -e 'abs(isize) >= 250' $bam -b -o ${sample_id}_v250.bam
    samtools index ${sample_id}_v250.bam
    """
}

process REQUANTIFY {
    tag "featureCounts"
    container 'biocontainers/subread:v2.0.1_cv1'
    publishDir "${params.outdir}/counts", mode: 'copy'

    input:
    path bams

    output:
    path "filtered_counts_v250.txt"

    script:
    """
    featureCounts -p -T 16 -s 2 \
        -a ${params.gtf} \
        -o filtered_counts_v250.txt \
        ${bams}
 Faust    """
}

// 可选：分析短片段的来源 (Objective 2)
process ANALYZE_TRASH {
    tag "$sample_id"
    publishDir "${params.outdir}/trash_analysis", mode: 'copy'

    input:
    tuple val(sample_id), path(bam)

    output:
    path "${sample_id}_trash_counts.txt"

    script:
    """
    # 提取短片段 (30-250bp)
    samtools view -h -e 'abs(isize) > 30 && abs(isize) < 250' $bam -b -o ${sample_id}_trash.bam
    featureCounts -p -T 8 -s 2 -a ${params.gtf} -o ${sample_id}_trash_counts.txt ${sample_id}_trash.bam
    """
}

workflow {
    // 匹配 nf-core 输出的 BAM 文件名模式
    bam_ch = Channel.fromPath("${params.bam_dir}/*.sortedByCoord.out.bam")
                    .map { it -> [it.baseName.split('\\.')[0], it] }

    // 执行过滤
    FILTER_AND_INDEX(bam_ch)

    // 重新定量
    REQUANTIFY(FILTER_AND_INDEX.out.filtered_bam.collect())

    // 针对 WT2 和 Mock3 进行垃圾分析
    trash_targets = bam_ch.filter { it[0] =~ /WT_2|Mock_3/ }
    ANALYZE_TRASH(trash_targets)
}
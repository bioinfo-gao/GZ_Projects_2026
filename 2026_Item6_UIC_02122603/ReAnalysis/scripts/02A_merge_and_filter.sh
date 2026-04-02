#!/bin/bash
# 02A_merge_and_assess.sh
# 合并多lane数据并评估插入片段分布（不过滤）

#!/bin/bash
# 02_merge_and_assess.sh

BASE_DIR="/home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis"
RAW_LINK="${BASE_DIR}/raw_fastq_link"
THREADS=32

echo "=========================================="
echo "UIC RNA-seq - 合并 lane 并评估插入片段"
echo "=========================================="
echo "线程数：${THREADS}"
echo "fastp 版本：$(fastp --version 2>&1 | head -1)"
echo ""

mkdir -p ${BASE_DIR}/processed_fastq

SUCCESS_COUNT=0
FAIL_COUNT=0

while read line; do
    if [[ ${line} == "sample_id"* ]]; then
        continue
    fi
    
    SAMPLE=$(echo ${line} | awk '{print $1}')
    GROUP=$(echo ${line} | awk '{print $2}')
    STATUS=$(echo ${line} | awk '{print $5}')
    
    echo "########################################"
    echo "### 样本：${SAMPLE} (组：${GROUP}, 状态：${STATUS})"
    echo "########################################"
    
    R1_FILES="${RAW_LINK}/${SAMPLE}/*_1.fq.gz"
    R2_FILES="${RAW_LINK}/${SAMPLE}/*_2.fq.gz"
    
    if ! ls ${R1_FILES} 1>/dev/null 2>&1; then
        echo "  ⚠ 找不到 R1 fastq 文件，跳过此样本"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi
    
    if ! ls ${R2_FILES} 1>/dev/null 2>&1; then
        echo "  ⚠ 找不到 R2 fastq 文件，跳过此样本"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi
    
    R1_COUNT=$(ls ${R1_FILES} | wc -l)
    R2_COUNT=$(ls ${R2_FILES} | wc -l)
    echo "  R1 文件数：${R1_COUNT}"
    echo "  R2 文件数：${R2_COUNT}"
    
    RAW_READS=$(zcat ${R1_FILES} | grep -c "^@" || echo 0)
    echo "  原始 reads 数：${RAW_READS}"
    
    echo "  运行 fastp 合并 lane 并评估..."
    
    # fastp 1.3.0 兼容参数
    if fastp \
        -i <(zcat ${R1_FILES}) \
        -I <(zcat ${R2_FILES}) \
        -o ${BASE_DIR}/processed_fastq/${SAMPLE}_R1.merged.fq.gz \
        -O ${BASE_DIR}/processed_fastq/${SAMPLE}_R2.merged.fq.gz \
        --json ${BASE_DIR}/processed_fastq/${SAMPLE}_assessment.json \
        --html ${BASE_DIR}/processed_fastq/${SAMPLE}_assessment.html \
        -w ${THREADS} \
        --trim_poly_g \
        --disable_adapter_trimming \
        --disable_quality_filtering \
        --disable_length_filtering \
        2>&1 | tee ${BASE_DIR}/processed_fastq/${SAMPLE}_assessment.log; then
        
        PROCESSED_READS=$(zcat ${BASE_DIR}/processed_fastq/${SAMPLE}_R1.merged.fq.gz | grep -c "^@" || echo 0)
        KEPT_PCT=$(echo "scale=2; ${PROCESSED_READS} * 100 / ${RAW_READS}" | bc)
        
        echo "  处理后 reads: ${PROCESSED_READS} (${KEPT_PCT}%)"
        echo "  ✓ 成功"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "  ⚠ fastp 执行失败，继续处理下一个样本"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    echo ""
    
done < ${BASE_DIR}/samples.txt

echo "=========================================="
echo "评估完成"
echo "成功：${SUCCESS_COUNT}/12"
echo "失败：${FAIL_COUNT}/12"
echo "=========================================="

# 生成总结
cat > ${BASE_DIR}/processed_fastq/00_assessment_summary.txt << EOF
UIC RNA-seq 插入片段评估总结
生成时间：$(date)
fastp 版本：$(fastp --version 2>&1 | head -1)
成功样本：${SUCCESS_COUNT}/12

EOF

for SAMPLE in Mock_1 Mock_2 Mock_3 WT_1 WT_2 WT_3 vpr_1 vpr_2 vpr_3 Q65R_1 Q65R_2 Q65R_3; do
    if [ -f "${BASE_DIR}/processed_fastq/${SAMPLE}_assessment.json" ]; then
        RAW=$(zcat ${RAW_LINK}/${SAMPLE}/*_1.fq.gz | grep -c "^@" || echo 0)
        PROCESSED=$(zcat ${BASE_DIR}/processed_fastq/${SAMPLE}_R1.merged.fq.gz | grep -c "^@" || echo 0)
        PCT=$(echo "scale=2; ${PROCESSED} * 100 / ${RAW}" | bc)
        echo "${SAMPLE}: ${RAW} → ${PROCESSED} (${PCT}%)" >> ${BASE_DIR}/processed_fastq/00_assessment_summary.txt
    else
        echo "${SAMPLE}: 失败" >> ${BASE_DIR}/processed_fastq/00_assessment_summary.txt
    fi
done

echo ""
cat ${BASE_DIR}/processed_fastq/00_assessment_summary.txt
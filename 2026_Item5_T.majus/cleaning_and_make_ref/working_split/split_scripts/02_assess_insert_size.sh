#!/bin/bash
# 01_assess_insert_size.sh
# 评估每个样本的插入片段大小分布，确定拆分阈值

SAMPLE_NAME=$1
INPUT_DIR=$2

cd ${INPUT_DIR}/${SAMPLE_NAME}

# 找到 R1 和 R2 文件
R1_FILE=$(ls *_1.fq.gz)
R2_FILE=$(ls *_2.fq.gz)

echo "=== 评估样本：${SAMPLE_NAME} ==="
echo "R1: ${R1_FILE}"
echo "R2: ${R2_FILE}"

# 使用 fastp 评估插入片段分布（只分析前 100 万条 reads 以加快速度）
fastp -i ${R1_FILE} -I ${R2_FILE} \
      --insert_size_mean \
      --insert_size_histogram \
      --reads_to_process 1000000 \
      -h ${SAMPLE_NAME}_insert_size.html \
      -j ${SAMPLE_NAME}_insert_size.json \
      -w 8

echo "插入片段分析报告已生成：${SAMPLE_NAME}_insert_size.html"
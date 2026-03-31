#!/bin/bash
# 02_assess_insert_size_batch_fixed.sh
# 使用 fastp 评估插入片段大小分布（修复版）

#!/bin/bash
# 02_assess_insert_size_batch_v4.sh
# 插入片段评估 - fastp 1.3.0 兼容版本

#!/bin/bash
# 02_assess_insert_size_batch_v5.sh
# 插入片段评估 - 正确捕获退出码版本

#!/bin/bash
# 02_assess_insert_size_batch_v6.sh
# 插入片段评估 - 改进报告命名版本

#!/bin/bash
# 02_assess_insert_size_minimal.sh
# 插入片段评估 - 极简版

BASE_DIR="/home/gao/projects/2026_Item5_T.majus/working_split"
OUTPUT_DIR="/home/gao/projects/2026_Item5_T.majus/split_output"

# 5 个冲突样本
SAMPLES=("WTS4_1" "WTS4_2" "WTS4_5" "WhS4_1" "WhS4_4")

# 对应的 CRISPR 样本（仅用于记录）
declare -A CRISPR_PAIRS=(
    ["WTS4_1"]="YF99"
    ["WTS4_2"]="YF106"
    ["WTS4_5"]="YF116"
    ["WhS4_1"]="YF123"
    ["WhS4_4"]="YF128"
)

THREADS=32

mkdir -p ${OUTPUT_DIR}

# 汇总报告
SUMMARY="${OUTPUT_DIR}/00_INSERT_SIZE_SUMMARY.txt"
LOG="${OUTPUT_DIR}/00_INSERT_SIZE_LOG.txt"

${SUMMARY}
${LOG}

echo "插入片段大小分布评估" >> ${SUMMARY}
echo "====================" >> ${SUMMARY}
echo "" >> ${SUMMARY}

for SAMPLE in "${SAMPLES[@]}"; do
    CRISPR=${CRISPR_PAIRS[$SAMPLE]}
    
    echo "### ${SAMPLE} ↔ ${CRISPR}" >> ${SUMMARY}
    echo "### ${SAMPLE}" | tee -a ${LOG}
    
    cd ${BASE_DIR}/${SAMPLE} || continue
    mkdir -p ${OUTPUT_DIR}/${SAMPLE}
    
    R1=$(ls *_1.fq.gz 2>/dev/null | head -1)
    R2=$(ls *_2.fq.gz 2>/dev/null | head -1)
    
    
    echo "  R1: ${R1}" >> ${SUMMARY}
    echo "  R2: ${R2}" >> ${SUMMARY}
    
    # 运行 fastp
    fastp -i ${R1} -I ${R2} \
          -h ${OUTPUT_DIR}/${SAMPLE}/${SAMPLE}_insert_size.html \
          -j ${OUTPUT_DIR}/${SAMPLE}/${SAMPLE}_insert_size.json \
          -w ${THREADS} \
          --report_title "${SAMPLE}"
    
    STATUS=$?
    
    if [ $STATUS -eq 0 ] && [ -f "${OUTPUT_DIR}/${SAMPLE}/${SAMPLE}_insert_size.json" ]; then
        echo "  状态：成功" >> ${SUMMARY}
        echo "  ✓ 成功" | tee -a ${LOG}
        
        # 提取插入片段数据
        python3 -c "
import json
with open('${OUTPUT_DIR}/${SAMPLE}/${SAMPLE}_insert_size.json') as f:
    data = json.load(f)
ins = data.get('insert_size', {})
if ins:
    print(f\"  平均：{ins.get('mean', 'N/A')} bp\")
    print(f\"  中位数：{ins.get('median', 'N/A')} bp\")
    print(f\"  峰值：{ins.get('peak', 'N/A')} bp\")
" | tee -a ${LOG}
        
        echo "  报告：${OUTPUT_DIR}/${SAMPLE}/${SAMPLE}_insert_size.html" >> ${SUMMARY}
    else
        echo "  状态：失败" >> ${SUMMARY}
        echo "  ❌ 失败" | tee -a ${LOG}
    fi
    
    echo "" >> ${SUMMARY}
    echo "" | tee -a ${LOG}
done

echo "完成" >> ${SUMMARY}
echo "====================" >> ${SUMMARY}
echo "汇总报告：${SUMMARY}"
echo "日志文件：${LOG}"

# mamba install fastp -y -n base # 安装 fastp（如果尚未安装） -y, yes 的简写，表示自动确认安装, -n base 表示在 base 环境中安装
# ========== 步骤 4: 创建 tmux 会话并运行 ==========
# tmux new -s insert_size_eval
# mamba activate base
# bash 02_assess_insert_size_batch_fast.sh
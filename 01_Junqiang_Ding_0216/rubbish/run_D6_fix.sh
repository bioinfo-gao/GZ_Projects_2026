#!/bin/bash

# ============================================================
# 脚本名称: run_D6_fix.sh
# 功能: 1. 监听当前任务 2. 备份结果 3. 激活环境 4. 低资源补跑D6
# 运行方式: nohup bash ./run_D6_fix.sh > D6_fix_run.log 2>&1 &
# ============================================================

# 1. 核心路径定义
WORKING_DIR="/home/songz/gaoz/GZ_Project_2026/01_Junqiang_Ding_0216"
RESULT_DIR="$WORKING_DIR/results"
BAK_DIR="$WORKING_DIR/results_bak"
INPUT_CSV="$WORKING_DIR/samplesheet_full.csv"
NF_MAIN="/home/songz/gaoz/GZ_Project_2026/rnaseq-3.12.0/main.nf"

# 2. 进入工作目录
echo "正在进入工作目录: $WORKING_DIR"
cd "$WORKING_DIR" || { echo "错误: 无法进入目录"; exit 1; }

# 3. 监听机制
echo "开始监听：等待当前所有 songz 的 Nextflow 进程结束..."
while pgrep -u songz -f nextflow > /dev/null; do
    sleep 300  # 每 5 分钟检查一次
done
echo "检测到前序任务已完成，时间：$(date)"

# 4. 数据备份 (results -> results_bak)
if [ -d "$RESULT_DIR" ]; then
    echo "正在执行备份: results -> results_bak..."
    rm -rf "$BAK_DIR"
    cp -r "$RESULT_DIR" "$BAK_DIR"
    echo "备份完成。"
else
    echo "警告: 未发现 results 目录，跳过备份步骤。"
fi

# 5. 环境初始化 (激活 mamba 环境)
echo "正在初始化 mamba 环境 R44_RNA..."
# 必须先 source conda 的 profile 才能在脚本中使用 mamba/conda activate
source ~/anaconda3/etc/profile.d/conda.sh || source ~/miniconda3/etc/profile.d/conda.sh
mamba activate R44_RNA || { echo "错误: 无法激活 R44_RNA 环境"; exit 1; }

# 6. 启动补跑任务 (白天低资源模式)
echo "正在启动 D6 补跑任务 (max_cpus: 2, max_memory: 16GB)..."
export NXF_OFFLINE=TRUE

nextflow run "$NF_MAIN" \
    --input "$INPUT_CSV" \
    --outdir "$RESULT_DIR" \
    --fasta /home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.fasta \
    --gtf /home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.gtf \
    -work-dir /home/songz/gaoz/work/01_Junqiang_Ding_0216 \
    --aligner star_salmon \
    --max_cpus 2 \
    --max_memory '16.GB' \
    --skip_dupradar \
    --skip_rseqc \
    --skip_biotype_qc \
    -resume \
    -with-report "$WORKING_DIR/D6_final_report.html"

echo "所有流程于 $(date) 执行完毕，请检查 $RESULT_DIR 目录。"
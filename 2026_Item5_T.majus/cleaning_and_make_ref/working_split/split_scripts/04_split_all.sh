#!/bin/bash

# =================================================================
# 脚本名称: split_maj_crispr.sh
# 功能: 基于 CRISPR Scaffold 序列物理拆分混样数据
# =================================================================

# 0. 环境准备
# mamba install -c bioconda bbmap -y # base
# 3. 检查是否安装成功
# bbduk.sh --version
# bbduk.sh 本质上是一个 Java 封装脚本，请确保你的系统有 Java 环境：
# java -version java -version

# 1. 基础配置
BASE_DIR="/home/gao/projects/2026_Item5_T.majus/working_split"
SCAFFOLD_KEY="GTTTTAGAGCTAGAAATA" # 根据你的 zcat 结果确定的核心特征

# 2. 定义文件夹与输出文件名的对应关系
# 格式: "文件夹名:RNAseq输出前缀:CRISPR输出前缀"
SAMPLES=(
    "WTS4_1:Real_WTS4_1:YF99"
    "WTS4_2:Real_WTS4_2:YF106"
    "WTS4_5:Real_WTS4_5:YF116"
    "WhS4_1:Real_WhS4_1:YF123"
    "WhS4_4:Real_WhS4_4:YF128"
)

# about 15 kernel for java , 6 kernel for bgzip, 9min to finish
echo "开始处理任务..."
echo "特征识别序列: $SCAFFOLD_KEY"

# 3. 循环处理每一个文件夹
for ITEM in "${SAMPLES[@]}"; do
    # 解析对应关系
    IFS=":" read -r FOLDER RNA_PREFIX CRISPR_PREFIX <<< "$ITEM"
    
    CURRENT_PATH="${BASE_DIR}/${FOLDER}"
    
    if [ ! -d "$CURRENT_PATH" ]; then
        echo "警告: 找不到文件夹 $CURRENT_PATH，跳过。"
        continue
    fi

    echo "----------------------------------------------------"
    echo "正在处理目录: $FOLDER"
    cd "$CURRENT_PATH"

    # 识别 R1 和 R2 文件
    R1_FILE=$(ls *L7_1.fq.gz 2>/dev/null)
    R2_FILE=$(ls *L7_2.fq.gz 2>/dev/null)

    if [ -z "$R1_FILE" ] || [ -z "$R2_FILE" ]; then
        echo "错误: 在 $FOLDER 中找不到 fq.gz 文件！"
        continue
    fi

    echo "输入文件: $R1_FILE / $R2_FILE"

    # 创建输出文件夹
    mkdir -p split_results

    # 4. 调用 bbduk.sh 进行物理拆分
    # outm (matched): 含有 Scaffold 的 Read -> CRISPR 项目
    # outu (unmatched): 不含 Scaffold 的 Read -> RNA-seq 项目
    # k=18: 匹配特征码的长度
    # hdist=1: 允许 1 个碱基错配，防止测序错误导致拆不出来
    bbduk.sh in1="$R1_FILE" in2="$R2_FILE" \
             outm1="split_results/${CRISPR_PREFIX}_R1.fq.gz" outm2="split_results/${CRISPR_PREFIX}_R2.fq.gz" \
             outu1="split_results/${RNA_PREFIX}_R1.fq.gz" outu2="split_results/${RNA_PREFIX}_R2.fq.gz" \
             literal="$SCAFFOLD_KEY" k=18 hdist=1

    echo "完成 $FOLDER 拆分！"
    echo "结果保存至: $CURRENT_PATH/split_results/"
done

echo "===================================================="
echo "所有任务处理完毕！"
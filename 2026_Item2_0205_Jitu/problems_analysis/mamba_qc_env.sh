# 创建环境
mamba create -n qc_env -c bioconda -c conda-forge fastqc multiqc -y
# 激活环境
mamba activate qc_env

# 验证安装
fastqc --version  #  FastQC, v0.12.1
multiqc --version # multiqc, version 1.33

# enter the working directory and create output directory
cd /home/gao/projects/2026_Item2_0205_contamination_athenomics/
mkdir -p qc_results/fastqc

# 运行 FastQC (如果是双端测序，将所有 fastq.gz 文件放入)
# -t 指定线程数，-o 指定输出目录 # 

# This server has 32 kernel and 64 threads, as well as 96GB memory
# In generall, each person should not use more than half the resources, so I will use 32 threads for fastqc

# 原始数据在 /home/gao/Dropbox/Quote_02052601_lnc/各目录下，eg. C1_A, ch_3D，后缀为 .fq.gz
# 20 min
fastqc -t 32 -o qc_results/fastqc /home/gao/Dropbox/Quote_02052601_lnc/*/*.fq.gz


# MultiQC 生成汇总报告, 10 seconds
multiqc -o qc_results/multiqc qc_results/fastqc/

# 查看报告路径
echo "报告生成完毕：/home/gao/Dropbox/Quote_02052601_lnc/qc_results/multiqc/multiqc_report.html"

# ls
# C1_A  C1_C  C2_A  C2_C  C3_A  C3_C  ch_1A  ch_1C  ch_2A  ch_2C  ch_3A  ch_3C  Sequencing_QC
# C1_B  C1_D  C2_B  C2_D  C3_B  C3_D  ch_1B  ch_1D  ch_2B  ch_2D  ch_3B  ch_3D

# 第二部分：快速诊断脚本（可选）
# 如果工程师想快速查看序列长度分布，可以用这个脚本直接提取关键信息：
#!/bin/bash
# 保存为 quick_qc.sh



echo "=========================================="
echo "快速 QC 诊断报告"
echo "=========================================="

for dir in C*; do
    echo ""
    echo "样本: $dir"
    echo "------------------------------------------"
    
    # 查找 .fq.gz 文件
    fq_file=$(find /home/gao/Dropbox/Quote_02052601_lnc/$dir -name "*.fq.gz" | head -1)
    
    if [ -n "$fq_file" ]; then
        # 抽取前1000条reads，计算平均长度
        avg_len=$(zcat $fq_file | head -4000 | awk 'NR%4==2 {sum+=length($0); n++} END {print sum/n}')
        echo "  平均读长: ${avg_len} bp"
        
        # 判断类型
        if (( $(echo "$avg_len > 100" | bc -l) )); then
            echo "  → 判定: Bulk RNA-seq (建议使用 nf-core/rnaseq)"
        elif (( $(echo "$avg_len > 15" | bc -l) )); then
            echo "  → 判定: Small RNA-seq (建议使用 nf-core/smrnaseq)"
        else
            echo "  → 判定: 异常数据 (需进一步检查)"
        fi
    else
        echo "  未找到 .fq.gz 文件"
    fi
done

echo ""
echo "=========================================="
echo "详细报告请查看: qc_results/multiqc/multiqc_report.html"
echo "=========================================="
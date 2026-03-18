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
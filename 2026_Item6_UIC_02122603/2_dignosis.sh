# 1. 查看哪些样本修剪量最高
cd /home/gao/Dropbox/Quote_02122603_UIC/Data_Analysis/QC/


# 1. 查看哪些样本修剪量最高
grep -A 20 "Cutadapt" QC.html | grep -E "Sample|trimmed"

# 2. 检查高修剪样本的插入片段分布
fastp -i sample_R1.fq.gz -I sample_R2.fq.gz \
      --insert_size_mean \
      -h sample_insert.html \
      -j sample_insert.json

# 3. 对比不同样本组的修剪模式
# (WTS4 vs WhS4 vs CRISPR)
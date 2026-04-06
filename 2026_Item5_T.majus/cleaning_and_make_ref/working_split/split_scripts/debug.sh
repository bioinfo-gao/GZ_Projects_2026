# 1. 检查 fastp 是否安装
which fastp
fastp --version

# 2. 检查 fastq 文件是否存在且可读
ls -lh /home/gao/projects/2026_Item5_T.majus/working_split/WhS4_4/*.fq.gz

# 3. 测试 fastp 能否读取文件
zcat /home/gao/projects/2026_Item5_T.majus/working_split/WhS4_4/WhS4_4_CKDL260004732-1A_235Y7KLT3_L7_1.fq.gz | head -4

# 4. 手动测试 fastp（单样本）
fastp -i /home/gao/projects/2026_Item5_T.majus/working_split/WhS4_4/WhS4_4_CKDL260004732-1A_235Y7KLT3_L7_1.fq.gz \
      -I /home/gao/projects/2026_Item5_T.majus/working_split/WhS4_4/WhS4_4_CKDL260004732-1A_235Y7KLT3_L7_2.fq.gz \
      --insert_size_mean \
      -h /tmp/test_fastp.html \
      -j /tmp/test_fastp.json \
      -w 4 \
      --reads_to_process 100000 \
      &> /home/gao/projects/2026_Item5_T.majus/fastp_run_details.txt

echo "fastp 退出码：$?"
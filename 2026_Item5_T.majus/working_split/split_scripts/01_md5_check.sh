#!/bin/bash
# 01_verify_md5.sh
# 验证每个样本目录中 fastq 文件的 MD5  checksum

cd /home/gao/projects/2026_Item5_T.majus/working_split/


for dir in WTS4_1 WTS4_2 WTS4_5 WhS4_1 WhS4_4; do
    echo "Checking $dir..."
    (cd "$dir" && md5sum -c MD5.txt) 2>&1
    echo "--------------------------"
done

# md5sum -c MD5.txt 2>&1
# WhS4_1_CKDL260004732-1A_235Y7KLT3_L7_1.fq.gz: OK
# WhS4_1_CKDL260004732-1A_235Y7KLT3_L7_2.fq.gz: OK

# Checking WTS4_1...
# WTS4_1_CKDL260004732-1A_235Y7KLT3_L7_1.fq.gz: OK
# WTS4_1_CKDL260004732-1A_235Y7KLT3_L7_2.fq.gz: OK
# --------------------------
# Checking WTS4_2...
# WTS4_2_CKDL260004732-1A_235Y7KLT3_L7_1.fq.gz: OK
# WTS4_2_CKDL260004732-1A_235Y7KLT3_L7_2.fq.gz: OK
# --------------------------
# Checking WTS4_5...
# WTS4_5_CKDL260004732-1A_235Y7KLT3_L7_1.fq.gz: OK
# WTS4_5_CKDL260004732-1A_235Y7KLT3_L7_2.fq.gz: OK
# --------------------------
# Checking WhS4_1...
# WhS4_1_CKDL260004732-1A_235Y7KLT3_L7_1.fq.gz: OK
# WhS4_1_CKDL260004732-1A_235Y7KLT3_L7_2.fq.gz: OK
# --------------------------
# Checking WhS4_4...
# WhS4_4_CKDL260004732-1A_235Y7KLT3_L7_1.fq.gz: OK
# WhS4_4_CKDL260004732-1A_235Y7KLT3_L7_2.fq.gz: OK
# --------------------------
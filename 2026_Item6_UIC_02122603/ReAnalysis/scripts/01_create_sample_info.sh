#!/bin/bash
# 01_create_sample_info.sh
# 创建UIC项目样本信息表和原始数据软链接

BASE_DIR="/home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis"
RAW_DATA_DIR="/Work_bio/dropbox/Dropbox_Data/Quote_02122603_UIC"

# 创建必要目录
mkdir -p ${BASE_DIR}/{scripts,filtered_fastq,quantification,abnormal_fragments,results}

# 创建原始fastq的软链接（不复制文件）
echo "创建原始数据软链接..."
cd ${BASE_DIR}
ln -sf ${RAW_DATA_DIR} raw_fastq_link

# 验证软链接
if [ -L "${BASE_DIR}/raw_fastq_link" ]; then
    echo "✓ 软链接创建成功"
    ls -la ${BASE_DIR}/raw_fastq_link
else
    echo "❌ 软链接创建失败"
    exit 1
fi

# 创建样本信息表， 更方便的办法是用 Data Preview by RandomFractalsInc 打开之后，在右上角自动可以选择保存为 csv 格式
#cat > ${BASE_DIR}/samples.txt << EOF
cat > ${BASE_DIR}/samples.tsv << EOF
sample_id	group	i7_index	i5_index	status	species
Mock_1	Mock	CTGAAGCT	CAGGACGT	normal	Human
Mock_2	Mock	TAATGCGC	GTACTGAC	normal	Human
Mock_3	Mock	CGGCTATG	GACCTGTA	abnormal	Human
WT_1	WT	TCCGCGAA	ATGTAACT	normal	Human
WT_2	WT	TCTCGCGC	GTTTCAGA	abnormal	Human
WT_3	WT	AGCGATAG	CACAGGAT	normal	Human
vpr_1	vpr	CGTGTAGG	TAGCTGCC	normal	Human
vpr_2	vpr	GACACTAC	AGCGAATG	normal	Human
vpr_3	vpr	TGCATACA	TATGCTGC	normal	Human
Q65R_1	Q65R	CAGTCTGG	AGAAGACT	normal	Human
Q65R_2	Q65R	TGGCACCT	TATAGCCT	normal	Human
Q65R_3	Q65R	CAAGGTGA	ATAGAGGC	normal	Human
EOF

echo ""
echo "样本信息表已创建："
cat ${BASE_DIR}/samples.tsv # cat ${BASE_DIR}/samples.txt

# 验证所有样本目录存在
echo ""
echo "验证样本目录..."
for SAMPLE in Mock_1 Mock_2 Mock_3 WT_1 WT_2 WT_3 vpr_1 vpr_2 vpr_3 Q65R_1 Q65R_2 Q65R_3; do
    if [ -d "${BASE_DIR}/raw_fastq_link/${SAMPLE}" ]; then
        FILE_COUNT=$(ls ${BASE_DIR}/raw_fastq_link/${SAMPLE}/*.fq.gz 2>/dev/null | wc -l)
        echo "  ✓ ${SAMPLE}: ${FILE_COUNT} 个fastq文件"
    else
        echo "  ❌ ${SAMPLE}: 目录不存在"
    fi
done

echo ""
echo "脚本1完成"
import pandas as pd
import glob
import os

# 运行方法
# cd /home/gao/projects/2026_Item5_T.majus/scripts
# python 1_produce_nf-core_Samplesheet.py

# 配置路径
fastq_dir = "/home/gao/Dropbox/Quote_03062602_plant"
original_csv = "/home/gao/projects/2026_Item5_T.majus/scripts/Sample_Sheet_corrected1.csv"
output_samplesheet = "/home/gao/projects/2026_Item5_T.majus/scripts/nf_core_samplesheet.csv"

# 读取原始表格
df = pd.read_csv(original_csv)
samples = df['Name in File'].unique()

data = []
for sample in samples:
    # 查找对应的 R1 和 R2 文件
    r1 = os.path.join(fastq_dir, f"{sample}_R1.fq.gz")
    r2 = os.path.join(fastq_dir, f"{sample}_R2.fq.gz")
    
    # 检查文件是否存在
    if os.path.exists(r1) and os.path.exists(r2):
        # strandedness 设为 auto 让流程自动检测，或者设为 reverse (如果是标准库)
        data.append([sample, r1, r2, 'auto'])
    else:
        print(f"Warning: 找不到样本 {sample} 的文件于 {fastq_dir}")

# 生成新表格
final_df = pd.DataFrame(data, columns=['sample', 'fastq_1', 'fastq_2', 'strandedness'])
final_df.to_csv(output_samplesheet, index=False)
print(f"成功生成 nf-core 专用 Samplesheet: {output_samplesheet}")
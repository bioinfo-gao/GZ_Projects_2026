import pandas as pd
import io

# 你的原始数据
csv_data = """Customer Name,Name in File,Species,Analysis Type,Strand Specific,machine Type,Sequencing Type,"Data Delivery Method (Required)",i7 index,i5 index
Qiuchen Li,Mock_1,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,CTGAAGCT,CAGGACGT
Qiuchen Li,Mock_2,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,TAATGCGC,GTACTGAC
Qiuchen Li,Mock_3,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,CGGCTATG,GACCTGTA
Qiuchen Li,WT_1,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,TCCGCGAA,ATGTAACT
Qiuchen Li,WT_2,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,TCTCGCGC,GTTTCAGA
Qiuchen Li,WT_3,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,AGCGATAG,CACAGGAT
Qiuchen Li,vpr_1,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,CGTGTAGG,TAGCTGCC
Qiuchen Li,vpr_2,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,GACACTAC,AGCGAATG
Qiuchen Li,vpr_3,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,TGCATACA,TATGCTGC
Qiuchen Li,Q65R_1,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,CAGTCTGG,AGAAGACT
Qiuchen Li,Q65R_2,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,TGGCACCT,TATAGCCT
Qiuchen Li,Q65R_3,Human,Bulk RNA Seq,Yes,Nova Seq X Plus,PE150,Partial lane sequencing-With Demultiplexing,CAAGGTGA,ATAGAGGC"""

df = pd.read_csv(io.StringIO(csv_data))
fastq_dir = "/home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis/processed_fastq"

# 构建 nf-core 格式
samplesheet = pd.DataFrame()
samplesheet['sample'] = df['Name in File']
# 修正后缀为 .merged.fq.gz
samplesheet['fastq_1'] = samplesheet['sample'].apply(lambda x: f"{fastq_dir}/{x}_R1.merged.fq.gz")
samplesheet['fastq_2'] = samplesheet['sample'].apply(lambda x: f"{fastq_dir}/{x}_R2.merged.fq.gz")
# 设置链特异性为 reverse (Gencode/TruSeq 标准)
samplesheet['strandedness'] = 'reverse' 

# 保存文件
output_path = "/home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis/scripts/Sample_Sheet_UIC.csv"
samplesheet.to_csv(output_path, index=False)
print(f"Samplesheet 成功生成: {output_path}")
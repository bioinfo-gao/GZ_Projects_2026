#!/usr/bin/env python3
# 05_final_quality_report.py
# 生成最终拆分质量验证报告

import os
import subprocess
import gzip
from datetime import datetime

BASE_DIR = "/home/gao/projects/2026_Item5_T.majus/split_output"
SAMPLES = ["WTS4_1", "WTS4_2", "WTS4_5", "WhS4_1", "WhS4_4"]

CRISPR_PAIRS = {
    "WTS4_1": "YF99",
    "WTS4_2": "YF106",
    "WTS4_5": "YF116",
    "WhS4_1": "YF123",
    "WhS4_4": "YF128"
}

def count_reads(fq_file):
    """统计 fastq 文件中的 reads 数"""
    if not os.path.exists(fq_file):
        return 0
    if fq_file.endswith('.gz'):
        cmd = f"zcat {fq_file} | grep -c '^@'"
    else:
        cmd = f"grep -c '^@' {fq_file}"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    try:
        return int(result.stdout.strip())
    except:
        return 0

def check_crispr_contamination(fq_file, scaffold="GTTTTAGAGCTAGAAATAGC"):
    """检查 CRISPR scaffold 序列污染"""
    if not os.path.exists(fq_file):
        return 0
    if fq_file.endswith('.gz'):
        cmd = f"zcat {fq_file} | grep -c '{scaffold}'"
    else:
        cmd = f"grep -c '{scaffold}' {fq_file}"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    try:
        return int(result.stdout.strip())
    except:
        return 0

def get_file_size(fq_file):
    """获取文件大小（GB）"""
    if not os.path.exists(fq_file):
        return 0
    size_bytes = os.path.getsize(fq_file)
    return size_bytes / (1024**3)

def generate_report():
    """生成质量报告"""
    
    report_file = f"{BASE_DIR}/final_quality_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    
    with open(report_file, 'w') as f:
        f.write("=" * 100 + "\n")
        f.write("索引冲突样本拆分最终质量验证报告\n")
        f.write("=" * 100 + "\n")
        f.write(f"生成时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"输出目录：{BASE_DIR}\n")
        f.write("\n")
        
        for sample in SAMPLES:
            crispr_sample = CRISPR_PAIRS[sample]
            sample_dir = f"{BASE_DIR}/{sample}"
            
            crispr_r1 = f"{sample_dir}/{sample}_CRISPR_R1.fq.gz"
            crispr_r2 = f"{sample_dir}/{sample}_CRISPR_R2.fq.gz"
            rnaseq_r1 = f"{sample_dir}/{sample}_RNAseq_R1.fq.gz"
            rnaseq_r2 = f"{sample_dir}/{sample}_RNAseq_R2.fq.gz"
            
            f.write("-" * 100 + "\n")
            f.write(f"样本：{sample} ↔ CRISPR 样本：{crispr_sample}\n")
            f.write("-" * 100 + "\n")
            
            # CRISPR 文件统计
            if os.path.exists(crispr_r1):
                crispr_reads = count_reads(crispr_r1)
                crispr_sig = check_crispr_contamination(crispr_r1)
                crispr_pct = crispr_sig / crispr_reads * 100 if crispr_reads > 0 else 0
                crispr_size = get_file_size(crispr_r1) + get_file_size(crispr_r2)
                
                f.write(f"  CRISPR 文件:\n")
                f.write(f"    Total reads: {crispr_reads:,}\n")
                f.write(f"    Contains scaffold: {crispr_sig:,} ({crispr_pct:.2f}%)\n")
                f.write(f"    File size (R1+R2): {crispr_size:.2f} GB\n")
                
                if crispr_pct < 80:
                    f.write(f"    ⚠️  警告：CRISPR 文件中 scaffold 序列比例偏低！\n")
            
            # RNA-seq 文件统计
            if os.path.exists(rnaseq_r1):
                rnaseq_reads = count_reads(rnaseq_r1)
                rnaseq_sig = check_crispr_contamination(rnaseq_r1)
                rnaseq_pct = rnaseq_sig / rnaseq_reads * 100 if rnaseq_reads > 0 else 0
                rnaseq_size = get_file_size(rnaseq_r1) + get_file_size(rnaseq_r2)
                
                f.write(f"  RNA-seq 文件:\n")
                f.write(f"    Total reads: {rnaseq_reads:,}\n")
                f.write(f"    Contains scaffold (contamination): {rnaseq_sig:,} ({rnaseq_pct:.4f}%)\n")
                f.write(f"    File size (R1+R2): {rnaseq_size:.2f} GB\n")
                
                if rnaseq_pct > 0.1:
                    f.write(f"    ⚠️  警告：RNA-seq 文件中 CRISPR 污染率较高 (>0.1%)！\n")
                else:
                    f.write(f"    ✓ 污染率在可接受范围内\n")
            
            f.write("\n")
        
        f.write("=" * 100 + "\n")
        f.write("报告结束\n")
        f.write("=" * 100 + "\n")
    
    print(f"最终质量报告已生成：{report_file}")
    print()
    
    # 同时输出到终端
    with open(report_file, 'r') as f:
        print(f.read())

if __name__ == '__main__':
    generate_report()
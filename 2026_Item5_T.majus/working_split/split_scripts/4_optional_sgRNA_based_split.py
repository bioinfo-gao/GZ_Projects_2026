#!/usr/bin/env python3
# 03_split_by_sequence.py
# 根据 CRISPR sgRNA scaffold 序列特征拆分混合文库

import argparse
import gzip
import os
from datetime import datetime

def open_file(filename, mode='rt'):
    """支持 gzip 和普通文件的打开"""
    if filename.endswith('.gz'):
        return gzip.open(filename, mode)
    else:
        return open(filename, mode)

def check_crispr_signature(seq, scaffold_seq="GTTTTAGAGCTAGAAATAGCAAGTTAAAATAAGGCTAGTCC"):
    """
    检查 reads 是否含有 CRISPR sgRNA scaffold 保守序列
    检查正向和反向互补，允许部分匹配（20bp 以上）
    """
    scaffold_seq = scaffold_seq.upper()
    seq = seq.upper().replace('\n', '').replace('\r', '')
    
    # 检查正向（取 scaffold 的关键区域）
    if scaffold_seq[:25] in seq or scaffold_seq[-25:] in seq:
        return True
    
    # 检查反向互补
    rc_scaffold = complement(scaffold_seq)
    if rc_scaffold[:25] in seq or rc_scaffold[-25:] in seq:
        return True
    
    return False

def complement(seq):
    """返回反向互补序列"""
    comp = {'A': 'T', 'T': 'A', 'G': 'C', 'C': 'G', 'N': 'N', 
            'a': 't', 't': 'a', 'g': 'c', 'c': 'g', 'n': 'n'}
    return ''.join(comp.get(base, 'N') for base in reversed(seq))

def split_fastq(r1_file, r2_file, output_prefix, scaffold_seq, report_file):
    """
    拆分 fastq 文件
    策略：含有 CRISPR scaffold 序列 → CRISPR 文库，否则 → RNA-seq 文库
    """
    
    print(f"开始拆分：{r1_file}, {r2_file}")
    print(f"输出前缀：{output_prefix}")
    print(f"时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # 输出文件
    crispr_r1 = f"{output_prefix}_CRISPR_R1.fq.gz"
    crispr_r2 = f"{output_prefix}_CRISPR_R2.fq.gz"
    rnaseq_r1 = f"{output_prefix}_RNAseq_R1.fq.gz"
    rnaseq_r2 = f"{output_prefix}_RNAseq_R2.fq.gz"
    
    # 计数器
    crispr_count = 0
    rnaseq_count = 0
    total_count = 0
    
    with open_file(r1_file) as r1_h, \
         open_file(r2_file) as r2_h, \
         gzip.open(crispr_r1, 'wt') as c_r1_h, \
         gzip.open(crispr_r2, 'wt') as c_r2_h, \
         gzip.open(rnaseq_r1, 'wt') as r_r1_h, \
         gzip.open(rnaseq_r2, 'wt') as r_r2_h:
        
        while True:
            # 读取 R1 的 4 行
            r1_header = r1_h.readline()
            if not r1_header:
                break
            
            r1_seq = r1_h.readline()
            r1_plus = r1_h.readline()
            r1_qual = r1_h.readline()
            
            # 读取 R2 的 4 行
            r2_header = r2_h.readline()
            r2_seq = r2_h.readline()
            r2_plus = r2_h.readline()
            r2_qual = r2_h.readline()
            
            total_count += 1
            
            # 检查 CRISPR 特征序列（检查 R1 和 R2）
            r1_seq_str = r1_seq.decode() if isinstance(r1_seq, bytes) else r1_seq
            r2_seq_str = r2_seq.decode() if isinstance(r2_seq, bytes) else r2_seq
            
            has_crispr_sig = (check_crispr_signature(r1_seq_str, scaffold_seq) or
                             check_crispr_signature(r2_seq_str, scaffold_seq))
            
            if has_crispr_sig:
                # 含有 CRISPR 特征 → 归为 CRISPR 文库
                c_r1_h.write(r1_header)
                c_r1_h.write(r1_seq)
                c_r1_h.write(r1_plus)
                c_r1_h.write(r1_qual)
                
                c_r2_h.write(r2_header)
                c_r2_h.write(r2_seq)
                c_r2_h.write(r2_plus)
                c_r2_h.write(r2_qual)
                crispr_count += 1
            else:
                # 不含 CRISPR 特征 → 归为 RNA-seq 文库
                r_r1_h.write(r1_header)
                r_r1_h.write(r1_seq)
                r_r1_h.write(r1_plus)
                r_r1_h.write(r1_qual)
                
                r_r2_h.write(r2_header)
                r_r2_h.write(r2_seq)
                r_r2_h.write(r2_plus)
                r_r2_h.write(r2_qual)
                rnaseq_count += 1
            
            # 每 100 万条 reads 输出进度
            if total_count % 1000000 == 0:
                print(f"  已处理 {total_count:,} 条 reads...", end='\r')
    
    # 计算统计信息
    crispr_pct = crispr_count / total_count * 100 if total_count > 0 else 0
    rnaseq_pct = rnaseq_count / total_count * 100 if total_count > 0 else 0
    
    print()
    print(f"=== 拆分结果 ===")
    print(f"总 reads 数：{total_count:,}")
    print(f"CRISPR reads: {crispr_count:,} ({crispr_pct:.2f}%)")
    print(f"RNA-seq reads: {rnaseq_count:,} ({rnaseq_pct:.2f}%)")
    print()
    print(f"输出文件：")
    print(f"  CRISPR: {crispr_r1}, {crispr_r2}")
    print(f"  RNA-seq: {rnaseq_r1}, {rnaseq_r2}")
    
    # 写入报告文件
    with open(report_file, 'w') as f:
        f.write(f"样本拆分报告\n")
        f.write(f"生成时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"输入文件：{r1_file}, {r2_file}\n")
        f.write(f"\n")
        f.write(f"总 reads 数：{total_count:,}\n")
        f.write(f"CRISPR reads: {crispr_count:,} ({crispr_pct:.2f}%)\n")
        f.write(f"RNA-seq reads: {rnaseq_count:,} ({rnaseq_pct:.2f}%)\n")
        f.write(f"\n")
        f.write(f"输出文件:\n")
        f.write(f"  CRISPR: {crispr_r1}, {crispr_r2}\n")
        f.write(f"  RNA-seq: {rnaseq_r1}, {rnaseq_r2}\n")

def main():
    parser = argparse.ArgumentParser(description='Split mixed library fastq files by sequence feature')
    parser.add_argument('--r1', required=True, help='R1 fastq file')
    parser.add_argument('--r2', required=True, help='R2 fastq file')
    parser.add_argument('--output_prefix', required=True, help='Output file prefix')
    parser.add_argument('--scaffold', default='GTTTTAGAGCTAGAAATAGCAAGTTAAAATAAGGCTAGTCC', 
                       help='CRISPR scaffold sequence')
    parser.add_argument('--report', required=True, help='Report output file')
    
    args = parser.parse_args()
    
    split_fastq(args.r1, args.r2, args.output_prefix, args.scaffold, args.report)

if __name__ == '__main__':
    main()
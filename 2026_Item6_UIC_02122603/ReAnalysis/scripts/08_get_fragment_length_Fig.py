import json
import matplotlib.pyplot as plt
import os
import glob

# 设置路径
# json_dir = "/home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis/processed_fastq"
# output_dir = "/home/gao/projects/2026_Item6_UIC_02122603/ReAnalysis/insert_size_plots"
json_dir = "/home/gao/Dropbox/Quote_02122603_UIC/Data_Analysis/ZG/summary/"
output_dir = "/home/gao/Dropbox/Quote_02122603_UIC/Data_Analysis/ZG/insert_size_plots"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# 查找所有的 fastp json 文件
json_files = glob.glob(os.path.join(json_dir, "*assessment.json"))

def plot_insert_size(json_path):
    sample_name = os.path.basename(json_path).replace("_assessment.json", "")
    print(f"正在处理: {sample_name}")
    
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    # 提取 insert_size 统计数据
    # fastp json 结构: insert_size -> histogram
    if "insert_size" in data and "histogram" in data["insert_size"]:
        hist = data["insert_size"]["histogram"]
        
        # X 轴是索引 (0, 1, 2...), Y 轴是对应的 count
        x = list(range(len(hist)))
        y = hist
        
        plt.figure(figsize=(10, 6), dpi=300)
        # 绘制柱状图，颜色选择专业的科技蓝
        plt.bar(x, y, color='#1f77b4', width=1.0, alpha=0.8)
        
        # 标注 Peak 值（如果有）
        peak = x[y.index(max(y))]
        plt.axvline(peak, color='red', linestyle='--', alpha=0.6, label=f"Peak: {peak}bp")
        
        # 美化图表
        plt.title(f"Insert Size Distribution - {sample_name}", fontsize=15)
        plt.xlabel("Insert Size (bp)", fontsize=12)
        plt.ylabel("Read Count", fontsize=12)
        plt.xlim(0, 300)  # fastp 通常统计到 300 左右
        plt.grid(axis='y', linestyle=':', alpha=0.5)
        plt.legend()
        
        # 保存图片
        plt.savefig(os.path.join(output_dir, f"{sample_name}_insert_size.png"), bbox_inches='tight')
        plt.close()
    else:
        print(f"跳过: {sample_name} (未找到 insert_size 数据)")

# 循环处理
for f in json_files:
    plot_insert_size(f)

print(f"\n所有图片已保存至: {output_dir}")
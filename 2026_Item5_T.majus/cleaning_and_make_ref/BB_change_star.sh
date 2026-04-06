# 进入工作目录
cd /home/gao/projects/2026_Item5_T.majus/scripts

# 终极修复脚本：
# 1. 精准提取 TM ID。
# 2. 补齐 gene_id / transcript_id。
# 3. CDS 行一分为二 (CDS + exon)。
# 4. 强制 Tab 分隔且截断为 9 列。
awk -F'\t' 'BEGIN{OFS="\t"} {
    if ($1 ~ /^#/) {print $0; next}
    
    pos = index($0, "TM")
    if (pos > 0) {
        raw_id_part = substr($0, pos)
        split(raw_id_part, arr, /[ ;" \t]/)
        tid = arr[1]
        gid = tid; sub(/\..*/, "", gid)
        
        # 构造标准属性列
        $9 = "gene_id \"" gid "\"; transcript_id \"" tid "\";"
        
        if ($3 == "transcript") {
            # 仅输出 9 列，剔除尾部垃圾数据
            print $1,$2,$3,$4,$5,$6,$7,$8,$9
        } else if ($3 == "CDS") {
            # 输出标准的 CDS 行
            print $1,$2,$3,$4,$5,$6,$7,$8,$9
            # 关键步：在此生成 exon 行并输出，同样保持 9 列
            $3 = "exon"
            print $1,$2,$3,$4,$5,$6,$7,$8,$9
        }
    }
}' /Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/T_majus.annotation.gtf > T_majus.final.v2.gtf

# 将修正版重命名为最终版
mv T_majus.final.v2.gtf T_majus.final.gtf


# 1. 确认 exon 数量不再为 0
echo "Exon count: $(grep -c -w "exon" T_majus.final.gtf)"

# 2. 确认列数严格为 9
awk -F'\t' '{print NF}' T_majus.final.gtf | sort | uniq -c

# 3. 查看文件大小
ls -lh T_majus.final.gtf
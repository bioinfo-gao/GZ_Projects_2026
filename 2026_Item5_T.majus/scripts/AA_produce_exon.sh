# 进入工作目录
cd /home/gao/projects/2026_Item5_T.majus/scripts

# 终极逻辑：
# 1. 每一行只要包含 "TM" 字符串，我们就处理它。
# 2. 从 "TM" 开始截取，直到遇到第一个分号或空格。
# 3. 补齐 exon 标签。
awk 'BEGIN{OFS="\t"} {
    if ($1 ~ /^#/) {print $0; next}
    
    # 查找 TM 字符串出现的位置
    pos = index($0, "TM")
    if (pos > 0) {
        # 截取从 TM 开始的剩余字符串
        raw_id_part = substr($0, pos)
        # 提取 ID（截取到第一个分号、空格或引号前）
        split(raw_id_part, arr, /[ ;" \t]/)
        tid = arr[1]
        
        # 提取 gene_id (去掉小数点)
        gid = tid
        dot_pos = index(gid, ".")
        if (dot_pos > 0) {
            gid = substr(gid, 1, dot_pos - 1)
        }

        # 重新构造标准第九列
        new_attr = "gene_id \"" gid "\"; transcript_id \"" tid "\";"
        
        # 重新赋值第九列及其后的所有列（合并剩余部分）
        $9 = new_attr
        
        if ($3 == "transcript") {
            print $0
        } else if ($3 == "CDS") {
            print $0
            # 伪造关键的 exon 行
            $3 = "exon"
            print $0
        }
    }
}' /Work_bio/references/Tropaeolum_majus/T_majus_v1/schmidt_et_al_2024/T_majus.annotation.gtf > T_majus.standardized.gtf


# 验证是否有内容输出
grep -w "exon" T_majus.standardized.gtf | head -n 4
grep -E "transcript|exon" T_majus.standardized.gtf | head -n 4

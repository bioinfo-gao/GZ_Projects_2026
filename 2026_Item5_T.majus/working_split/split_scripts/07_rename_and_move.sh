#!/bin/bash
#https://chatgpt.com/c/69cbea82-9f0c-8332-a951-3dacee12a885
# 根目录

set -euo pipefail   # 出错立即停止（非常重要）

BASE_DIR="/home/gao/projects/2026_Item5_T.majus/working_split"

SAMPLES=("WhS4_1" "WhS4_4" "WTS4_1" "WTS4_2" "WTS4_5")

# ✅ 检查 BASE_DIR 是否存在
if [[ ! -d "$BASE_DIR" ]]; then
    echo "ERROR: BASE_DIR does not exist: $BASE_DIR"
    exit 1
fi

for sample in "${SAMPLES[@]}"; do

    SPLIT_DIR="${BASE_DIR}/${sample}/split_results"

    # ✅ 检查目录存在
    if [[ ! -d "$SPLIT_DIR" ]]; then
        echo "WARNING: Skip missing dir $SPLIT_DIR"
        continue
    fi

    echo "Processing: $SPLIT_DIR"

    # 防止 *.fq.gz 没匹配时变成字面量
    shopt -s nullglob

    files=("$SPLIT_DIR"/*.fq.gz)

    # 如果没有文件，跳过
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No fq.gz files in $SPLIT_DIR"
        continue
    fi

    # 1️⃣ rename
    for file in "${files[@]}"; do
        filename=$(basename "$file")

        if [[ ! "$filename" =~ ^Real_ ]]; then
            newfile="$SPLIT_DIR/Real_$filename"
            mv "$file" "$newfile"
            echo "Renamed: $filename -> Real_$filename"
        fi
    done

    # 2️⃣ 分类
    for file in "$SPLIT_DIR"/Real_*.fq.gz; do
        filename=$(basename "$file")

        sample_name=$(echo "$filename" | sed -E 's/_R[12]\.fq\.gz$//')

        target_dir="$SPLIT_DIR/$sample_name"
        mkdir -p "$target_dir"

        mv "$file" "$target_dir/"

        echo "Moved: $filename -> $target_dir/"
    done

    echo "Done: $sample"
    echo "-----------------------------"

done

echo "All done."
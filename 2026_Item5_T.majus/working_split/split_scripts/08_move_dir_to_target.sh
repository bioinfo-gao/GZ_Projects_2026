#!/bin/bash

set -euo pipefail

BASE_DIR="/home/gao/projects/2026_Item5_T.majus/working_split"

DEST_MAIN="/home/gao/Dropbox/Quote_03062602"
DEST_YF="/Work_bio/dropbox/Dropbox_Data/YF_Data/01.RawData"

SAMPLES=("WhS4_1" "WhS4_4" "WTS4_1" "WTS4_2" "WTS4_5")

# 创建目标目录（如果不存在）
mkdir -p "$DEST_MAIN"
mkdir -p "$DEST_YF"

for sample in "${SAMPLES[@]}"; do

    SPLIT_DIR="${BASE_DIR}/${sample}/split_results"

    if [[ ! -d "$SPLIT_DIR" ]]; then
        echo "Skip missing: $SPLIT_DIR"
        continue
    fi

    echo "Processing: $SPLIT_DIR"

    shopt -s nullglob

    # 遍历所有 Real_* 子目录
    for dir in "$SPLIT_DIR"/Real_*; do

        # 如果不是目录就跳过
        [[ -d "$dir" ]] || continue

        dirname=$(basename "$dir")

        # 👉 分类判断
        if [[ "$dirname" =~ ^Real_Wh ]] || [[ "$dirname" =~ ^Real_WT ]]; then

            echo "Move to MAIN: $dirname"
            mv "$dir" "$DEST_MAIN/"

        elif [[ "$dirname" =~ ^Real_YF ]]; then

            echo "Move to YF: $dirname"
            mv "$dir" "$DEST_YF/"

        else
            echo "Skip unknown: $dirname"
        fi

    done

    echo "Done: $sample"
    echo "------------------------"

done

echo "All moves completed."
#!/bin/bash
# 使用 find 命令配合 -depth 参数。这种方法的精妙之处在于它会先处理子文件，再处理父目录，从而避免因目录名先改变而导致找不到子文件的错误。
# 定义目标根目录
TARGET_DIR="/home/gao/Dropbox/Quote_03062602"

echo "开始清理前缀 'Real_' ..."

# 使用 -depth 确保先重命名文件，再重命名文件夹
# 逻辑：
# 1. 找到所有以 Real_ 开头的文件和文件夹
# 2. 获取其路径(dirname)和原始名称(basename)
# 3. 使用 sed 去掉名称开头的 Real_
# 4. 执行 mv 重命名

find "$TARGET_DIR" -depth -name "Real_*" | while read -r old_path; do
    # 获取目录路径
    dir=$(dirname "$old_path")
    # 获取原始文件名
    base=$(basename "$old_path")
    # 去掉 Real_ 前缀
    new_base=$(echo "$base" | sed 's/^Real_//')
    
    # 执行重命名
    mv "$old_path" "$dir/$new_base"
    
    echo "已重命名: $base -> $new_base"
done

echo "清理完成！"
#!/bin/bash
# verify_r_installation.sh

mamba activate DE_R45

echo "=========================================="
echo "验证 R 安装"
echo "=========================================="

# 检查 R 路径
echo "R 路径:"
which R
which Rscript

# 检查 R 版本
echo ""
echo "R 版本:"
R --version 2>&1 | head -3

# 检查库路径
echo ""
echo "R 库路径:"
Rscript -e ".libPaths()"

# 测试基本功能
echo ""
echo "测试 R 基本功能:"
Rscript -e "
cat('R 版本:', R.version.string, '\n')
cat('R 路径:', R.home(), '\n')
cat('✓ R 安装验证成功\n')
"

echo ""
echo "=========================================="



#!/bin/bash
# verify_all_r_packages.sh

mamba activate DE_R45

echo "=========================================="
echo "验证所有 R 包"
echo "=========================================="

Rscript -e "
packages <- c(
    'jsonlite', 'ggplot2', 'pheatmap', 'dplyr', 'readr',
    'tximport', 'DESeq2', 'rmarkdown', 'knitr', 'patchwork', 'apeglm'
)

cat('R 版本:', R.version.string, '\n\n')

installed <- 0
failed <- 0

for (pkg in packages) {
    if (requireNamespace(pkg, quietly=TRUE)) {
        cat(sprintf('✓ %-15s %s\n', pkg, packageVersion(pkg)))
        installed <- installed + 1
    } else {
        cat(sprintf('✗ %-15s 未安装\n', pkg))
        failed <- failed + 1
    }
}

cat(sprintf('\n成功：%d/%d\n', installed, length(packages)))
"

echo ""
echo "=========================================="
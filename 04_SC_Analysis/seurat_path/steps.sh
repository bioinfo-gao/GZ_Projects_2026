mamba create -n seurat_env -c conda-forge r-base=4.3 r-seurat r-languageserver r-httpgd r-patchwork r-dplyr -y
mamba activate seurat_env


# 科研里更稳定的做法是：

# ❗ 让 R 自己管理包

# 不要用 conda 管 R 包

# 建议：

# conda create -n seurat_env r-base=4.3

# 然后在 R 里：

# install.packages("Seurat")

# 不要用：

# conda install r-seurat

# 那会锁死依赖版本。

# 🎯 单细胞最佳稳定版本（2026 推荐）
# 软件	推荐版本
# R	4.3.x
# Bioconductor	3.18
# Seurat	5.x

getwd()

list.files("data")

更直接的方法（推荐）

按：

Ctrl + Shift + P

输入：

Preferences: Open Settings (JSON)

然后添加：

{
    "r.source.moveCursor": true
}

运行后自动跳到下一行”

再加一个设置：

打开：

Ctrl + ,

搜索：

r.source.moveCursor

勾选 ✅

或者在 settings.json 里加：

"r.source.moveCursor": true
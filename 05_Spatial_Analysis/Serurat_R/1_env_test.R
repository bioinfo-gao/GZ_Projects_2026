# # 创建环境，包含 R 基础包和 VS Code 绘图支持
# micromamba create -n spatial_R_env r-base=4.4 r-essentials r-reticulate r-httpgd r-languageserver -c conda-forge -y
# # 激活环境
# micromamba activate spatial_R_env

getwd()
R.version.string

# > getwd()
# [1] "/home/zhen"
# > R.version.string
# [1] "R version 4.4.3 (2025-02-28)

# 设置镜像
#options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
# 安装基础包
install.packages(c("BiocManager", "remotes", "tidyverse", "httpgd"))

# 安装 Seurat v5 (空间分析旗舰)
# Seurat v5 的矩阵计算可以极大地节省内存
#install.packages("Seurat")
# 方案一（最干净稳定）：直接用 conda 安装 Seurat
# conda activate spatial_R
# conda install -c conda-forge r-seurat

# 安装 Bioconductor 核心空间包
BiocManager::install(c("BayesSpace", "Voyager", "SpatialExperiment", "scuttle"))
# 看起来路径是对的，安装到minforge3里的 spatial_R 里面去了
# * installing *source* package ‘RcppTOML’ ...
# ** package ‘RcppTOML’ successfully unpacked and MD5 sums checked
# ** using staged installation
# ** libs
# sh: 1: x86_64-conda-linux-gnu-c++: not found
# x86_64-conda-linux-gnu-c++ -std=gnu++17 -I"/home/zhen/miniforge3/envs/spatial_R/lib/R/include" -DNDEBUG -I../inst/include -DTOML_ENABLE_FLOAT16=0 -I'/home/zhen/miniforge3/envs/spatial_R/lib/R/library/Rcpp/include' -DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem /home/zhen/miniforge3/envs/spatial_R/include -I/home/zhen/miniforge3/envs/spatial_R/incl


# 安装 BPCells (这是您 9.7G 内存的救星，它将数据存在硬盘而非内存)
remotes::install_github("bnaras/BPCells")

# 安装 Giotto (另一个强大的空间框架)
# Giotto 提供了非常棒的 3D 渲染和交互功能
remotes::install_github("Giotto-Package/Giotto")
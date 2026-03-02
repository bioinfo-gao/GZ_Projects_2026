# # 确保在 spatial_R 环境下运行
# if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
# remotes::install_github("bnaras/BPCells")
# 
# # 2. 安装正确的 BPCells 仓库 (这是目前最常用的版本)
# remotes::install_github("bnjmn/BPCells")
# remotes::install_github("bnprks/BPCells/r")
# 
# 
# 
# # 1. 告诉 R 优先从 BPCells 官方的二进制仓库下载
# # 我们同时加入 Satija Lab (Seurat作者) 的源作为备份
# options(repos = c(
#   bnaras = 'https://bnaras.r-universe.dev',
#   satijalab = 'https://satijalab.r-universe.dev',
#   CRAN = 'https://mirror.las.iastate.edu/CRAN/'
# ))
# 
# # 2. 安装 BPCells (会自动寻找预编译好的二进制文件)
# install.packages("BPCells")



# https://bnprks.r-universe.dev/BPCells 
install.packages('BPCells', repos = c('https://bnprks.r-universe.dev', 'https://cloud.r-project.org'))

# giotto single cell cannot install yet
# https://www.youtube.com/watch?v=oOiEK0q4dYA

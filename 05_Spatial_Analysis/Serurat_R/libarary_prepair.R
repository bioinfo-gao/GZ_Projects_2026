# 先安装 remotes（比 devtools 更轻量）
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")

# 1. 验证编译器是否到位（如果不报错输出路径，说明修好了）
system("which x86_64-conda-linux-gnu-cc")

# 2. 针对 9.7GB 内存的严苛限制（必须执行）
# 即使有了编译器，多核编译也会爆内存。强制单核安装：
options(Ncpus = 1)


# 1. 告诉 R 优先从 Giotto 官方的二进制仓库下载
options(repos = c(
  drieslab = 'https://drieslab.r-universe.dev',
  CRAN = 'https://cran.csail.mit.edu/CRAN/'
  # CRAN = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/'
))

# 2. 针对 9.7G 内存的保护：禁用多线程解压
options(Ncpus = 1)

install.packages(c("GiottoClass", "GiottoUtils", "GiottoVisuals"))

# 进入你之前下载 Giotto 的目录
cd ~/GZ_Projects_2026/download

# 再次执行安装
R CMD INSTALL Giotto

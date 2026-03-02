library(Seurat)
library(reticulate)

# 1. 强制连接您的 GPU 环境
#use_python("/home/zhen/micromamba/envs/spatial_gpu_final/bin/python", required = TRUE)
# 使用您刚才 ll 确认过的真实路径
use_python("/home/zhen/miniforge3/envs/spatial_gpu_final/bin/python", required = TRUE)

# 验证是否识别到了 RTX 3060
py_config()
# 看到 "CUDA: True" 和 "RTX 3060" 时，说明您已经拥有了“R壳GPU芯”的强大环境
# 导入 Python 的 torch 模块
torch <- import("torch")

# 检查 CUDA 是否可用（应该返回 TRUE）
torch$cuda$is_available()

# 确认识别到的显卡型号
if(torch$cuda$is_available()){
  print(paste("成功识别显卡:", torch$cuda$get_device_name(0L)))
}
# > torch <- import("torch")
# /home/zhen/miniforge3/envs/spatial_R/lib/R/library/reticulate/python/rpytools/loader.py:120: FutureWarning: The pynvml package is deprecated. Please install nvidia-ml-py instead. If you did not install pynvml directly, please report this to the maintainers of the package that installed pynvml for you.
# return _find_and_load(name, import_)
# > # 检查 CUDA 是否可用（应该返回 TRUE）
#   > torch$cuda$is_available()
# [1] TRUE
# > # 确认识别到的显卡型号
#   > if(torch$cuda$is_available()){
#     +   print(paste("成功识别显卡:", torch$cuda$get_device_name(0L)))
#     + }
# [1] "成功识别显卡: NVIDIA GeForce RTX 3060 Laptop GPU"


> 
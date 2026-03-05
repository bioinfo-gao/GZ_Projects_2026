library(reticulate)

# 使用您刚才 ll 确认过的真实路径
use_python(
  "/home/zhen/miniforge3/envs/spatial_gpu_final/bin/python",
  required = TRUE
)

# 验证是否识别到了 RTX 3060
py_config()
# python:         /home/zhen/miniforge3/envs/spatial_gpu_final/bin/python
# libpython:      /home/zhen/miniforge3/envs/spatial_gpu_final/lib/libpython3.11.so
# pythonhome:     /home/zhen/miniforge3/envs/spatial_gpu_final:/home/zhen/miniforge3/envs/spatial_gpu_final
# version:        3.11.14 | packaged by conda-forge | (main, Jan 26 2026, 23:48:32) [GCC 14.3.0]
# numpy:          /home/zhen/miniforge3/envs/spatial_gpu_final/lib/python3.11/site-packages/numpy
# numpy_version:  1.26.4
# NOTE: Python version was forced by use_python() function

# 如何在 VS Code 中永久固定这个路径？
# 为了防止下次重启还要手动输入长路径，建议修改 VS Code 的 Remote Settings (JSON)。
# 按 Ctrl + Shift + P -> Open Remote Settings (JSON) (WSL: Ubuntu)。
# 确保您的环境配置如下（注意 miniforge3）：

# {
#     "r.rterm.linux": "/home/zhen/miniforge3/envs/spatial_R/bin/R",
#     "r.plot.useHttpgd": true,
#     "r.alwaysUseActiveTerminal": true,
#     "r.reticulate.python": "/home/zhen/miniforge3/envs/spatial_gpu_final/bin/python"
# }
# 添加最后一行 r.reticulate.python 后，VS Code 里的 R 扩展会自动帮你寻找 GPU 环境。
# 4. 终极验证：确认 RTX 3060 是否“上线”
# 运行以下 R 代码，如果返回 TRUE，说明您的 R 已经成功借到了显卡的算力：


library(reticulate)
torch <- import("torch")
torch$cuda$is_available() 
# 预期返回: [1] TRUE DONE !
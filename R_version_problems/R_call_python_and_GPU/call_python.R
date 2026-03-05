library(reticulate)

# 使用您刚才 ll 确认过的真实路径
use_python(
  "/home/zhen/miniforge3/envs/spatial_gpu_final/bin/python",
  required = TRUE
)

# 验证是否识别到了 RTX 3060
py_config()

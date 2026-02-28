(base) zhen@DESKTOP-C8OKE65:~/GZ_Projects_2026$ nvidia-smi # Fri Feb 27 2026       
# | NVIDIA-SMI 560.35.04              Driver Version: 561.17         CUDA Version: 12.6     |
#第二步：重新创建基础环境 (只装非 GPU 包)
# 我们只用 Mamba 装最基础的 Python 和生信工具：
mamba create -n spatial_Scanpy_Squidpy_GPU python=3.12 scanpy ipykernel pandas matplotlib -c conda-forge -c bioconda -y
# GPU 版 PyTorch（关键）即 pytorch-cuda， 而 pytorch 是 CPU 版本的 PyTorch
# 针对 RTX 3060，安装支持 CUDA 12.1 的版本
# 激活环境后，使用 PyTorch 官方的 Pip 链接。这样它会下载自带 libcublas 的安装包，不与系统或其他 Mamba 包冲突。
mamba activate spatial_Scanpy_Squidpy_GPU

pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# 第 5 步：测试 GPU: 
python
import torch
print(torch.cuda.is_available())
print(torch.cuda.get_device_name(0))
# True
# NVIDIA GeForce RTX 3060 # 说明 GPU 成功 🎉
# ✅ 第 6 步（可选但推荐）：安装 scvi-tools
# 如果你做空间 domain / 深度模型：
pip install scvi-tools

# 安装 Squidpy（空间分析工具）
pip install squidpy #-i https://pypi.tuna.tsinghua.edu.cn/simple
# 安装 OmicVerse
pip install omicverse 
# 安装常用的 zarr 补丁（防止之前讨论过的报错）
pip install "zarr<3"
# 安装 PyG (图神经网络支持)
pip install torch-geometric # #pip install torch-geometric -i https://pypi.tuna.tsinghua.edu.cn/simple


验证环境
# 请在你的 WSL 终端（确保已 mamba activate scRNA_gpu）中运行以下测试，确认 RTX 3060 显卡驱动已打通：

python -c "import scanpy as sc; import omicverse as ov; import torch; print('Scanpy:', sc.__version__); print('OmicVerse:', ov.__version__); print('GPU可用:', torch.cuda.is_available())"
# Scanpy: 1.11.5
# OmicVerse: 1.7.9
# GPU可用: True

# 这是 Pip 在处理复杂的生信包依赖时遇到了“逻辑死循环”。squidpy 依赖于 scanpy，
# 而 scanpy 又深度依赖 anndata、numpy 和 numba。
# 当这些包的版本要求互相冲突（例如一个要求 numpy 2.0，另一个要求 numpy 1.x）时，
# Pip 的解析器会陷入无限递归，最终报出 resolution-too-deep。

# 核心方案：手动限定“守门员”包的版本
# 这个命令通过手动限制 numpy 和 zarr 的版本，直接砍掉了 90% 不兼容的搜索路径，让 Pip 能快速找到解：
# 2. 使用约束参数安装 Squidpy
pip install "squidpy>=1.6" "numpy<2" "zarr<3" "anndata>=0.10"

# 现在大多数科研服务器都是：
# conda 管理科学计算栈
# pip 管理 torch / tensorflow
# 混用是常态，而且更稳定。
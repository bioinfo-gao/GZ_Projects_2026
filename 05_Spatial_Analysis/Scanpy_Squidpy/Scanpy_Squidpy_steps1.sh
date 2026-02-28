mamba activate base
mamba env remove -n spatial_Scanpy_Squidpy_GPU -y
mamba env list

# 显式指定 setuptools 保证 pkg_resources 存在
mamba create -n spatial_gpu_final python=3.11 pip "setuptools<70" wheel -c conda-forge -y

mamba activate spatial_gpu_final

# 安装 uv 作为加速器
pip install uv

# 安装 GPU 版 Torch (RTX 3060 专用)
uv pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# 安装空间分析全家桶（包含 scanpy, squidpy 和 omicverse）
# 加上 numpy<2 是为了防止最新的 numpy 2.0 毁掉整个环境
# 4. 一次性安装生信核心包（由 uv 负责闪电解算）
# 严格限制 numpy 和 zarr，彻底杜绝 pkg_resources 消失的问题
uv pip install "scanpy>=1.10" "squidpy>=1.6" omicverse "numpy<2" "zarr<3" "anndata>=0.10"

# 5. 验证 pkg_resources（核心检查点）
python -c "import pkg_resources; print('pkg_resources 已经成功找回！')"
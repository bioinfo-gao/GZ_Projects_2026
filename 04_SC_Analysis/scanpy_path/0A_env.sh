# 1. 删除现有的 scanpy_anal 环境
conda env remove -n scanpy_analy

# 2. 创建新环境并一次性安装所有核心包（包括 omicverse）
mamba create -n scanpy_ana -c conda-forge -c bioconda \
    python=3.9 \
    scanpy anndata pandas numpy scikit-learn \
    matplotlib seaborn numba jupyterlab omicverse -y

# 3. 激活环境并安装 ipykernel
conda activate scanpy_ana
pip install ipykernel

# 4. 注册 Jupyter kernel
python -m ipykernel install --user --name scanpy_ana --display-name "Python (scanpy_ana)"
# 进入我们刚刚建好的空间分析目录
mkdir -p 06_Visium_Analysis/mouse_brain_data
cd 06_Visium_Analysis/mouse_brain_data

# 1. 下载空间 H&E 图像及对齐文件压缩包
wget https://cf.10xgenomics.com/samples/spatial-exp/1.1.0/V1_Adult_Mouse_Brain/V1_Adult_Mouse_Brain_spatial.tar.gz

# 2. 下载对应的基因表达矩阵文件 (.h5)
wget https://cf.10xgenomics.com/samples/spatial-exp/1.1.0/V1_Adult_Mouse_Brain/V1_Adult_Mouse_Brain_filtered_feature_bc_matrix.h5

# 3. 解压图像文件夹 (会生成一个 spatial/ 目录)
tar -xzvf V1_Adult_Mouse_Brain_spatial.tar.gz

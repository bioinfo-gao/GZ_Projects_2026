 source /home/songz/miniconda3/etc/profile.d/conda.sh && conda create -n GZ-conda -c bioconda samtools fastqc multiqc star salmon trimmomatic -y

pkill -u songz -f conda

 # 1. 安装mamba
source /home/songz/miniconda3/etc/profile.d/conda.sh && conda install mamba -n base -c conda-forge

# 2. 使用mamba创建环境
source /home/songz/miniconda3/etc/profile.d/conda.sh && mamba create -n GZ-conda -c bioconda samtools fastqc multiqc star salmon trimmomatic -y
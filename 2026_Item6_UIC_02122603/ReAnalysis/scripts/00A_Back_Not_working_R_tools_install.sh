# 激活环境
mamba activate DE_R45

# 安装 R 4.5（指定版本）
mamba install -c conda-forge \
    r-base=4.5 \
    r-rcpp \
    -y


# 安装 CRAN 包
mamba install -c conda-forge \
    r-jsonlite \
    r-ggplot2 \
    r-pheatmap \
    r-dplyr \
    r-readr \
    r-tidyverse \
    r-rmarkdown \
    r-knitr \
    r-patchwork \
    -y


# 安装 Bioconductor 包（正确命名）
mamba install -c bioconda -c conda-forge \
    bioconductor-tximport \
    bioconductor-deseq2 \
    bioconductor-apeglm \
    -y
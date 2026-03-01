mamba create -n spatial_R \
    r-base=4.4 \
    r-seurat r-httpgd r-languageserver r-reticulate \
    r-patchwork r-ggplot2 r-dplyr r-devtools \
    r-terra r-sf r-magick r-rcpp r-rcpparmadillo \
    gxx_linux-64 gcc_linux-64 gfortran_linux-64 \
    -c conda-forge -c bioconda -y

https://posit.co/download/rstudio-server/
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2026.01.1-403-amd64.deb
sudo gdebi rstudio-server-2026.01.1-403-amd64.deb

sudo vim /etc/rstudio/rserver.conf # 修改以下两行，指向你 mamba 环境里的 R 路径
# Server Configuration File
rsession-which-r=/home/zhen/miniforge3/envs/spatial_R/bin/R
rsession-ld-library-path=/home/zhen/miniforge3/envs/spatial_R/lib

sudo rstudio-server verify-installation
sudo rstudio-server restart

http://localhost:8787/ #可从windows直接访问wsl，输入用户名和密码登录，账号密码是你wsl的账号密码，登录后就可以在rstudio里使用mamba环境里的R了。

Ctrl + enter # run a line 
# 在 Rstudio 里运行代码，测试一下是否成功调用了 mamba 环境里的 R

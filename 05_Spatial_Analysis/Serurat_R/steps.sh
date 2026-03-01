mamba create -n spatial_R \
    r-base=4.4 \
    r-essentials \
    r-devtools \
    r-tidyverse \
    -c conda-forge -y

mamba activate spatial_R    
R --version

https://posit.co/download/rstudio-server/
  174  sudo apt-get install gdebi-core
  175  wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2026.01.1-403-amd64.deb
  176  sudo gdebi rstudio-server-2026.01.1-403-amd64.deb

sudo vim /etc/rstudio/rserver.conf
rsession-which-r=/home/zhen/miniforge3/envs/spatial_R/bin/R
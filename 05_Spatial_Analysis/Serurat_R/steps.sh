mamba create -n spatial_R \
    r-base=4.4 \
    r-essentials \
    r-devtools \
    r-tidyverse \
    -c conda-forge -y

mamba activate spatial_R    
R --version
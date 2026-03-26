which R
# (base) [12:22:12] [/home/gao]:
# gao@us1 $  # means no R installed at all 

# 为了确保在安装 tidyverse 和 janitor 时 R 版本绝不动摇，您必须使用**“强制版本锁死”**安装指令。
# in mamba env base 
# mamba install r-tidyverse r-janitor r-base=4.3.3 -c conda-forge --strict-channel-priority -y

which R
R --version
#R version 4.3.3 (2024-02-29) -- "Angel Food Cake"

# in mamba env  regular_bioinfo 
mamba activate regular_bioinfo 
# mamba install r-tidyverse r-janitor r-base=4.5.3 -c conda-forge --strict-channel-priority -y
which R
R --version
# R version 4.5.3 (2026-03-11) -- "Reassured Reassurer"

# in mamba env DE_R45 
mamba activate DE_R45 
# mamba install r-tidyverse r-janitor r-base=4.5.3 -c conda-forge --strict-channel-priority -y
which R
R --version
# R version 4.5.3 (2026-03-11) -- "Reassured Reassurer"

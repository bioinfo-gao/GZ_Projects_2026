# 在生信环境管理中，防止 Mamba 自动升级 R 版本是维持环境稳定的最高优先级任务。

# 为了确保在安装 tidyverse 和 janitor 时 R 版本绝不动摇，您必须使用**“强制版本锁死”**安装指令。
# mamba install r-tidyverse r-janitor r-base=4.3.3 -c conda-forge --strict-channel-priority -y

# 2. 为什么这样写能保证 R 不变？
# r-base=4.3.2：这是向 Mamba 下达的“死命令”。它告诉解算器（Solver）：“你寻找的任何依赖方案，都必须建立在 R 4.3.2 的基础之上。如果为了装 tidyverse 必须升级 R，那就报错，不准执行。”
# --strict-channel-priority：强制只从 conda-forge 获取二进制包。这能防止 Mamba 跑到别的频道去抓一个“看起来更先进”但会破坏版本的 R 包。

# install.packages("tidyverse", dependencies = TRUE)
# install.packages("janitor", dependencies = TRUE)
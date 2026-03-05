
# 在生信环境管理中，防止 Mamba 自动升级 R 版本是维持环境稳定的最高优先级任务。

# 为了确保在安装 tidyverse 和 janitor 时 R 版本绝不动摇，您必须使用**“强制版本锁死”**安装指令。
# mamba install r-tidyverse r-janitor r-base=4.3.3 -c conda-forge --strict-channel-priority -y

# 2. 为什么这样写能保证 R 不变？
# r-base=4.3.2：这是向 Mamba 下达的“死命令”。它告诉解算器（Solver）：“你寻找的任何依赖方案，都必须建立在 R 4.3.2 的基础之上。如果为了装 tidyverse 必须升级 R，那就报错，不准执行。”
# --strict-channel-priority：强制只从 conda-forge 获取二进制包。这能防止 Mamba 跑到别的频道去抓一个“看起来更先进”但会破坏版本的 R 包。

# install.packages("tidyverse", dependencies = TRUE)
# install.packages("janitor", dependencies = TRUE)

library(tidyverse)
library(janitor)
library(dplyr)
library(dplyr)

getwd()
setwd("/home/zhen/GZ_Projects_2026/04_SC_Analysis/seurat_path/Exploratory_Data_Analysis_with_R_in_Positron/")
#hw_raw <- read.csv("data/hw.csv")
hw_raw <- read.csv("HW_R.csv")


#data prep
colnames(hw_raw)
hw <- hw_raw |>   # the old version of pipe is %>%
  clean_names() |> # Lowercase Conversion: By running clean_names(), the original Female column no longer exists.
  mutate(deadline = if_else(midnight_deadline == 1, "Midnight", "4pm")) |>
  mutate(
    # Use lowercase 'female' as per clean_names output
    female = case_when(
      female == "Male" ~ 0,
      female == "Female" ~ 1
    ) # 缺少默认条件：`case_when` 如果没有匹配任何条件且未设置默认值，会返回 NA。虽然通常不报错，但建议添加 `TRUE` 条件以防意外。
  ) |>
  dplyr::relocate(q3_deadline_stress, .after = deadline) |> filter(!is.na(q3_deadline_stress))


hw |> group_by(deadline) |> summarise(mean_stress = mean(q3_deadline_stress))


# ?clean_names `help("clean_names", package = "janitor")  使用通用帮助命令


# 检查每组的数据量
table(hw$deadline)

# 或者使用 dplyr 计数
hw |> count(deadline)

# 两个四分位数没有显示出来，具体请看
ggplot(hw, aes(x = deadline, y = q3_deadline_stress)) +
  geom_jitter(alpha = 0.5) + 
  geom_boxplot() 

ggplot(hw, aes(x = deadline, y = q3_deadline_stress)) +
  geom_boxplot(outlier.shape = NA) +  # 先画箱线图，隐藏默认异常点
  geom_jitter(alpha = 0.5, width = 0.2) # 后画散点图，增加少量宽度抖动


# 绘图
ggplot(hw, aes(x = deadline, y = q3_deadline_stress)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(alpha = 0.5, width = 0.2)

ggplot(hw, aes(x = deadline, fill = as.factor( q3_deadline_stress)) ) +
geom_bar()


# 确保 deadline 为因子，固定顺序
hw <- hw |> mutate(deadline = factor(deadline, levels = c("4pm", "Midnight")))

# 再次检查数据量
hw |> count(deadline)

# 绘图
ggplot(hw, aes(x = deadline, y = q3_deadline_stress)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(alpha = 0.5, width = 0.2)


head(hw)
colnames(hw)

hw[, "q3_deadline_stress"]

hw |> 
  group_by(deadline) |> 
  summarise(
    total_rows = n(), 
    valid_stress = sum(!is.na(q3_deadline_stress)), 
    na_stress = sum(is.na(q3_deadline_stress))
  )

hw[, c( "id",           "q3_deadline_stress",      "hw_minutes")]

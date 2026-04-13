# R Statistics Essential Training
# Ex05_03
# Merging files

# 原始数据来自这个数据集
# Load data
?longley
data(longley)

让我搜索 longley 数据集的详细信息。



```toolCall::search_web::call_98b213cfdb9f4e279ac1d29b::INIT
```

根据搜索结果，我来为你详细介绍 **longley** 数据集：

# ## Longley 数据集介绍

# **来源：** J.W. Longley (1967) 发表在《Journal of the American Statistical Association》上的论文

# **用途：** 这是一个经典的宏观经济数据集，因存在**严重的多重共线性问题**，常被用来检验回归算法和计算机的计算精度。

# **数据范围：** 1947年至1962年，共16年的年度观测数据

# **包含7个变量（均为数值型）：**

# | 变量名 | 英文全称 | 中文含义 | 说明 |
# |--------|---------|---------|------|
# | **GNP.deflator** | GNP implicit price deflator | GNP平减指数 | 国民生产总值的价格指数（以1954年=100为基准） |
# | **GNP** | Gross National Product | 国民生产总值 | 以百万美元为单位 |
# | **Unemployed** | Number of unemployed | 失业人数 | 以千人为单位 |
# | **Armed.Forces** | Number in armed forces | 武装部队人数 | 军队人员数量（千人） |
# | **Population** | Noninstitutionalized population ≥ 14 years | 非机构化人口（≥14岁） | 14岁及以上的非机构人口（千人） |
# | **Year** | Year | 年份 | 时间变量（1947-1962） |
# | **Employed** | Number of people employed | 就业人数 | 受雇人数（千人） |

# **重要特征：**
# - 该数据集存在**严重的多重共线性**（条件数 kappa ≈ 14550 >> 1000）
# - 变量 GNP.deflator、GNP、Population、Employed 与 Year 的趋势相近
# - 常用于演示多元线性回归中的共线性问题
# - 经典回归模型：`lm(Employed ~ .)` 用于预测就业人数

# 这个数据集在统计学教学中非常重要，用来说明当自变量之间高度相关时，回归系数的估计会变得不稳定。

# Split up longley
a1 <- longley[1:14, 1:6]  # Starting data
a2 <- longley[1:14, 6:7]  # New column to add (with "Year" to match)
b <- longley[15:16, ]     # New rows to add

# Save 上面生成的数据 data
# write.table(a1, "~/Desktop/R/longley.a1.txt", sep="\t")
# write.table(a2, "~/Desktop/R/longley.a2.txt", sep="\t")
# write.table(b, "~/Desktop/R/longley.b.txt", sep="\t")
write.table(a1, "/home/gao/projects/Utilities/R/2026_Tested_Versions/Ch05/05_03/longley.a1.txt", sep="\t")
write.table(a2, "/home/gao/projects/Utilities/R/2026_Tested_Versions/Ch05/05_03/longley.a2.txt", sep="\t")
write.table(b,  "/home/gao/projects/Utilities/R/2026_Tested_Versions/Ch05/05_03/longley.b.txt",  sep="\t")

rm(list=ls()) # Clear out everything to start fresh

# Import data
# a1t <- read.table("~/Desktop/R/longley.a1.txt", sep="\t")
# a2t <- read.table("~/Desktop/R/longley.a2.txt", sep="\t")
a1t <- read.table("/home/gao/projects/Utilities/R/2026_Tested_Versions/Ch05/05_03/longley.a1.txt", sep="\t")
a2t <- read.table("/home/gao/projects/Utilities/R/2026_Tested_Versions/Ch05/05_03/longley.a2.txt", sep="\t")

a1t
a2t

# Take early years (a1t) and add columns (a2t)
# Must specify variable to match cases
a.1.2 <- merge(a1t, a2t, by = "Year")  # Merge two data frames
a.1.2  # Check results

# Add two more cases at bottom
b <- read.table("~/Desktop/R/longley.b.txt", sep="\t")
all.data <- rbind(a.1.2, b)  # "Row Bind"
all.data  # Check data
row.names(all.data) <- NULL  # Reset row names
all.data  # Check data

rm(list=ls())  # Clean up

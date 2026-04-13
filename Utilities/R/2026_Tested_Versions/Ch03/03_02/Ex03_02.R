# R Statistics Essential Training
# Ex03_02
# Calculating descriptives

# LOAD DATASET
require("datasets")
?cars
cars
str(cars)
data(cars)

# CALCULATE DESCRIPTIVES
summary(cars$speed)  # Summary for one variable
summary(cars)  # Summary for entire table

# Tukey's five-number summary: minimum, lower-hinge,
# median, upper-hinge, maximum. No labels.
fivenum(cars$speed)

# Boxplot stats: hinges, n, CI, outliers
boxplot.stats(cars$speed)

# 获取 R 可执行文件的完整绝对路径
file.path(R.home("bin"), "R")
# or
R.home()
# 或者
Sys.getenv("R_HOME")
#
.libPaths() # 查看R加载包的路径  # << ============== base env 的 path 

# ALTERNATIVE DESCRIPTIVES
# From the package "psych"
help(package = "psych")
install.packages("psych")
require("psych")
describe(cars) # 描述性统计  # <<<======================= also see Ex01_04, Ex04_03

# Clean up
detach("package:psych", unload=TRUE)
rm(list = ls())
# 按 deadline 分组计算四分位数
hw |>
  group_by(deadline) |>
  summarise(
    n = n(),
    min = min(q3_deadline_stress),
    Q1 = quantile(q3_deadline_stress, 0.25),
    median = quantile(q3_deadline_stress, 0.50),
    Q3 = quantile(q3_deadline_stress, 0.75),
    max = max(q3_deadline_stress),
    IQR = IQR(q3_deadline_stress),
    mean = mean(q3_deadline_stress),
    sd = sd(q3_deadline_stress)
  )

# 1. 重新准备数据（确保环境最新）
hw_plot <- hw_raw |>
  clean_names() |>
  mutate(deadline = if_else(midnight_deadline == 1, "Midnight", "4pm")) |>
  filter(!is.na(q3_deadline_stress)) |>
  mutate(deadline = factor(deadline, levels = c("4pm", "Midnight")))

# 2. 诊断检查
print(levels(hw_plot$deadline)) # 应输出 "4pm" "Midnight"
print(table(hw_plot$deadline)) # 应输出 43 42

# 3. 绘图（移除 jitter 先测试箱线图，添加颜色）
ggplot(hw_plot, aes(x = deadline, y = q3_deadline_stress)) +
  geom_boxplot(color = "black", fill = "lightblue", outlier.shape = NA) +
  labs(title = "Boxplot Test", x = "Deadline", y = "Stress") +
  theme_minimal()

# 方案 A：增强箱线图可见性
ggplot(hw, aes(x = deadline, y = q3_deadline_stress)) +
  geom_boxplot(width = 0.5, color = "black", fill = "lightblue", outlier.shape = NA) +
  geom_jitter(alpha = 0.4, width = 0.15, color = "darkgray") +
  labs(title = "Stress Distribution (Boxplot)", y = "Stress Level") +
  theme_minimal()

# 方案 B：使用小提琴图 + 箱线图 (推荐)
ggplot(hw, aes(x = deadline, y = q3_deadline_stress)) +
  geom_violin(fill = "lightgray", color = "gray", alpha = 0.5) + # 显示密度分布
  geom_boxplot(width = 0.1, color = "red", outlier.shape = NA) + # 叠加箱线图
  geom_jitter(alpha = 0.3, width = 0.1, color = "black") +
  labs(title = "Stress Distribution (Violin + Box)", y = "Stress Level") +
  theme_minimal()

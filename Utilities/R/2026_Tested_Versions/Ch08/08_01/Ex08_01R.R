# R Statistics Essential Training
# Ex08_01
# Creating clustered bar chart for frequencies

# Load data
# Built-in dataset "warpbreaks"
?warpbreaks
warpbreaks
# Doesn't work: ==============<<<<<<<<<<<<<<<<
barplot(breaks ~ wool * tension, data = warpbreaks)
# This one works BUT not whole data is shown: ==============<<<<<<<<<<<<<<<<
plot(breaks ~ wool * tension, data = warpbreaks)

# Create a frequency table
freq_table <- table(warpbreaks$wool, warpbreaks$tension)
freq_table

barplot(
  freq_table,
  beside = TRUE,
  legend = TRUE,
  xlab = "Wool",
  ylab = "Frequency"
)

# Calculate mean breaks for each wool*tension combination
library(dplyr)
summary_data <- warpbreaks %>%
  group_by(wool, tension) %>%
  summarise(mean_breaks = mean(breaks), .groups = 'drop')

summary_data

# Create interaction labels
summary_data$combination <- paste(
  summary_data$wool,
  summary_data$tension,
  sep = "-"
)
summary_data

# Plot
barplot(
  summary_data$mean_breaks,
  names.arg = summary_data$combination,
  las = 2, # Rotate labels vertically
  ylab = "Mean Breaks"
)


data <- tapply(
  warpbreaks$breaks,
  list(warpbreaks$wool, warpbreaks$tension),
  mean
)
data
barplot(
  data,
  beside = TRUE,
  col = c("steelblue3", "thistle3"),
  bor = NA,
  main = "Mean Number of Warp Breaks\nby Tension and Wool",
  xlab = "Tension",
  ylab = "Mean Number of Breaks"
)


library(ggplot2)

# For means with error bars
ggplot(warpbreaks, aes(x = interaction(wool, tension), y = breaks)) +
  stat_summary(fun = mean, geom = "bar") +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  labs(x = "Wool-Tension Combination", y = "Mean Breaks") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# For legend, "locator(1)" is interactive and lets you click <<<<==========
# where you want to put the legend. You can also specify
# with coordinates.
legend(
  locator(1), #====================<<<<<<<<<<<<<<<
  rownames(data),
  fill = c("steelblue3", "thistle3")
)

rm(list = ls()) # Clean up

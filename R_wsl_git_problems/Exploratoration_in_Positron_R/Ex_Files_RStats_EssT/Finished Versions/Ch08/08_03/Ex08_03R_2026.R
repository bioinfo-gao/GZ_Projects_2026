# R Statistics Essential Training
# Ex08_03
# Creating scatterplot matrices

# Load data
library(datasets)
?iris
data(iris)
iris[1:5, ]

# Basic scatterplot matrix
pairs(iris[1:4])

# Modified scatterplot matrices

# Create palette with RColorBrewer
require("RColorBrewer")
display.brewer.pal(3, "Pastel1")

# Put histograms on the diagonal (from "pairs" help)
panel.hist <- function(x, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks; nB <- length(breaks)
  y <- h$counts; y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y,  ...)
  # Removed "col = "cyan" from code block; original below
  # rect(breaks[-nB], 0, breaks[-1], y, col = "cyan", ...) 
}

library(graphics)
pairs(iris[1:4], 
      panel = panel.smooth,  # Optional smoother
      main = "Scatterplot Matrix for Iris Data Using pairs Function",
      diag.panel = panel.hist, 
      pch = 16, 
      col = brewer.pal(3, "Pastel1")[unclass(iris$Species)])

# Similar with "car" package
# Gives kernal density and rugplot for each variable
# R 4.5.1
# (base) zhen@DESKTOP-C8OKE65:~/GZ_Projects_2026$ mamba activate spatial
# critical libmamba Cannot activate, prefix does not exist at: '/home/zhen/miniforge3/envs/spatial'
# (base) zhen@DESKTOP-C8OKE65:~/GZ_Projects_2026$ mamba activate spatial_R
# (spatial_R) zhen@DESKTOP-C8OKE65:~/GZ_Projects_2026$ mamba install -c conda-forge r-car

library(car)
library(stats)
scatterplotMatrix(~Petal.Length + Petal.Width + Sepal.Length + Sepal.Width | Species,
                  data = iris,
                  col = brewer.pal(3, "Dark2"),
                  main="Scatterplot Matrix for Iris Data Using \"car\" Package")

# Clean up
palette("default")  # Return to default
detach("package:RColorBrewer", unload = TRUE)
detach("package:car", unload=TRUE)
rm(list = ls())

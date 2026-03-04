R.version.string  # or 
sessionInfo()

library(Seurat)
plot(1:10, main="Httpgd Test")

# R automatics write the words and library from R REditorSupport to 
# the interactive window, so you don't have to type them again. 
# Just write lib, the REditorSupport will give you suggest to library() 


# vscode do NOT understand print() in R, we have to install languageserver and httpgd to see the output in the interactive window. If you see the plot above, it means httpgd is working. If you see the version info above, it means R and Seurat are working. If you see both, congratulations! Your R environment is ready for Seurat analysis in VS Code.
# in R terminal, you can run the following commands to install the necessary packages to call R 
# from bash terminal, you can run the following commands 
install.packages("languageserver", repos = "https://cloud.r-project.org/")


# R Extension Pack by Yuki Ueda
# These are some of the extensions to make R development easier and fun.

# install.packages("httpgd", repos = "https://cloud.r-project.org/")
print("Hello, Seurat and Httpgd are working!")


# 万能的命令行工具 Pandoc（生信标配）
# 作为生信人，你的 mamba 环境里其实可以装一个非常强大的文档转换工具 Pandoc，它不依赖浏览器。
# # 1. 在你的环境里安装 pandoc
mamba install pandoc -c conda-forge
# 2. 将 md 转换为 html (HTML 不需要额外依赖，方便在浏览器查看)
pandoc seurat_vs_scanpy.md -o seurat_vs_scanpy.html 
#pandoc seurat_vs_scanpy.md -o seurat_vs_scanpy.pdf  
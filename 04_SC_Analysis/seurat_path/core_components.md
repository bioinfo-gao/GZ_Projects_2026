| 组件 (mamba 渠道) | 核心作用 | 为什么用 mamba 而不是在 R 里 install.packages |
| :--- | :--- | :--- |
| `r-base=4.3` | R 语言运行核心 | 确保版本稳定，满足 Seurat V5 需求 |
| `r-seurat` | 单细胞分析主程序 | 包含大量底层 C++ 代码，mamba 直接下预编译版，防报错 |
| `r-httpgd` | VS Code 交互式画图 | 避免系统缺少 `libcairo` 等 Linux 绘图库导致的编译失败 |
| `r-languageserver`| VS Code 代码补全与提示 | 极大地提升在服务器上写 R 代码的体验 |
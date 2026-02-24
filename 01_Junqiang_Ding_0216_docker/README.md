# 丁俊强项目 - Docker 版本

这是一个使用 Docker 容器技术运行 nf-core/rnaseq 分析流程的版本，使用与李晓菲项目相同的参数和 Docker 缓存。

## 项目概述

- 原始项目: 丁俊强项目 (01_Junqiang_Ding_0216)
- 分析类型: Bulk RNA-seq
- 样本数量: 9个 (D1-D9)
- 测序类型: 双端测序，链特异性 (reverse)
- 参考基因组: 小鼠 (Mus musculus)
- 工具版本: nf-core/rnaseq v3.21.0

## 使用方法

### 1. 直接运行分析

```bash
bash work_pipeline_docker.sh
```

### 2. 带监控的运行

```bash
bash run_nfcore_docker_with_monitor.sh
```

此脚本会启动分析并监控进程状态，记录日志和最终结果。

## 配置参数

本项目使用与李晓菲项目相同的配置参数：

- 参考基因组FASTA: `/home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.fasta`
- 注释文件GTF: `/home/songz/lhn_work/database/02.genome/mouse_reference/Mus_musculus.gtf`
- rRNA数据库: `/home/songz/lhn_work/database/03.rRNA/local_rrna_manifest.txt`
- STAR索引: `/home/songz/lhn_work/Project_2025/Project_01_bulk_rnaseq_20251021/results_mouse/genome/index/star`
- Salmon索引: `/home/songz/lhn_work/Project_2025/Project_01_bulk_rnaseq_20251021/results_mouse/genome/index/salmon`
- 使用Docker运行时
- 离线模式运行

## 输出结果

分析结果将保存在 `results_mouse_9_docker` 目录中。

## 日志文件

- `docker_analysis_output.log`: 详细分析输出
- `nfcore_docker_alerts.log`: 进程状态和错误报告
- `.analysis_pid`: 分析进程ID

## 注意事项

1. 确保Docker服务正在运行且当前用户具有Docker权限
2. 确保所需的参考基因组、索引和数据库文件路径正确可访问
3. 如果遇到权限问题，请联系系统管理员将您添加到docker用户组
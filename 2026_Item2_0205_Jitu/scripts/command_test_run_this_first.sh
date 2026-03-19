export NXF_SINGULARITY_CACHEDIR=/Work_bio/gao/projects/singularity_cache
mkdir -p $NXF_SINGULARITY_CACHEDIR

# 如果这个目录为空或不存在，说明镜像尚未完全下载。不用担心，下一次运行时会自动下载。
# 首先确定你的工作目录正确不正确， 且其中有无 
ls -lh $NXF_SINGULARITY_CACHEDIR

tmux new -s rnaseq  

# Check if we are inside a tmux session
# (1) 有些终端会在标题栏显示 [tmux] 或当前会话名,需要用鼠标悬停或查看标题栏才能看到。
# (2) 你可以在命令行输入以下命令来检查是否在 tmux 中：
echo $TMUX
# 如果输出类似 /tmp/tmux-1000/default,12345,0 的字符串（包含 tmux 服务路径和会话信息），说明你在 tmux 中。
# 如果没有输出（空行），说明不在 tmux 中。
# (3) tmux info 命令
tmux info 2>/dev/null
# 如果在 tmux 内，会显示当前会话的详细信息。
# 如果不在 tmux 内，会提示 no server running on /tmp/tmux-... 或 can't find server（错误信息会被重定向到 /dev/null 则不显示）。

# 进入你的工作目录
cd /home/gao/projects/2026_Item2_0205_Jitu/scripts

# 运行测试（会自动下载测试数据，并使用 singularity 容器）
nextflow run nf-core/rnaseq \
    -r 3.14.0 \
    -profile singularity,test \
    --outdir ./test_output \
    -resume

# ======================= # =======================
# -[nf-core/rnaseq] Pipeline completed successfully -
# Completed at: 19-Mar-2026 11:51:52
# Duration    : 6m 24s
# CPU hours   : 0.5
# Succeeded   : 194

# ======================= # =======================
# 如果测试成功运行至结束（最后显示 Pipeline completed successfully），则证明：
# 所有所需容器镜像均已成功下载并可用。
# 流程逻辑完整，无环境依赖问题。
# 注意：第一次运行时会下载测试数据（约 200MB）和所有容器镜像，请确保网络通畅。
# 再次检查，则可以发现大量img 文件已经出现在 $NXF_SINGULARITY_CACHEDIR 中，且测试数据也被下载到了 test_output 目录下。
# (base) gao@us1:~/projects/2026_Item2_0205_Jitu/scripts$ ls -lh $NXF_SINGULARITY_CACHEDIR |wc
#      26     227    2756

# ======================= # =======================
# 检查已成功运行的进程
# 如果你之前已经运行过该流程（即使中途中断），可以通过以下命令查看已成功完成的进程：

# # 列出最近一次运行的进程状态
# nextflow log suspicious_williams -f process,status,exit
# 如果看到类似 COMPLETED 的进程（如 TRIMGALORE、GTF_FILTER），说明这些步骤所需的软件已正常执行。





# ======================= # =======================
# 手动验证单个容器镜像（可选）
# 你可以手动拉取核心镜像并测试其可用性：
# # 拉取流程主镜像
# singularity pull --dir $NXF_SINGULARITY_CACHEDIR docker://nfcore/rnaseq:3.14.0

# # 测试镜像是否可用
# singularity exec $NXF_SINGULARITY_CACHEDIR/nfcore-rnaseq-3.14.0.img star --version
# 如果输出 STAR 版本号，说明该镜像正常。

# Ctrl+B, D     

tmux a

exit 
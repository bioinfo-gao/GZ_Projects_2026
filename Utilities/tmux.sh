tmux new -s rnaseq -> 运行命令 -> Ctrl+B, D 离开

# 新建会话：
tmux new -s rnaseq 

# 在会话中挂起 (Detach)：按下快捷键：
# Ctrl + B，然后按 D。(此时你可以安全关闭终端或 VS Code，任务会在后台继续运行)

# 查看正在运行的会话：
tmux ls
# 0: 1 windows (created Thu Mar 19 10:50:25 2026)
# 你会看到类似 
# 0: 1 windows (created...) 或者 
# bio_work: 1 windows... 的输出。
# 前面的 0 或 bio_work 就是它的名字。

# # 如果名字是 0
# tmux attach -t 0
tmux attach -t rnaseq

# 重新进入最近的对话：简写（进入最近使用的会话）
tmux a

# Ctrl + B, 然后按 D 只是分离（Detach）了会话，它就像把一个正在播放视频的窗口最小化到了后台，任务依然在跑。
# 如果你想彻底关闭该会话并清除它，有以下几种方法：

# 方法 1：在会话内部输入指令（最简单）如果你还在 tmux 窗口里，直接输入：
exit
# 或者按下快捷键：
# Ctrl + D
# 当看到屏幕显示 [exited] 时，这个会话就彻底消失了。
# 方法 2：在会话外部强制杀死（在普通终端操作）如果你已经按了 Ctrl + B, D 回到了普通命令行，
# 你可以通过名字来删除它：先查看会话列表（确认名字）：
tmux ls
# 杀死指定会话（假设名字是 0 或你起的 bio_work）：
bashtmux kill-session -t 0

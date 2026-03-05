# 给 WSL Ubuntu 分配 10G 内存和 10 个核
# WSL（Windows Subsystem for Linux）默认会根据主机资源动态分配 CPU 和内存（通常内存上限为主机总内存的 50%，CPU 为所有核），
#但您可以自定义配置来固定分配（如 10G 内存和 10 个核）。这通过编辑 Windows 中的 .wslconfig 文件实现。
#以下是详细步骤，适用于 Windows 10/11 和 WSL 2（WSL 1 不支持资源限制）。操作前确保 WSL 已安装并运行 Ubuntu。

# 步骤 1：关闭 WSL 实例

# 在 PowerShell 或命令提示符（cmd）中运行：text
wsl --shutdown
# 这会关闭所有 WSL 实例，确保配置生效。

# 步骤 2：创建或编辑 .wslconfig 文件

# 文件位置：您的 Windows 用户目录（e.g., C:\Users\您的用户名.wslconfig）。如果不存在，创建一个新文件。
# 用记事本或 VS Code 打开/创建 .wslconfig（注意是隐藏文件，以点开头）。
# 添加以下内容（INI 格式）：text
[wsl2]
memory=10GB     # 分配 10G 内存
processors=10   # 分配 10 个 CPU 核
# 保存文件。注意：
# memory：单位为 GB、MB 等（e.g., 10GB 或 10240MB）。
# processors：整数，不能超过主机物理核数（检查主机：任务管理器 > 性能 > CPU）。
# 如果主机内存/核不足，会自动限制到最大可用。


# 步骤 3：重启 WSL 并验证

# 运行：text
wsl -d Ubuntu  # 替换为您的发行版名，如 Ubuntu-22.04
# 在 WSL Ubuntu 中验证配置：
# 检查内存：
free -h（Total 列应接近 10G）。
# 检查 CPU 核：
nproc # 或 
lscpu #（CPU(s) 列应为 10）。

# 如果无效，重启 Windows 或运行 wsl --shutdown 再试。

# 注意事项

# 主机资源：主机需有 >10G 内存和 >10 个核，否则配置无效（WSL 会自动降级）。
# 性能影响：分配过多可能影响 Windows 性能；测试后调整。
# 多发行版：配置全局生效（所有 WSL 2 发行版共享）。
# 版本要求：WSL 2（运行 wsl --version 检查）；如果 WSL 1，需升级 wsl --update。
# 问题排查：如果文件不生效，检查路径（必须在用户目录下，非系统盘），或用管理员模式编辑。

# 配置后，您的 WSL Ubuntu 会固定使用 10G 内存和 10 个核，适合运行资源密集任务（如生物信息分析）。如果遇到错误，请提供输出，我可以进一步调试！
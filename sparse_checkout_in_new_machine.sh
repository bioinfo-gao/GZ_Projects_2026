# 1. 配置 Git 全局身份（必需）
# 配置用户身份（不配置无法提交）
git config --global user.name "ZG Tailscale"
git config --global user.email "bioinfo.gao@gmail.com"

# 验证配置
git config --global user.name
git config --global user.email
git config --global --list

# 2. 配置 SSH 密钥（用于 GitHub 认证）
# 生成 SSH 密钥（如果还没有）
ssh-keygen -t ed25519 -C "bioinfo.gao@gmail.com" -f ~/.ssh/id_ed25526
# 或传统 RSA（兼容性好）
# ssh-keygen -t rsa -b 4096 -C "bioinfo.gao@gmail.com"

# 启动 ssh-agent
eval "$(ssh-agent -s)"

# 添加密钥
ssh-add ~/.ssh/id_ed25526

# 复制公钥到剪贴板（或手动复制）
cat ~/.ssh/id_ed25526.pub
# 复制输出，添加到 GitHub: Settings -> SSH and GPG keys -> New SSH key

# 3. 测试 SSH 连接
ssh -T git@github.com
# 看到：Hi username! You've successfully authenticated...

# 4. Sparse Checkout 完整流程
# 创建工作目录
mkdir -p ~/projects && cd ~/projects

# 初始化空仓库
git init GZ_Projects_2026
cd GZ_Projects_2026

# 添加远端
git remote add origin git@github.com:bioinfo-gao/GZ_Projects_2026.git

# 先清理旧配置 （如果之前设置过）
git config --unset core.sparseCheckoutCone 2>/dev/null || true

# # 1: 先启用 sparse-checkout（布尔值 true）
# git config --bool core.sparseCheckout true

# # Git 2.34 可能需要直接编辑文件而不是用 config 命令
# echo "cone" > .git/info/sparse-checkout

# # 验证
# echo "检查配置:"
# cat .git/info/sparse-checkout


# # ===== 5. 拉取远端 =====
# echo ""
# echo "拉取 origin/$DEFAULT_BRANCH..."
# git fetch origin "$DEFAULT_BRANCH" --depth 1
# git checkout -b "$DEFAULT_BRANCH" "origin/$DEFAULT_BRANCH"

# # ===== 6. 设置为空（cone 模式下）=====
# # cone 模式：空行表示什么都不包含
# echo "" > .git/info/sparse-checkout
# git read-tree -mu HEAD  # 应用更改

# # ===== 7. 完成状态 =====
# echo ""
# echo "✅ Cone 模式 Sparse Checkout 完成！"
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# echo "  分支:     $DEFAULT_BRANCH"
# echo "  文件数:   $(git ls-files | wc -l) (应为 0)"
# echo "  仓库大小: $(du -sh .git | cut -f1)"
# echo "  模式文件: $(cat .git/info/sparse-checkout | head -1)"
# echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# echo ""
# echo "👉 添加文件夹（cone 模式）:"
# echo "   echo 'docs' >> .git/info/sparse-checkout"
# echo "   git read-tree -mu HEAD"
# echo ""
# echo "👉 或尝试: git sparse-checkout set docs scripts"

# 启用 sparse-checkout
git config core.sparseCheckout true

# cone 模式：写入 cone 到第一行
echo "cone" > .git/info/sparse-checkout

# 拉取 master 分支
git fetch origin master --depth 1
git checkout -b master origin/master

## 设置为空（什么都不下载）
git sparse-checkout set 

echo ""
echo "完成，当前文件数: $(git ls-files | wc -l)"
echo ""
echo "现在可以添加文件夹了:"
echo "  git sparse-checkout add 2026_Item2_0205_contamination_athenomics"
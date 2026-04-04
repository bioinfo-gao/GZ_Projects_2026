


# 查看有多少次提交等待推送
git log origin/master..HEAD --oneline

# 查看这些提交包含哪些大文件
git log origin/master..HEAD --name-only | grep -E "\.transcripts\.gtf|\.bam" | head -20

# 假设您有 3 次待推送提交，重置到 3 次之前
# 先确认提交数，然后调整数字
git reset --soft HEAD~4

# 取消所有文件的暂存
git reset HEAD


# 只添加代码、配置、小型结果（排除大文件）
git add 2026_Item6_UIC_02122603/scripts/
git add 2026_Item6_UIC_02122603/results/
git add 2026_Item6_UIC_02122603/config/
git add .gitignore
git add README.md

# 验证暂存区（应该没有大文件）
git status --short | grep -E "\.transcripts\.gtf|\.bam|\.flagstat" || echo "✓ 暂存区无大文件"

# 只添加代码、配置、小型结果（排除大文件）
git add 2026_Item6_UIC_02122603/scripts/
git add 2026_Item6_UIC_02122603/results/
git add 2026_Item6_UIC_02122603/config/
git add .gitignore
git add README.md

# 验证暂存区（应该没有大文件）
git status --short | grep -E "\.transcripts\.gtf|\.bam|\.flagstat" || echo "✓ 暂存区无大文件"


# 提交（只包含小文件）
git commit -m "Code and results only (large nf-core outputs excluded)"

# 推送
git push origin master
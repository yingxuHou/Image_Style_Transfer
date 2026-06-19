#!/bin/bash
# Git 自动同步脚本
# 用法: bash sync_github.sh "提交信息"

set -e

# 如果没有提供提交信息，使用默认信息
COMMIT_MSG="${1:-Update: $(date '+%Y-%m-%d %H:%M:%S')}"

echo "=========================================="
echo "开始同步到 GitHub"
echo "=========================================="

# 添加所有修改
echo "📦 添加文件..."
git add .

# 检查是否有变更
if git diff --staged --quiet; then
    echo "✅ 没有需要提交的变更"
    exit 0
fi

# 显示将要提交的文件
echo ""
echo "📝 将要提交的变更:"
git status --short

echo ""
read -p "确认提交? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 取消提交"
    exit 1
fi

# 提交
echo ""
echo "💾 提交变更..."
git commit -m "$COMMIT_MSG

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"

# 推送
echo ""
echo "🚀 推送到 GitHub..."
git push origin main

echo ""
echo "=========================================="
echo "✅ 同步完成！"
echo "=========================================="
echo "查看仓库: https://github.com/yingxuHou/Image_Style_Transfer"

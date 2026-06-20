#!/bin/bash
# 下载COCO训练数据集的一部分
# 我们将下载500张图像（平衡训练时间和效果）

echo "=========================================="
echo "下载COCO训练数据（500张图像）"
echo "=========================================="

# 安装必要的工具（如果没有）
if ! command -v wget &> /dev/null; then
    echo "安装 wget..."
    sudo apt-get update && sudo apt-get install -y wget
fi

# 创建临时下载目录
TEMP_DIR="data/temp_download"
mkdir -p "$TEMP_DIR"

echo ""
echo "方法1: 使用Kaggle COCO数据集（推荐）"
echo "=========================================="
echo "1. 访问: https://www.kaggle.com/datasets/awsaf49/coco-2017-dataset"
echo "2. 点击 Download 下载 train2017.zip (约18GB，包含118,287张图像)"
echo "3. 解压后从中随机选取500-1000张图像复制到 data/train_images/"
echo ""
echo "或者使用以下命令快速选取（假设你已下载并解压到 ~/Downloads/train2017/）："
echo ""
echo "  # 随机选取500张图像"
echo "  find ~/Downloads/train2017/ -name '*.jpg' | shuf -n 500 | xargs -I {} cp {} data/train_images/"
echo ""

echo ""
echo "方法2: 使用Unsplash随机图像（快速测试）"
echo "=========================================="
echo "下载500张随机高质量图像..."

# 使用Unsplash的随机图像API
for i in {1..500}; do
    echo "下载图像 $i/500..."
    wget -q "https://source.unsplash.com/random/800x600?nature,landscape,architecture" \
         -O "$TEMP_DIR/unsplash_$(printf "%04d" $i).jpg"

    # 检查文件是否有效
    if [ -f "$TEMP_DIR/unsplash_$(printf "%04d" $i).jpg" ]; then
        file_size=$(stat -f%z "$TEMP_DIR/unsplash_$(printf "%04d" $i).jpg" 2>/dev/null || stat -c%s "$TEMP_DIR/unsplash_$(printf "%04d" $i).jpg" 2>/dev/null)
        if [ "$file_size" -lt 1000 ]; then
            echo "  跳过无效图像"
            rm "$TEMP_DIR/unsplash_$(printf "%04d" $i).jpg"
        fi
    fi

    # 避免请求过快
    sleep 1
done

# 移动到训练目录
echo ""
echo "移动图像到训练目录..."
mv "$TEMP_DIR"/*.jpg data/train_images/ 2>/dev/null || true
rmdir "$TEMP_DIR"

# 统计
TOTAL=$(find data/train_images -name "*.jpg" -o -name "*.JPG" -o -name "*.png" | wc -l)
echo ""
echo "=========================================="
echo "✅ 完成！"
echo "=========================================="
echo "训练图像总数: $TOTAL"
echo ""
echo "下一步:"
echo "  bash scripts/train_full.sh"

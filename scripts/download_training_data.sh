#!/bin/bash
# 下载训练数据集

echo "=========================================="
echo "下载训练数据集"
echo "=========================================="

# 方案 1: COCO 2017 训练集（推荐，但很大 ~26GB）
# 方案 2: Natural Images（小而快 ~358MB，8 类自然图像）
# 方案 3: Intel Image Classification（中等 ~363MB，自然场景）

echo ""
echo "可选数据集："
echo "1. COCO 2017 (26GB, 118k 图像) - 最好但很大"
echo "2. Natural Images (358MB, 6.9k 图像) - 推荐，快速"
echo "3. Intel Image Classification (363MB, 25k 图像) - 自然场景"
echo ""
echo "默认下载：Natural Images（方案2）"
echo ""

# 创建临时下载目录
mkdir -p /home/yxhou/medium-project/data/downloads
cd /home/yxhou/medium-project/data/downloads

# 下载 Natural Images 数据集
echo "正在下载 Natural Images 数据集..."
kaggle datasets download -d prasunroy/natural-images

# 解压
echo "正在解压..."
unzip -q natural-images.zip -d natural-images

# 统计图像数量
echo ""
echo "检查下载的图像..."
find natural-images -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" | wc -l

# 复制到训练目录
echo ""
echo "复制到训练目录..."
find natural-images -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) -exec cp {} /home/yxhou/medium-project/data/train_images/ \;

# 统计最终训练图像数量
FINAL_COUNT=$(find /home/yxhou/medium-project/data/train_images -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" | wc -l)

echo ""
echo "=========================================="
echo "下载完成！"
echo "=========================================="
echo "训练图像总数: $FINAL_COUNT"
echo "训练目录: /home/yxhou/medium-project/data/train_images/"
echo ""
echo "下一步: bash scripts/train_full.sh"

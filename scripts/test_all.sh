#!/bin/bash
# 批量测试所有测试图像

echo "=========================================="
echo "批量测试所有图像"
echo "=========================================="

# 检查模型
if [ ! -f "checkpoints/best_model.pth" ]; then
    echo "❌ 错误: 模型文件不存在 checkpoints/best_model.pth"
    echo "请先运行: bash scripts/train_full.sh"
    exit 1
fi

# 清空旧的指标文件
> results/metrics.csv

# 测试所有图像
TEST_IMAGES=$(find data/test_images -name "*.jpg" -o -name "*.JPG" -o -name "*.png")
TEST_COUNT=$(echo "$TEST_IMAGES" | wc -l)

echo "找到 $TEST_COUNT 张测试图像"
echo ""

i=1
for img in $TEST_IMAGES; do
    filename=$(basename "$img")
    basename="${filename%.*}"

    echo "[$i/$TEST_COUNT] 处理: $filename"

    python test.py \
        --model checkpoints/best_model.pth \
        --input "$img" \
        --output "results/comparisons/${basename}_stylized.png" \
        --style-image data/style_images/style.jpg \
        --image-size 512 \
        --metrics results/metrics.csv \
        --device auto

    i=$((i+1))
    echo ""
done

echo "=========================================="
echo "批量测试完成！"
echo "=========================================="
echo "输出目录: results/comparisons/"
echo "性能指标: results/metrics.csv"
echo ""
echo "查看结果:"
echo "  cat results/metrics.csv"
echo "  ls -lh results/comparisons/"

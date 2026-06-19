#!/bin/bash
# 快速推理测试脚本

echo "=========================================="
echo "快速推理测试"
echo "=========================================="

# 检查模型是否存在
if [ ! -f "checkpoints/test_model.pth" ]; then
    echo "❌ 错误: 模型文件不存在 checkpoints/test_model.pth"
    echo "请先运行: bash scripts/train_quick.sh"
    exit 1
fi

# 检查测试图像
if [ ! -f "data/test_images/test.jpg" ]; then
    echo "❌ 错误: 测试图像不存在 data/test_images/test.jpg"
    exit 1
fi

# 运行推理
python3 test.py \
    --model checkpoints/test_model.pth \
    --input data/test_images/test.jpg \
    --output results/comparisons/test_output.png \
    --style-image data/style_images/style.jpg \
    --image-size 256 \
    --metrics results/test_metrics.csv

echo ""
echo "=========================================="
echo "推理测试完成！"
echo "=========================================="
echo "输出图像: results/comparisons/test_output.png"
echo "性能指标: results/test_metrics.csv"
echo ""
echo "查看结果:"
echo "  cat results/test_metrics.csv"

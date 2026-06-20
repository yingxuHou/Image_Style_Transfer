#!/bin/bash
# 快速验证脚本：5 epochs 测试新参数是否有效
# 预计时间：~30 分钟

echo "=========================================="
echo "快速验证：新参数配置"
echo "=========================================="
echo ""
echo "目的：快速验证思路是否正确（5 epochs）"
echo "如果效果好，再运行完整训练（30 epochs）"
echo ""
echo "新参数："
echo "  content_weight: 5.0 (原来 2.0)"
echo "  style_weight: 1e4 (原来 1e5，降低 10 倍)"
echo "  tv_weight: 1e-4 (原来 1e-6，提升 100 倍)"
echo "  style layers: 加权 [0.2, 0.3, 0.5, 1.0]"
echo ""
echo "=========================================="
echo ""

python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_quick_test.pth \
    --epochs 5 \
    --batch-size 4 \
    --image-size 512 \
    --content-weight 5.0 \
    --style-weight 1e4 \
    --tv-weight 1e-4 \
    --log-file logs/train_quick_test.csv \
    --sample-output results/samples/sample_quick_test.png \
    --device auto

echo ""
echo "=========================================="
echo "快速验证完成！"
echo "=========================================="
echo ""
echo "立即测试效果："
python3 test.py \
    --model checkpoints/model_quick_test.pth \
    --input data/test_images/test.jpg \
    --output results/output_quick_test.png \
    --image-size 672

echo ""
echo "=========================================="
echo "对比图像："
echo "  原始: results/output_correct_model.png"
echo "  新版: results/output_quick_test.png"
echo ""
echo "如果新版效果明显更好（结构更清晰）："
echo "  → 运行完整训练: bash scripts/train_structure_preserving.sh"
echo ""
echo "如果效果不理想："
echo "  → 调整权重比例，再次快速验证"
echo "=========================================="

#!/bin/bash
# 保留更清晰内容结构的训练脚本
# 目标：风格化的同时保持元素清晰可辨

echo "=========================================="
echo "训练目标：清晰内容 + 适度风格"
echo "=========================================="
echo ""
echo "参数调整："
echo "  epochs: 20 (充分训练)"
echo "  content_weight: 10.0 (进一步加强内容)"
echo "  style_weight: 5000 (再降低一半)"
echo "  tv_weight: 1e-4 (平滑噪声)"
echo "  batch_size: 8 (利用GPU显存)"
echo "  image_size: 512"
echo ""
echo "=========================================="
echo ""

python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_clearer_content.pth \
    --epochs 20 \
    --batch-size 8 \
    --image-size 512 \
    --content-weight 10.0 \
    --style-weight 5000 \
    --tv-weight 1e-4 \
    --log-file logs/train_clearer_content.csv \
    --sample-output results/samples/sample_clearer_content.png \
    --device auto

echo ""
echo "=========================================="
echo "训练完成！测试效果..."
echo "=========================================="
echo ""

python3 test.py \
    --model checkpoints/model_clearer_content.pth \
    --input data/test_images/test.jpg \
    --output results/output_clearer_content.png \
    --image-size 672

echo ""
echo "=========================================="
echo "输出："
echo "  结果: results/output_clearer_content.png"
echo "  日志: logs/train_clearer_content.csv"
echo ""
echo "对比："
echo "  quick_test: results/output_quick_test.png"
echo "  新版本: results/output_clearer_content.png"
echo "=========================================="

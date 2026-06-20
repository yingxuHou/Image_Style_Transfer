#!/bin/bash
# 平衡训练脚本：500:1 风格比例，20 epochs
# 目标：清晰的内容结构 + 适度的风格效果

echo "=========================================="
echo "训练配置：清晰内容导向"
echo "=========================================="
echo ""
echo "训练参数："
echo "  epochs: 20"
echo "  batch_size: 16 (充分利用 GPU 显存)"
echo "  image_size: 512"
echo ""
echo "权重配置："
echo "  content_weight: 10.0"
echo "  style_weight: 5000 (比例 500:1)"
echo "  tv_weight: 1e-4"
echo ""
echo "预计训练时间：~1.5-2 小时"
echo "=========================================="
echo ""

python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_balanced_500.pth \
    --epochs 20 \
    --batch-size 16 \
    --image-size 512 \
    --content-weight 10.0 \
    --style-weight 5000 \
    --tv-weight 1e-4 \
    --log-file logs/train_balanced_500.csv \
    --sample-output results/samples/sample_balanced_500.png \
    --device auto

echo ""
echo "=========================================="
echo "训练完成！立即测试..."
echo "=========================================="
echo ""

python3 test.py \
    --model checkpoints/model_balanced_500.pth \
    --input data/test_images/test.jpg \
    --output results/output_balanced_500.png \
    --image-size 672

echo ""
echo "=========================================="
echo "训练完成！"
echo "=========================================="
echo ""
echo "输出文件："
echo "  模型: checkpoints/model_balanced_500.pth"
echo "  结果: results/output_balanced_500.png"
echo "  日志: logs/train_balanced_500.csv"
echo ""
echo "对比图像："
echo "  quick_test (5 epochs, 2000:1): results/output_quick_test.png"
echo "  新版本 (20 epochs, 500:1): results/output_balanced_500.png"
echo ""
echo "如果元素还是不够清晰，可以尝试："
echo "  - 进一步降低风格权重到 250:1 或 100:1"
echo "  - 增加训练到 30 epochs"
echo "  - 调整 TV weight 来减少噪声"
echo "=========================================="

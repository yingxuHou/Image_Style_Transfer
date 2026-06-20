#!/bin/bash
# 对比实验：不同 style_weight 的影响

echo "=========================================="
echo "对比实验：测试不同 style_weight"
echo "=========================================="
echo ""
echo "实验设置："
echo "  - 固定参数: epochs=2, batch_size=8, image_size=256"
echo "  - 对比变量: style_weight"
echo "  - 实验组: 1e4, 1e5 (已完成), 1e6"
echo ""

# 检查训练数据
TRAIN_COUNT=$(find data/train_images -name "*.JPG" -o -name "*.jpg" -o -name "*.png" | wc -l)
echo "训练图像数量: $TRAIN_COUNT"
echo ""

# 创建对比实验目录
mkdir -p checkpoints/experiments
mkdir -p results/experiments

# 实验1: style_weight = 1e4 (较小)
echo "=========================================="
echo "实验1: style_weight = 1e4 (弱风格)"
echo "=========================================="
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/experiments/model_1e4.pth \
    --epochs 2 \
    --batch-size 8 \
    --image-size 256 \
    --content-weight 1.0 \
    --style-weight 1e4 \
    --tv-weight 1e-6 \
    --log-file logs/exp_1e4.csv \
    --sample-output results/experiments/sample_1e4.png \
    --device auto

echo ""
echo "实验1完成！测试效果..."
python3 test.py \
    --model checkpoints/experiments/model_1e4.pth \
    --input data/test_images/test.jpg \
    --output results/experiments/output_1e4.png \
    --style-image data/style_images/style.jpg \
    --image-size 512

echo ""
echo "=========================================="
echo "实验2: style_weight = 1e5 (中等风格) - 已完成"
echo "=========================================="
echo "跳过，使用已训练的 best_model.pth"
echo "测试效果..."
python3 test.py \
    --model checkpoints/best_model.pth \
    --input data/test_images/test.jpg \
    --output results/experiments/output_1e5.png \
    --style-image data/style_images/style.jpg \
    --image-size 512

echo ""
echo "=========================================="
echo "实验3: style_weight = 1e6 (强风格)"
echo "=========================================="
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/experiments/model_1e6.pth \
    --epochs 2 \
    --batch-size 8 \
    --image-size 256 \
    --content-weight 1.0 \
    --style-weight 1e6 \
    --tv-weight 1e-6 \
    --log-file logs/exp_1e6.csv \
    --sample-output results/experiments/sample_1e6.png \
    --device auto

echo ""
echo "实验3完成！测试效果..."
python3 test.py \
    --model checkpoints/experiments/model_1e6.pth \
    --input data/test_images/test.jpg \
    --output results/experiments/output_1e6.png \
    --style-image data/style_images/style.jpg \
    --image-size 512

echo ""
echo "=========================================="
echo "对比实验完成！"
echo "=========================================="
echo ""
echo "实验结果："
echo "  实验1 (1e4): results/experiments/output_1e4.png"
echo "  实验2 (1e5): results/experiments/output_1e5.png"
echo "  实验3 (1e6): results/experiments/output_1e6.png"
echo ""
echo "查看对比："
echo "  ls -lh results/experiments/"
echo "  cat results/metrics.csv"

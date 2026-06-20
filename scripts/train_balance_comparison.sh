#!/bin/bash
# 权重对比实验：找到最佳 style/content 平衡点

echo "=========================================="
echo "权重对比实验"
echo "目标：找到结构保持 + 风格强度的最佳平衡"
echo "=========================================="
echo ""

# 实验 1：更强结构保持（推荐起点）
echo "实验 1: 强结构保持"
echo "  content_weight=5.0, style_weight=1e4, tv_weight=1e-4"
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_balance_1e4.pth \
    --epochs 20 \
    --batch-size 4 \
    --image-size 512 \
    --content-weight 5.0 \
    --style-weight 1e4 \
    --tv-weight 1e-4 \
    --log-file logs/train_balance_1e4.csv \
    --sample-output results/samples/sample_balance_1e4.png \
    --device auto

echo ""
echo "----------------------------------------"
echo ""

# 实验 2：中等平衡
echo "实验 2: 中等平衡"
echo "  content_weight=3.0, style_weight=3e4, tv_weight=1e-4"
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_balance_3e4.pth \
    --epochs 20 \
    --batch-size 4 \
    --image-size 512 \
    --content-weight 3.0 \
    --style-weight 3e4 \
    --tv-weight 1e-4 \
    --log-file logs/train_balance_3e4.csv \
    --sample-output results/samples/sample_balance_3e4.png \
    --device auto

echo ""
echo "----------------------------------------"
echo ""

# 实验 3：较强风格
echo "实验 3: 较强风格（接近原始配置）"
echo "  content_weight=2.0, style_weight=5e4, tv_weight=1e-4"
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_balance_5e4.pth \
    --epochs 20 \
    --batch-size 4 \
    --image-size 512 \
    --content-weight 2.0 \
    --style-weight 5e4 \
    --tv-weight 1e-4 \
    --log-file logs/train_balance_5e4.csv \
    --sample-output results/samples/sample_balance_5e4.png \
    --device auto

echo ""
echo "=========================================="
echo "对比实验完成！"
echo "=========================================="
echo ""
echo "生成的模型："
echo "  1. model_balance_1e4.pth  - 强结构保持 (比例 2000:1)"
echo "  2. model_balance_3e4.pth  - 中等平衡 (比例 10000:1)"
echo "  3. model_balance_5e4.pth  - 较强风格 (比例 25000:1)"
echo ""
echo "原始模型作为对照："
echo "  model_512_content2x.pth   - 原始配置 (比例 50000:1)"
echo ""
echo "批量测试命令："
echo "for model in model_balance_{1e4,3e4,5e4}.pth; do"
echo "  python3 test.py --model checkpoints/\$model --input data/test_images/test.jpg --output results/output_\${model%.pth}.png --image-size 672"
echo "done"

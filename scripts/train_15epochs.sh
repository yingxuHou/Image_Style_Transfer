#!/bin/bash
# 15 epoch 训练 - 追求更清晰的效果

echo "=========================================="
echo "15 Epochs 训练（追求更清晰的效果）"
echo "=========================================="

export TORCH_HOME=~/.cache/torch
export XDG_CACHE_HOME=~/.cache

# 检查训练数据
TRAIN_COUNT=$(find data/train_images -name "*.JPEG" | wc -l)
echo "训练图像数量: $TRAIN_COUNT"

echo ""
echo "⏱️  预计训练时间: 约 45-50 分钟"
echo "🎯 目标: 更清晰的风格迁移效果"
echo ""

# 使用 1e5 (中等风格)，训练 15 个 epoch
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_15epochs.pth \
    --epochs 15 \
    --batch-size 8 \
    --image-size 256 \
    --content-weight 1.0 \
    --style-weight 1e5 \
    --tv-weight 1e-6 \
    --log-file logs/train_15epochs.csv \
    --sample-output results/samples/sample_15epochs.png \
    --device auto

echo ""
echo "=========================================="
echo "✅ 训练完成！"
echo "=========================================="
echo "模型保存: checkpoints/model_15epochs.pth"
echo "训练日志: logs/train_15epochs.csv"
echo "训练样例: results/samples/sample_15epochs.png"
echo ""
echo "下一步测试:"
echo "python3 test.py --model checkpoints/model_15epochs.pth --input data/test_images/test.jpg --output results/output_15epochs.png --image-size 512"

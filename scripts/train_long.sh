#!/bin/bash
# 长时间训练以获得更好的效果

echo "=========================================="
echo "长时间训练（10 epochs）"
echo "=========================================="

export TORCH_HOME=~/.cache/torch
export XDG_CACHE_HOME=~/.cache

# 检查训练数据
TRAIN_COUNT=$(find data/train_images -name "*.JPEG" | wc -l)
echo "训练图像数量: $TRAIN_COUNT"

echo ""
echo "预计训练时间: 约 30-40 分钟"
echo ""

# 使用 1e5 (中等风格)，但训练 10 个 epoch
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_10epochs.pth \
    --epochs 10 \
    --batch-size 8 \
    --image-size 256 \
    --content-weight 1.0 \
    --style-weight 1e5 \
    --tv-weight 1e-6 \
    --log-file logs/train_10epochs.csv \
    --sample-output results/samples/sample_10epochs.png \
    --device auto

echo ""
echo "=========================================="
echo "训练完成！"
echo "=========================================="
echo "模型保存: checkpoints/model_10epochs.pth"
echo "训练日志: logs/train_10epochs.csv"
echo "训练样例: results/samples/sample_10epochs.png"
echo ""
echo "下一步测试: python3 test.py --model checkpoints/model_10epochs.pth --input data/test_images/test.jpg --output results/output_10epochs.png"

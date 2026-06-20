#!/bin/bash
# 512×512 高分辨率训练 - 更注重内容保留

echo "=========================================="
echo "512×512 训练 - 提高内容权重（更清晰）"
echo "=========================================="

export TORCH_HOME=~/.cache/torch
export XDG_CACHE_HOME=~/.cache

TRAIN_COUNT=$(find data/train_images -name "*.JPEG" | wc -l)
echo "训练图像数量: $TRAIN_COUNT"

echo ""
echo "⏱️  预计训练时间: 约 60 分钟"
echo "🎯 目标: 保留更多内容细节，同时有风格效果"
echo "📊 关键改变: content_weight 从 1.0 提高到 2.0"
echo ""

# 提高 content_weight 来保留更多细节
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_512_content2x.pth \
    --epochs 15 \
    --batch-size 4 \
    --image-size 512 \
    --content-weight 2.0 \
    --style-weight 1e5 \
    --tv-weight 1e-6 \
    --log-file logs/train_512_content2x.csv \
    --sample-output results/samples/sample_512_content2x.png \
    --device auto

echo ""
echo "=========================================="
echo "✅ 训练完成！"
echo "=========================================="

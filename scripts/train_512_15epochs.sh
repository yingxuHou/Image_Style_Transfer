#!/bin/bash
# 512×512 高分辨率训练 - 15 epochs

echo "=========================================="
echo "512×512 高分辨率训练（15 Epochs）"
echo "=========================================="

export TORCH_HOME=~/.cache/torch
export XDG_CACHE_HOME=~/.cache

# 检查训练数据
TRAIN_COUNT=$(find data/train_images -name "*.JPEG" | wc -l)
echo "训练图像数量: $TRAIN_COUNT"

echo ""
echo "⏱️  预计训练时间: 约 60-90 分钟（比256×256慢）"
echo "🎯 目标: 高分辨率清晰输出"
echo "📊 训练尺寸: 512×512"
echo "⚠️  batch_size 降至 4（避免显存不足）"
echo ""

# 512×512 训练，batch_size 降低以适应显存
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_512_15epochs.pth \
    --epochs 15 \
    --batch-size 4 \
    --image-size 512 \
    --content-weight 1.0 \
    --style-weight 1e5 \
    --tv-weight 1e-6 \
    --log-file logs/train_512_15epochs.csv \
    --sample-output results/samples/sample_512_15epochs.png \
    --device auto

echo ""
echo "=========================================="
echo "✅ 训练完成！"
echo "=========================================="
echo "模型保存: checkpoints/model_512_15epochs.pth"
echo "训练日志: logs/train_512_15epochs.csv"
echo "训练样例: results/samples/sample_512_15epochs.png"
echo ""
echo "下一步测试（高分辨率）:"
echo "python3 test.py --model checkpoints/model_512_15epochs.pth --input data/test_images/test.jpg --output results/output_512_final.png --image-size 512"

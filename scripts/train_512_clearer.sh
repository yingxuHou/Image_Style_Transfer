#!/bin/bash
# 512×512 训练 - 提高内容权重，保留更多细节

echo "=========================================="
echo "512×512 训练 - 更清晰的内容保留"
echo "=========================================="

export TORCH_HOME=~/.cache/torch
export XDG_CACHE_HOME=~/.cache

TRAIN_COUNT=$(find data/train_images -name "*.JPEG" | wc -l)
echo "训练图像数量: $TRAIN_COUNT"

echo ""
echo "⏱️  预计训练时间: 约 60 分钟"
echo "🎯 目标: 更清晰的内容细节"
echo "📊 参数调整:"
echo "   - content_weight: 1.0 → 2.0 (2倍，保留更多细节)"
echo "   - style_weight: 1e5 (不变)"
echo "   - 比例从 1:100000 变为 2:100000"
echo ""

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
echo "模型保存: checkpoints/model_512_content2x.pth"
echo "训练日志: logs/train_512_content2x.csv"
echo "训练样例: results/samples/sample_512_content2x.png"
echo ""
echo "下一步测试（使用拉伸模式）:"
echo "python3 test_stretch.py --model checkpoints/model_512_content2x.pth --input data/test_images/test.jpg --output results/output_512_content2x.png"

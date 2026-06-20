#!/bin/bash
# 真正训练（用现有13张图，2个epoch）- 修复权限问题版本

echo "=========================================="
echo "真正训练（用现有13张图，2个epoch）"
echo "=========================================="

# 设置 PyTorch 缓存目录到用户目录
export TORCH_HOME=~/.cache/torch
export XDG_CACHE_HOME=~/.cache

# 检查训练数据
TRAIN_COUNT=$(find data/train_images -name "*.JPG" -o -name "*.jpg" -o -name "*.png" | wc -l)
echo "训练图像数量: $TRAIN_COUNT"

if [ "$TRAIN_COUNT" -lt 13 ]; then
    echo "❌ 错误: 训练图像不足"
    exit 1
fi

echo ""
echo "⚠️  注意：13张图数据量很少，效果会一般"
echo "但至少能看到基本的风格迁移效果"
echo ""

# 真正训练（完整的epoch，不限制步数）
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/real_model.pth \
    --epochs 2 \
    --batch-size 4 \
    --image-size 256 \
    --content-weight 1.0 \
    --style-weight 1e5 \
    --tv-weight 1e-6 \
    --log-file logs/real_train.csv \
    --sample-output results/samples/real_sample.png \
    --device auto

echo ""
echo "=========================================="
echo "训练完成！"
echo "=========================================="
echo "模型保存: checkpoints/real_model.pth"
echo "训练日志: logs/real_train.csv"
echo "训练样例: results/samples/real_sample.png"
echo ""
echo "下一步: python3 test.py --model checkpoints/real_model.pth --input data/test_images/test.jpg --output results/real_output.png"

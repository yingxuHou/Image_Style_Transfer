#!/bin/bash
# 正式训练脚本 - 用于完整训练（需要足够的训练数据）

echo "=========================================="
echo "正式训练 Fast Neural Style"
echo "=========================================="

# 检查训练数据
TRAIN_COUNT=$(find data/train_images -name "*.JPG" -o -name "*.jpg" -o -name "*.png" | wc -l)
echo "训练图像数量: $TRAIN_COUNT"

if [ "$TRAIN_COUNT" -lt 100 ]; then
    echo "⚠️  警告: 训练图像较少（少于100张）"
    echo "建议准备 1000-2000 张图像以获得最佳效果"
    echo ""
    read -p "是否继续训练? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 设置参数（可根据 GPU 调整）
EPOCHS=2
BATCH_SIZE=8
IMAGE_SIZE=256

echo ""
echo "训练参数:"
echo "  Epochs: $EPOCHS"
echo "  Batch Size: $BATCH_SIZE"
echo "  Image Size: $IMAGE_SIZE"
echo "  训练图像: $TRAIN_COUNT 张"
echo ""

# 开始训练
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/best_model.pth \
    --epochs $EPOCHS \
    --batch-size $BATCH_SIZE \
    --image-size $IMAGE_SIZE \
    --content-weight 1.0 \
    --style-weight 1e5 \
    --tv-weight 1e-6 \
    --log-file logs/train_loss.csv \
    --sample-output results/samples/train_sample.png \
    --device auto

echo ""
echo "=========================================="
echo "训练完成！"
echo "=========================================="
echo "模型保存: checkpoints/best_model.pth"
echo "训练日志: logs/train_loss.csv"
echo "训练样例: results/samples/train_sample.png"
echo ""
echo "下一步:"
echo "  1. 查看训练日志: cat logs/train_loss.csv"
echo "  2. 测试模型: bash scripts/test_all.sh"

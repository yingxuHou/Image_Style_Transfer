#!/bin/bash
# 快速训练测试脚本 - 用现有数据快速验证代码可运行

echo "=========================================="
echo "快速训练测试（10 步，仅验证代码）"
echo "=========================================="

# 检查训练数据
TRAIN_COUNT=$(find data/train_images -name "*.JPG" -o -name "*.jpg" -o -name "*.png" | wc -l)
echo "训练图像数量: $TRAIN_COUNT"

if [ "$TRAIN_COUNT" -lt 5 ]; then
    echo "⚠️  警告: 训练图像太少（少于5张），仅作代码测试"
fi

# 快速训练（10步）
python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/test_model.pth \
    --epochs 1 \
    --batch-size 2 \
    --image-size 256 \
    --max-steps 10 \
    --log-file logs/test_train.csv \
    --sample-output results/samples/test_sample.png

echo ""
echo "=========================================="
echo "训练测试完成！"
echo "=========================================="
echo "模型保存: checkpoints/test_model.pth"
echo "日志保存: logs/test_train.csv"
echo "样例保存: results/samples/test_sample.png"
echo ""
echo "下一步: 运行 'bash scripts/test_quick.sh' 测试推理"

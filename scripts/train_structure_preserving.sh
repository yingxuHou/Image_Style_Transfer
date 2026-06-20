#!/bin/bash
# 结构保持的风格迁移训练
# 基于详细分析的最佳参数配置

echo "=========================================="
echo "结构保持风格迁移训练"
echo "=========================================="
echo ""
echo "核心改进："
echo "  1. style_weight 降低到 1e4（原来 1e5）"
echo "  2. content_weight 提升到 5.0（原来 2.0）"
echo "  3. TV weight 提升到 1e-4（原来 1e-6，增强 100 倍）"
echo "  4. 浅层 style loss 降权（代码内部修复）"
echo "  5. 训练 30 epochs（原来 15）"
echo ""
echo "目标：保持建筑结构 + 艺术笔触风格"
echo "=========================================="
echo ""

python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_structure_preserving.pth \
    --epochs 30 \
    --batch-size 4 \
    --image-size 512 \
    --content-weight 5.0 \
    --style-weight 1e4 \
    --tv-weight 1e-4 \
    --log-file logs/train_structure_preserving.csv \
    --sample-output results/samples/sample_structure_preserving.png \
    --device auto

echo ""
echo "=========================================="
echo "训练完成！"
echo "=========================================="
echo "模型保存: checkpoints/model_structure_preserving.pth"
echo "训练日志: logs/train_structure_preserving.csv"
echo ""
echo "测试命令:"
echo "python3 test.py \\"
echo "    --model checkpoints/model_structure_preserving.pth \\"
echo "    --input data/test_images/test.jpg \\"
echo "    --output results/output_structure_preserving.png \\"
echo "    --image-size 672"

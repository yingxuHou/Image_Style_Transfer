#!/bin/bash
# 训练一个 content_weight 更高的模型
# 目标：保留更多细节

echo "开始训练高 content_weight 模型（保留更多细节）"
echo "参数: content_weight=5.0, style_weight=1e5, epochs=20, image_size=512"
echo ""

python3 train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/model_high_content.pth \
    --epochs 20 \
    --batch-size 4 \
    --image-size 512 \
    --content-weight 5.0 \
    --style-weight 1e5 \
    --tv-weight 1e-6 \
    --log-file logs/train_high_content.csv \
    --sample-output results/samples/sample_high_content.png \
    --device auto

echo ""
echo "训练完成！"
echo "模型保存: checkpoints/model_high_content.pth"
echo "训练日志: logs/train_high_content.csv"
echo ""
echo "测试命令:"
echo "python3 test.py --model checkpoints/model_high_content.pth --input data/test_images/test.jpg --output results/output_high_content.png --image-size 672"

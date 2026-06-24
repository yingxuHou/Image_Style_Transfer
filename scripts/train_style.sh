#!/bin/bash
# 成品训练脚本:用最终视觉推荐配置训练一个新风格模型
# 用法:
#   bash scripts/train_style.sh <风格图路径> <输出名称> [比例]
# 示例:
#   bash scripts/train_style.sh data/style_images/vangogh.jpg vangogh
#   bash scripts/train_style.sh data/style_images/ink.jpg ink 250
#
# 配置来自比例扫描实验(scripts/ratio_sweep.sh)的结论:
#   16 epoch / 512 / batch16 / tv=1e-4 / lr=1e-3,content_weight=10
#   默认比例 250:1(style_weight=2500),细节保留最佳；500:1 可作为风格更明显的平衡备选
#   带 best-checkpoint:每 epoch 末在验证图上评估,只保留最优(避开训练尖峰)
set -e
cd "$(dirname "$0")/.."
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

STYLE_IMG="${1:?用法: bash scripts/train_style.sh <风格图路径> <输出名称> [比例,默认250]}"
NAME="${2:?用法: bash scripts/train_style.sh <风格图路径> <输出名称> [比例,默认250]}"
RATIO="${3:-250}"                 # content:style 比例,可选 250 / 500 / 1000

CONTENT_W=10
STYLE_W=$(( CONTENT_W * RATIO ))  # style_weight = content_weight * ratio
EPOCHS=16
BATCH=16
SIZE=512
TV_W=1e-4
VAL_IMG=data/test_images/test.jpg

CKPT=checkpoints/${NAME}.pth
mkdir -p checkpoints results/samples results/comparisons logs

echo "=========================================="
echo "训练风格模型: $NAME"
echo "  风格图:     $STYLE_IMG"
echo "  比例:       ${RATIO}:1  (content=$CONTENT_W, style=$STYLE_W)"
echo "  配置:       ${EPOCHS}ep / ${SIZE} / batch${BATCH} / tv=$TV_W"
echo "  输出模型:   $CKPT"
echo "=========================================="

python3 train.py \
  --train-dir data/train_images \
  --style-image "$STYLE_IMG" \
  --output "$CKPT" \
  --epochs $EPOCHS --batch-size $BATCH --image-size $SIZE \
  --content-weight $CONTENT_W --style-weight $STYLE_W --tv-weight $TV_W \
  --val-image "$VAL_IMG" \
  --log-file "logs/${NAME}.csv" \
  --sample-output "results/samples/${NAME}_sample.png" \
  --num-workers 4 --device auto

echo ""
echo "训练完成,在测试图上生成效果..."
python3 test.py \
  --model "$CKPT" \
  --input data/test_images/test.jpg \
  --output "results/comparisons/${NAME}_output.png" \
  --style-image "$STYLE_IMG" \
  --image-size 672

echo ""
echo "=========================================="
echo "完成!"
echo "  模型: $CKPT"
echo "  效果: results/comparisons/${NAME}_output.png"
echo "=========================================="

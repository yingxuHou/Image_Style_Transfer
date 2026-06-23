#!/bin/bash
# 比例扫描实验:content:style = 250:1 / 500:1 / 1000:1
# 固定 content_weight=10,变 style_weight ∈ {2500, 5000, 10000}
# 成品级配置:16 epoch / 512 / batch16 / tv=1e-4,带 best-checkpoint(每 epoch 末验证,只留最优)
set -e
cd "$(dirname "$0")/.."
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

EPOCHS=16
BATCH=16
SIZE=512
CONTENT_W=10
TV_W=1e-4
STYLE_IMG=data/style_images/style.jpg
VAL_IMG=data/test_images/test.jpg     # 每 epoch 末用于选最优 checkpoint
TEST1=data/test_images/test.jpg
TEST2=data/test_images/test1.JPG
METRICS=results/experiments/ratio_sweep.csv

CKPT_DIR=checkpoints/experiments
OUT_DIR=results/experiments
mkdir -p "$CKPT_DIR" "$OUT_DIR"
rm -f "$METRICS"

# style_weight -> 比例标签
declare -A RATIO=( [2500]="250to1" [5000]="500to1" [10000]="1000to1" )

for SW in 2500 5000 10000; do
  TAG="ratio_${RATIO[$SW]}"
  echo ""
  echo "=========================================="
  echo "训练 $TAG  (content=$CONTENT_W style=$SW, 比例 $((SW/CONTENT_W)):1)"
  echo "=========================================="
  python3 train.py \
    --train-dir data/train_images \
    --style-image "$STYLE_IMG" \
    --output "$CKPT_DIR/${TAG}.pth" \
    --epochs $EPOCHS --batch-size $BATCH --image-size $SIZE \
    --content-weight $CONTENT_W --style-weight $SW --tv-weight $TV_W \
    --val-image "$VAL_IMG" \
    --log-file "logs/${TAG}.csv" \
    --sample-output "$OUT_DIR/${TAG}_sample.png" \
    --num-workers 4 --device auto

  # 两张测试图都评估
  python3 test.py --model "$CKPT_DIR/${TAG}.pth" --input "$TEST1" \
    --output "$OUT_DIR/${TAG}_out_test.png" --style-image "$STYLE_IMG" \
    --image-size 672 --metrics "$METRICS"
  python3 test.py --model "$CKPT_DIR/${TAG}.pth" --input "$TEST2" \
    --output "$OUT_DIR/${TAG}_out_test1.png" --style-image "$STYLE_IMG" \
    --image-size 672 --metrics "$METRICS"
done

echo ""
echo "=========================================="
echo "扫描完成。指标:"
cat "$METRICS"

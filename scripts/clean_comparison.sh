#!/bin/bash
# 干净的对比实验：固定全部参数,只变 style_weight (1e4 / 1e5 / 1e6)
# 三组均从头训练,确保可比性。结果写入独立的 metrics 文件,不污染历史数据。
set -e
cd "$(dirname "$0")/.."

# ---- 统一固定参数 ----
EPOCHS=2
BATCH=8
SIZE=256
CONTENT_W=1.0
TV_W=1e-6
TEST_IMG=data/test_images/test.jpg
STYLE_IMG=data/style_images/style.jpg
METRICS=results/experiments/comparison_clean.csv

CKPT_DIR=checkpoints/experiments
OUT_DIR=results/experiments
mkdir -p "$CKPT_DIR" "$OUT_DIR"

# 重新开始 metrics 文件
rm -f "$METRICS"

N=$(find data/train_images -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | wc -l)
echo "=========================================="
echo "干净对比实验 (style_weight)"
echo "固定: epochs=$EPOCHS batch=$BATCH size=$SIZE content_w=$CONTENT_W tv_w=$TV_W"
echo "训练图像: $N 张"
echo "=========================================="

for SW in 1e4 1e5 1e6; do
  TAG="sw${SW}"
  echo ""
  echo "---- 训练 style_weight=$SW ----"
  python3 train.py \
    --train-dir data/train_images \
    --style-image "$STYLE_IMG" \
    --output "$CKPT_DIR/clean_${TAG}.pth" \
    --epochs $EPOCHS --batch-size $BATCH --image-size $SIZE \
    --content-weight $CONTENT_W --style-weight $SW --tv-weight $TV_W \
    --log-file "logs/clean_${TAG}.csv" \
    --sample-output "$OUT_DIR/clean_sample_${TAG}.png" \
    --device auto

  echo "---- 测试 style_weight=$SW ----"
  python3 test.py \
    --model "$CKPT_DIR/clean_${TAG}.pth" \
    --input "$TEST_IMG" \
    --output "$OUT_DIR/clean_output_${TAG}.png" \
    --style-image "$STYLE_IMG" \
    --image-size 512 \
    --metrics "$METRICS"
done

echo ""
echo "=========================================="
echo "完成。指标汇总:"
echo "=========================================="
cat "$METRICS"

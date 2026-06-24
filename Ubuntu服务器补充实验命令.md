# Ubuntu 服务器补充实验命令：125/150/200:1 比例扫描

目的：在当前 250:1 效果最好的基础上，继续向“更保留内容细节、更弱风格”的方向扫描 125:1、150:1、200:1，观察黄色是否不再集中到高亮点，并判断最终推荐是否需要从 250:1 改为 150:1 或 200:1。

以下命令假设你已经在 Ubuntu 服务器上进入项目根目录：

```bash
cd /path/to/Image_Style_Transfer
```

如果你的服务器项目目录是之前报告里的路径，可以是：

```bash
cd /home/yxhou/medium-project
```

## 1. 先确认环境和数据

```bash
python3 -c "import torch, torchvision; print(torch.__version__, torchvision.__version__, torch.cuda.is_available())"
ls data/style_images/style.jpg
ls data/test_images/test.jpg data/test_images/test1.JPG data/test_images/test2.png
find data/train_images -type f | wc -l
```

如果 `torch.cuda.is_available()` 输出 `True`，说明会用 GPU 跑。

## 2. 建议先开一个 tmux，防止 SSH 断开

```bash
tmux new -s style_ratio
```

中途离开：按 `Ctrl+B`，再按 `D`。  
重新进入：

```bash
tmux attach -t style_ratio
```

## 3. 创建输出目录

```bash
mkdir -p checkpoints/experiments logs results/experiments results/samples
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
```

## 4. 训练 125:1、150:1、200:1 三组模型

说明：这里保持正式实验配置不变，只改 `style_weight`。因为 `content_weight=10`，所以：

- 125:1 -> `style_weight=1250`
- 150:1 -> `style_weight=1500`
- 200:1 -> `style_weight=2000`

###  100:1
紧急加了一个100的，
训练命令为：
```
python3 train.py \
  --train-dir data/train_images \
  --style-image data/style_images/style.jpg \
  --output checkpoints/experiments/ratio_100to1.pth \
  --epochs 16 \
  --batch-size 16 \
  --image-size 512 \
  --content-weight 10 \
  --style-weight 1000 \
  --tv-weight 1e-4 \
  --val-image data/test_images/test.jpg \
  --log-file logs/ratio_100to1.csv \
  --sample-output results/samples/ratio_100to1_sample.png \
  --num-workers 4 \
  --device auto
```
![1782300155963](image/Ubuntu服务器补充实验命令/1782300155963.png)

### 125:1

```bash
python3 train.py \
  --train-dir data/train_images \
  --style-image data/style_images/style.jpg \
  --output checkpoints/experiments/ratio_125to1.pth \
  --epochs 16 \
  --batch-size 16 \
  --image-size 512 \
  --content-weight 10 \
  --style-weight 1250 \
  --tv-weight 1e-4 \
  --val-image data/test_images/test.jpg \
  --log-file logs/ratio_125to1.csv \
  --sample-output results/samples/ratio_125to1_sample.png \
  --num-workers 4 \
  --device auto
```
目前在跑这个……跑完了
![1782294561064](image/Ubuntu服务器补充实验命令/1782294561064.png)

### 150:1

```bash
python3 train.py \
  --train-dir data/train_images \
  --style-image data/style_images/style.jpg \
  --output checkpoints/experiments/ratio_150to1.pth \
  --epochs 16 \
  --batch-size 16 \
  --image-size 512 \
  --content-weight 10 \
  --style-weight 1500 \
  --tv-weight 1e-4 \
  --val-image data/test_images/test.jpg \
  --log-file logs/ratio_150to1.csv \
  --sample-output results/samples/ratio_150to1_sample.png \
  --num-workers 4 \
  --device auto
```

### 200:1

```bash
python3 train.py \
  --train-dir data/train_images \
  --style-image data/style_images/style.jpg \
  --output checkpoints/experiments/ratio_200to1.pth \
  --epochs 16 \
  --batch-size 16 \
  --image-size 512 \
  --content-weight 10 \
  --style-weight 2000 \
  --tv-weight 1e-4 \
  --val-image data/test_images/test.jpg \
  --log-file logs/ratio_200to1.csv \
  --sample-output results/samples/ratio_200to1_sample.png \
  --num-workers 4 \
  --device auto
```

## 5. 测试三张测试图

为了和原实验一致，推理尺寸继续用 `672`，并把指标统一写到 `results/experiments/ratio_low_style_sweep.csv`。

### 125:1 测试

```bash
python3 test.py --model checkpoints/experiments/ratio_125to1.pth --input data/test_images/test.jpg  --output results/experiments/ratio_125to1_out_test.png  --style-image data/style_images/style.jpg --image-size 672 --metrics results/experiments/ratio_low_style_sweep.csv --device auto
python3 test.py --model checkpoints/experiments/ratio_125to1.pth --input data/test_images/test1.JPG --output results/experiments/ratio_125to1_out_test1.png --style-image data/style_images/style.jpg --image-size 672 --metrics results/experiments/ratio_low_style_sweep.csv --device auto
python3 test.py --model checkpoints/experiments/ratio_125to1.pth --input data/test_images/test2.png --output results/experiments/ratio_125to1_out_test2.png --style-image data/style_images/style.jpg --image-size 672 --metrics results/experiments/ratio_low_style_sweep.csv --device auto
```
![1782294649714](image/Ubuntu服务器补充实验命令/1782294649714.png)



### 150:1 测试

```bash
python3 test.py --model checkpoints/experiments/ratio_150to1.pth --input data/test_images/test.jpg  --output results/experiments/ratio_150to1_out_test.png  --style-image data/style_images/style.jpg --image-size 672 --metrics results/experiments/ratio_low_style_sweep.csv --device auto
python3 test.py --model checkpoints/experiments/ratio_150to1.pth --input data/test_images/test1.JPG --output results/experiments/ratio_150to1_out_test1.png --style-image data/style_images/style.jpg --image-size 672 --metrics results/experiments/ratio_low_style_sweep.csv --device auto
python3 test.py --model checkpoints/experiments/ratio_150to1.pth --input data/test_images/test2.png --output results/experiments/ratio_150to1_out_test2.png --style-image data/style_images/style.jpg --image-size 672 --metrics results/experiments/ratio_low_style_sweep.csv --device auto
```

### 200:1 测试

```bash
python3 test.py --model checkpoints/experiments/ratio_200to1.pth --input data/test_images/test.jpg  --output results/experiments/ratio_200to1_out_test.png  --style-image data/style_images/style.jpg --image-size 672 --metrics results/experiments/ratio_low_style_sweep.csv --device auto
python3 test.py --model checkpoints/experiments/ratio_200to1.pth --input data/test_images/test1.JPG --output results/experiments/ratio_200to1_out_test1.png --style-image data/style_images/style.jpg --image-size 672 --metrics results/experiments/ratio_low_style_sweep.csv --device auto
python3 test.py --model checkpoints/experiments/ratio_200to1.pth --input data/test_images/test2.png --output results/experiments/ratio_200to1_out_test2.png --style-image data/style_images/style.jpg --image-size 672 --metrics results/experiments/ratio_low_style_sweep.csv --device auto
```

## 6. 可选：把 125/150/200/250 放一起生成对比图

如果服务器上有 Python + Pillow，可以直接运行下面脚本生成 `results/experiments/ratio_low_style_comparison.png`：

```bash
python3 - <<'PY'
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path('.')
items = []
for test_name in ['test', 'test1', 'test2']:
    for ratio in ['125', '150', '200', '250']:
        p = root / 'results' / 'experiments' / f'ratio_{ratio}to1_out_{test_name}.png'
        if p.exists():
            items.append((test_name, ratio, p))

thumb_w = 300
pad = 16
label_h = 42
cols = 4
rows = (len(items) + cols - 1) // cols
font = ImageFont.load_default()
thumbs = []
for test_name, ratio, p in items:
    img = Image.open(p).convert('RGB')
    h = int(img.height * thumb_w / img.width)
    img = img.resize((thumb_w, h), Image.LANCZOS)
    panel = Image.new('RGB', (thumb_w, h + label_h), 'white')
    panel.paste(img, (0, 0))
    d = ImageDraw.Draw(panel)
    d.text((8, h + 8), f'{test_name} | {ratio}:1', fill=(20, 20, 20), font=font)
    thumbs.append(panel)

if thumbs:
    panel_h = thumbs[0].height
    canvas = Image.new('RGB', (cols * thumb_w + (cols - 1) * pad, rows * panel_h + (rows - 1) * pad), (245, 247, 250))
    for i, panel in enumerate(thumbs):
        x = (i % cols) * (thumb_w + pad)
        y = (i // cols) * (panel_h + pad)
        canvas.paste(panel, (x, y))
    out = root / 'results' / 'experiments' / 'ratio_low_style_comparison.png'
    canvas.save(out)
    print('saved', out)
else:
    print('no images found')
PY
```

## 7. 训练完成后看结果

```bash
cat results/experiments/ratio_low_style_sweep.csv
ls -lh results/experiments/ratio_*to1_out_test*.png
ls -lh results/experiments/ratio_low_style_comparison.png
```

重点看：

1. `125:1 / 150:1 / 200:1` 是否比 `250:1` 更保留原图细节。
2. 黄色是否仍然集中在两个高亮点。
3. 风格是否已经弱到“不明显”。
4. 如果 `150:1` 比 `250:1` 更自然，就把最终推荐改成 `150:1`；如果风格太弱，就保留 `250:1`。

## 8. 提交到 GitHub

如果 `.pth` 已经通过 Git LFS 管理，可以提交模型；如果不想提交大权重，只提交结果图和 CSV。

```bash
git status

git add logs/ratio_125to1.csv logs/ratio_150to1.csv logs/ratio_200to1.csv
git add results/experiments/ratio_low_style_sweep.csv
git add results/experiments/ratio_125to1_out_test*.png
git add results/experiments/ratio_150to1_out_test*.png
git add results/experiments/ratio_200to1_out_test*.png
git add results/experiments/ratio_low_style_comparison.png

# 如果要提交权重，再取消下面三行注释
# git add checkpoints/experiments/ratio_125to1.pth
# git add checkpoints/experiments/ratio_150to1.pth
# git add checkpoints/experiments/ratio_200to1.pth

git commit -m "Add low-style ratio sweep results"
git push
```

## 9. 如果显存不足

优先把 batch size 从 16 降到 8：

```bash
--batch-size 8
```

其他参数先不要动，否则和原实验不够可比。

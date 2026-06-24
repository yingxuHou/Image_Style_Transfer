# Fast Neural Style - 图像风格迁移项目

基于 PyTorch 从零实现的 Fast Neural Style Transfer 训练、推理与对比实验项目。项目核心目标是训练一个前馈图像转换网络（TransformNet），在冻结的 VGG16 感知损失约束下学习指定艺术风格，并记录 `content_loss`、`style_loss` 与 `delta_time` 等实验指标。

## 项目概述

- **课程实验**：智能计算系统期中项目
- **方法路线**：Johnson et al. Fast Neural Style，前馈网络 + 感知损失
- **核心实现**：TransformNet、VGG16 特征提取器、Gram 风格损失、TV 平滑损失
- **最终配置**：512 分辨率、16 epoch、batch size 16、`content_weight=10`、`style_weight=2500`
- **最佳比例**：content:style = 250:1（细节保留最佳）；500:1 为风格更明显的平衡备选
- **推理速度**：约 0.09 s/张（RTX 4090 D，672 长边推理）

## 快速开始

### 1. 环境准备

```bash
pip install -r requirements.txt
python -c "import torch; print(torch.__version__, torch.cuda.is_available())"
```

依赖主要包括：`torch`、`torchvision`、`pillow`、`numpy`、`matplotlib`、`tqdm`、`pandas`。

### 2. 数据准备

本实验正式训练使用 Natural Images（Kaggle）数据集，共 6,912 张自然图像。为避免提交包过大，`data/downloads/` 与完整训练集不建议随课程作业提交。

当前目录约定如下：

| 路径 | 作用 | 提交建议 |
|---|---|---|
| `data/train_images/` | 训练脚本默认读取目录；正式训练前需放入训练图像 | 可保留空目录和 `.gitkeep`，不提交完整数据集 |
| `data/style_images/style.jpg` | 风格图像 | 若老师要求项目可直接运行，建议提交 |
| `data/test_images/test.jpg`, `test1.JPG`, `test2.png` | 测试图像 | 若老师要求项目可直接运行，建议提交 |
| `data/downloads/` | Kaggle 原始下载与解压目录 | 不建议提交，体积大且非核心代码 |

下载并准备训练数据：

```bash
bash scripts/download_training_data.sh
```

如果下载脚本中的绝对路径与本机目录不同，可将 Natural Images 解压后的图片复制到：

```text
data/train_images/
```

### 3. 快速验证代码

```bash
bash scripts/train_quick.sh
bash scripts/test_quick.sh
```

快速脚本用于验证环境与代码链路，不代表报告中的最终实验配置。

### 4. 复现实验配置

```bash
bash scripts/ratio_sweep.sh
```

该脚本会训练 250:1、500:1、1000:1 三组 content:style 比例，并输出日志、权重和对比结果。

训练单个新风格模型：

```bash
bash scripts/train_style.sh data/style_images/style.jpg my_style 250
```

### 5. 推理测试

```bash
python test.py \
  --model checkpoints/experiments/ratio_250to1.pth \
  --input data/test_images/test.jpg \
  --output results/output.png \
  --style-image data/style_images/style.jpg \
  --image-size 672
```

输出会包含风格化图像，并在控制台或 CSV 中记录 `delta_time`、`content_loss`、`style_loss`、`tv_loss`。

## 项目结构

```text
Image_Style_Transfer/
├── models/                    # 模型实现
│   ├── transform_net.py       # TransformNet 图像转换网络
│   └── vgg.py                 # VGG16 特征提取网络
├── utils/                     # 数据、图像与损失函数
│   ├── dataset.py
│   ├── image.py
│   └── loss.py
├── scripts/                   # 训练、测试、对比实验脚本
│   ├── ratio_sweep.sh
│   ├── train_style.sh
│   ├── train_quick.sh
│   └── test_quick.sh
├── results/                   # 报告引用的结果图与 CSV
│   ├── before_after_comparison.png
│   ├── epochs_comparison.png
│   ├── resolution_comparison.png
│   ├── style_weight_comparison.png
│   ├── experiments/ratio_250to1_out_test.png
│   ├── experiments/ratio_500to1_out_test.png
│   └── experiments/ratio_sweep_comparison.png
├── data/                      # 运行时数据目录，完整训练集不建议提交
├── checkpoints/               # 模型权重目录；大文件可用 Git LFS 或按脚本重训
├── logs/                      # 训练日志目录；精简提交可只交关键 CSV
├── train.py                   # 训练入口
├── test.py                    # 推理/评估入口
├── test_stretch.py            # 拉伸/比例测试入口
├── config.py                  # 默认配置
├── requirements.txt
├── 实验报告.md
├── 实验报告.pdf
└── 提交说明.md
```

## 实验结果摘要

正式比例扫描固定 16 epoch、512 分辨率、batch size 16、`content_weight=10`、`tv_weight=1e-4`，只改变 `style_weight`：

| content:style | 最优 epoch | 内容保持 | 风格强度 | 结论 |
|---|---:|---|---|---|
| 250:1 | 8 | 最好 | 较克制 | 最终推荐，细节处理最好 |
| 500:1 | 6 | 均衡 | 更明显 | 平衡备选 |
| 1000:1 | 3 | 较弱 | 最强 | 艺术化更强但细节损失更多 |

关键结果图见：

- `results/experiments/ratio_sweep_comparison.png`
- `results/style_weight_comparison.png`
- `results/resolution_comparison.png`
- `results/before_after_comparison.png`
- `results/experiments/ratio_250to1_out_test.png`（最终推荐，细节最佳）
- `results/experiments/ratio_500to1_out_test.png`（风格更明显的平衡备选）
- `results/experiments/ratio_sweep_test2_comparison.png`（新增 test2 三组比例对比）
- `results/experiments/test2_all_models_comparison.png`（新增 test2 全模型复测对比）

## 提交说明

建议按 `提交说明.md` 中的精简结构提交：保留代码、脚本、README、实验报告 PDF/Markdown、报告引用的结果图和关键 CSV；不提交 `data/downloads/`、`archive/`、`.claude/` 等过程或工具目录。

如果课程平台要求“项目可运行”，请额外确认以下文件存在：

- `data/style_images/style.jpg`
- `data/test_images/test.jpg`
- `data/test_images/test1.JPG`
- 训练数据已下载或已复制到 `data/train_images/`

## 参考文献

1. Johnson et al. (2016). *Perceptual Losses for Real-Time Style Transfer and Super-Resolution*. ECCV 2016.
2. Gatys et al. (2015). *A Neural Algorithm of Artistic Style*. arXiv:1508.06576.
3. Ulyanov et al. (2016). *Instance Normalization: The Missing Ingredient for Fast Stylization*. arXiv:1607.08022.

---

**硬件配置**：RTX 4090 D (24GB)  
**报告日期**：2026-06-19 ~ 2026-06-23




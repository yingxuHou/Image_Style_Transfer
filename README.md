# Fast Neural Style - 图像风格迁移项目

基于 PyTorch 实现的 Fast Neural Style 图像风格迁移模型训练与评估

## 项目概述

- **实验类型**: 智能计算系统期中实验
- **技术方案**: PyTorch Fast Neural Style（从零实现）
- **目标**: 训练风格迁移模型，记录损失值和推理时间

## 快速开始

### 1. 环境准备

```bash
# 检查环境
python -c "import torch; print(f'PyTorch: {torch.__version__}')"
python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"

# 安装依赖（如果需要）
pip install torch torchvision pillow tqdm
```

### 2. 数据准备

当前数据状态：
- ✅ 风格图像: `data/style_images/style.jpg` (1张)
- ⚠️ 训练图像: `data/train_images/` (13张 - **需要扩充到 1000-2000张**)
- ✅ 测试图像: `data/test_images/` (1张 - 建议增加到 3-5张)

**扩充训练数据**:
- 下载 ImageNet 子集或 COCO 数据集
- 解压到 `data/train_images/` 目录
- 支持格式: jpg, jpeg, png, bmp

### 3. 快速测试（验证代码可运行）

```bash
# 快速训练测试（10步，2分钟）
bash scripts/train_quick.sh

# 快速推理测试
bash scripts/test_quick.sh
```

### 4. 正式训练

```bash
# 完整训练（需要 1000+ 张训练图像，2-4 小时）
bash scripts/train_full.sh
```

### 5. 批量测试

```bash
# 测试所有测试图像
bash scripts/test_all.sh
```

## 项目结构

```
medium-project/
├── models/                    # 模型实现
│   ├── transform_net.py       # TransformNet（图像转换网络）
│   └── vgg.py                 # VGG16（特征提取网络）
├── utils/                     # 工具函数
│   ├── loss.py                # 损失函数（Gram矩阵、TV loss）
│   ├── image.py               # 图像处理
│   └── dataset.py             # 数据加载
├── scripts/                   # 快速启动脚本
│   ├── train_quick.sh         # 快速训练测试
│   ├── train_full.sh          # 正式训练
│   ├── test_quick.sh          # 快速推理测试
│   └── test_all.sh            # 批量测试
├── data/                      # 数据目录
│   ├── style_images/          # 风格图像
│   ├── train_images/          # 训练图像
│   └── test_images/           # 测试图像
├── checkpoints/               # 模型权重
├── results/                   # 实验结果
│   ├── samples/               # 训练样例
│   ├── comparisons/           # 对比图
│   └── metrics.csv            # 性能指标
├── logs/                      # 训练日志
├── study/                     # 学习笔记
├── doc/                       # 实验文档
├── train.py                   # 训练脚本
├── test.py                    # 测试脚本
└── config.py                  # 配置文件
```

## 使用说明

### 训练

```bash
python train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --output checkpoints/best_model.pth \
    --epochs 2 \
    --batch-size 8 \
    --image-size 256
```

**主要参数**:
- `--train-dir`: 训练图像目录
- `--style-image`: 风格图像路径
- `--epochs`: 训练轮数（建议 2-4）
- `--batch-size`: 批大小（RTX 4090 可用 8-16）
- `--image-size`: 图像尺寸（256 或 512）
- `--content-weight`: 内容损失权重（默认 1.0）
- `--style-weight`: 风格损失权重（默认 1e5）
- `--tv-weight`: TV 损失权重（默认 1e-6）

### 测试

```bash
python test.py \
    --model checkpoints/best_model.pth \
    --input data/test_images/test.jpg \
    --output results/output.png \
    --style-image data/style_images/style.jpg \
    --image-size 512
```

**输出内容**:
- 风格化图像
- `delta_time`: 推理时间
- `content_loss`: 内容损失
- `style_loss`: 风格损失
- `tv_loss`: 总变差损失

## 实验记录

### 必须记录的指标

实验要求必须记录：
- ✅ `content_loss` 或 `style_loss`（至少一项）
- ✅ `delta_time`（推理时间）

训练时自动记录到 `logs/train_loss.csv`:
- `step`, `epoch`, `total_loss`, `content_loss`, `style_loss`, `tv_loss`

测试时自动记录到 `results/metrics.csv`:
- `input`, `output`, `delta_time`, `content_loss`, `style_loss`, `tv_loss`

## 模型架构

### TransformNet（图像转换网络）
- **编码器**: 3 层卷积（3→32→64→128）
- **残差层**: 5 个残差块
- **解码器**: 2 层上采样（128→64→32→3）
- **归一化**: Instance Normalization
- **参数量**: 约 1.7M

### VGG16（特征提取网络）
- 预训练权重（ImageNet）
- 参数冻结（不训练）
- 提取 4 层特征：relu1_2, relu2_2, relu3_3, relu4_3
- 用于计算内容损失和风格损失

## 文档资源

- `PROJECT_PLAN.md` - 项目总体计划
- `实施指南与答疑.md` - 核心问题解答
- `项目整理报告.md` - 代码整理分析
- `doc/实验要求.md` - 实验要求详情
- `doc/算法理论基础.md` - 理论基础
- `doc/高分方案建议.md` - 高分策略
- `study/` - 学习笔记

## 常见问题

### Q: 训练需要多久？
A: 
- 快速测试（10步）: ~2 分钟
- 小规模（100张×1epoch）: ~20 分钟
- 正式训练（2000张×2epoch）: ~2-4 小时（RTX 4090 D）

### Q: 显存不够怎么办？
A:
- 减小 `--batch-size`（8→4→2）
- 减小 `--image-size`（256→128）

### Q: 训练数据从哪来？
A:
- ImageNet 子集（推荐）
- MS-COCO 数据集
- Kaggle 公开数据集
- 自己收集自然图像

### Q: 风格效果不好怎么办？
A:
- 增大 `--style-weight`（1e5 → 1e6）
- 训练更多轮次
- 更换更有特色的风格图像

## 实验要求检查清单

- [ ] ✅ 训练出风格迁移模型
- [ ] ✅ 记录 content_loss 和 style_loss
- [ ] ✅ 记录 delta_time（推理时间）
- [ ] ✅ 生成风格迁移结果图
- [ ] ⏳ 撰写实验报告（≥3页）
- [ ] ⏳ 整理代码和模型文件

## 参考文献

1. Johnson et al. (2016). *Perceptual Losses for Real-Time Style Transfer and Super-Resolution*. ECCV 2016.
2. Gatys et al. (2015). *A Neural Algorithm of Artistic Style*. arXiv:1508.06576.
3. Ulyanov et al. (2016). *Instance Normalization: The Missing Ingredient for Fast Stylization*. arXiv:1607.08022.

---

**硬件配置**: RTX 4090 D (24GB)  
**更新时间**: 2026-06-19

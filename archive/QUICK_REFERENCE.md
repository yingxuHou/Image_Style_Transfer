# 快速参考 - 常用命令

> 📌 项目路径：`/home/yxhou/medium-project`

## 🚀 快速开始（3步）

```bash
# 1. 快速训练测试（~2分钟）
bash scripts/train_quick.sh

# 2. 快速推理测试
bash scripts/test_quick.sh

# 3. 查看结果
cat results/test_metrics.csv
```

## 📊 检查状态

```bash
# GPU 状态
nvidia-smi

# 训练数据数量
find data/train_images -name "*.jpg" -o -name "*.JPG" -o -name "*.png" | wc -l

# 测试数据数量
find data/test_images -name "*.jpg" -o -name "*.JPG" -o -name "*.png" | wc -l

# 检查 PyTorch
python -c "import torch; print(f'PyTorch: {torch.__version__}, CUDA: {torch.cuda.is_available()}')"
```

## 🎯 正式训练

```bash
# 完整训练（需要 500+ 张训练图像）
bash scripts/train_full.sh

# 或手动指定参数
python train.py \
    --train-dir data/train_images \
    --style-image data/style_images/style.jpg \
    --epochs 2 \
    --batch-size 8 \
    --image-size 256 \
    --output checkpoints/best_model.pth
```

## 🧪 测试评估

```bash
# 批量测试所有图像
bash scripts/test_all.sh

# 测试单张图像
python test.py \
    --model checkpoints/best_model.pth \
    --input data/test_images/test.jpg \
    --output results/output.png \
    --image-size 512

# 查看性能指标
cat results/metrics.csv
```

## 📝 查看日志

```bash
# 训练日志
cat logs/train_loss.csv

# 实时查看训练（如果正在训练）
tail -f logs/train_loss.csv

# 查看最后 10 行
tail -n 10 logs/train_loss.csv
```

## 🗂️ 常用路径

```bash
# 数据
data/style_images/style.jpg          # 风格图
data/train_images/                   # 训练图
data/test_images/                    # 测试图

# 模型
checkpoints/test_model.pth           # 测试模型
checkpoints/best_model.pth           # 正式模型

# 结果
results/samples/                     # 训练样例
results/comparisons/                 # 对比图
results/metrics.csv                  # 性能指标

# 日志
logs/train_loss.csv                  # 训练日志

# 文档
README.md                            # 使用说明
CURRENT_STATUS.md                    # 当前状态
PROJECT_PLAN.md                      # 项目计划
doc/实验要求.md                       # 实验要求
study/                               # 学习笔记
```

## 🔧 常见问题

### 显存不足
```bash
# 减小 batch size
python train.py --batch-size 4

# 减小图像尺寸
python train.py --image-size 128
```

### 风格不明显
```bash
# 增大 style weight
python train.py --style-weight 1e6

# 训练更多轮
python train.py --epochs 4
```

### CPU 训练
```bash
python train.py --device cpu
```

## 📊 实验指标

### 必须记录
- ✅ `content_loss` - 内容损失
- ✅ `style_loss` - 风格损失
- ✅ `delta_time` - 推理时间（秒）

### 查看方式
```bash
# CSV 格式
cat results/metrics.csv

# 只看关键列
cat results/metrics.csv | cut -d',' -f1,6,7,8
# 输出：input, delta_time, content_loss, style_loss
```

## 🎨 对照实验

### 不同 style_weight
```bash
python train.py --style-weight 1e4 --output checkpoints/model_1e4.pth
python train.py --style-weight 1e5 --output checkpoints/model_1e5.pth
python train.py --style-weight 1e6 --output checkpoints/model_1e6.pth
```

### 不同分辨率
```bash
python test.py --image-size 256 --output results/output_256.png
python test.py --image-size 512 --output results/output_512.png
```

## 🗑️ 清理

```bash
# 清理测试文件
rm checkpoints/test_model.pth
rm logs/test_train.csv
rm results/test_metrics.csv

# 清理缓存
rm -rf __pycache__
find . -name "*.pyc" -delete
```

## 📚 参考文档

```bash
# 查看 README
cat README.md

# 查看当前状态
cat CURRENT_STATUS.md

# 查看实验要求
cat doc/实验要求.md

# 查看学习笔记
ls study/
```

## ⚡ 完整流程

```bash
# 1. 检查环境
nvidia-smi
python -c "import torch; print(torch.cuda.is_available())"

# 2. 准备数据（关键！需要 500-2000 张训练图）
# 下载到 data/train_images/

# 3. 快速测试
bash scripts/train_quick.sh
bash scripts/test_quick.sh

# 4. 正式训练
bash scripts/train_full.sh

# 5. 批量测试
bash scripts/test_all.sh

# 6. 查看结果
cat results/metrics.csv
ls results/comparisons/

# 7. 撰写报告
# 使用 logs/train_loss.csv 和 results/metrics.csv 中的数据
```

---

**当前状态**：代码完整，等待训练数据  
**下一步**：准备 500-2000 张训练图像  
**最后更新**：2026-06-19

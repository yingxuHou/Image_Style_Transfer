# Python 命令修复说明

## 问题
系统中只有 `python3` 命令，没有 `python` 命令。

## 已修复
所有脚本已更新为使用 `python3`：
- ✅ scripts/train_quick.sh
- ✅ scripts/train_real.sh  
- ✅ scripts/train_full.sh
- ✅ scripts/test_quick.sh
- ✅ scripts/test_all.sh

## 现在可以运行

```bash
# 真正训练（10-20 分钟）
bash scripts/train_real.sh

# 训练完成后测试
python3 test.py \
    --model checkpoints/real_model.pth \
    --input data/test_images/test.jpg \
    --output results/real_output.png \
    --image-size 512

# 查看指标
cat results/metrics.csv | tail -1
```

## 训练完成后你会得到

1. **模型文件**: `checkpoints/real_model.pth`
2. **训练日志**: `logs/real_train.csv`
3. **训练样例**: `results/samples/real_sample.png`
4. **测试输出**: `results/real_output.png` (能看出原图)

---

**更新时间**: 2026-06-19 20:00

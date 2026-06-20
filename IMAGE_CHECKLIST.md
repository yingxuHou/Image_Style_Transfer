# 实验图片清单

## 需要补充的图片位置

### 第一天实验

#### 实验 1.1: 最小数据集验证（失败）
- [ ] `results/real_output.png` - 失败案例输出
- [ ] `results/samples/real_sample.png` - 训练样本（噪声）

#### 实验 1.2-1.4: style_weight 对比
- [ ] `results/experiments/output_1e4.png` - 弱风格（style_weight=1e4）
- [ ] `results/experiments/output_1e5.png` - 中等风格（style_weight=1e5）
- [ ] `results/experiments/output_1e6.png` - 强风格（style_weight=1e6）
- [ ] `results/samples/sample_1e4.png` - 训练样本
- [ ] `results/samples/sample_1e6.png` - 训练样本
- [ ] `results/style_weight_comparison.png` - 三者对比图（需制作）

#### 实验 1.5-1.6: 训练轮数对比
- [ ] `results/output_10epochs.png` - 10 epochs 输出
- [ ] `results/output_15epochs.png` - 15 epochs 输出（512测试）
- [ ] `results/samples/sample_10epochs.png` - 训练样本
- [ ] `results/samples/sample_15epochs.png` - 训练样本
- [ ] `results/epochs_comparison.png` - 对比图（需制作）

### 第二天实验

#### 实验 2.1: 512×512 训练
- [ ] `results/output_512_final.png` - 512×512 训练输出
- [ ] `results/output_512_stretch.png` - 拉伸模式
- [ ] `results/output_512_aspect_ratio.png` - 保持宽高比
- [ ] `results/samples/sample_512_15epochs.png` - 训练样本

#### 实验 2.2: content_weight=2.0
- [ ] `results/output_512_content2x.png` - 最佳模型输出（有噪声问题）
- [ ] `results/samples/sample_512_content2x.png` - 训练样本

#### 实验 2.3: 新参数快速验证
- [ ] `results/output_quick_test.png` - 新参数验证输出
- [ ] `results/output_correct_model.png` - 原模型对比

### 对比图制作

需要制作的对比图：
1. [ ] style_weight 三者并排对比（1e4, 1e5, 1e6）
2. [ ] 训练轮数三者并排对比（2, 10, 15 epochs）
3. [ ] 分辨率对比（256测试 vs 512测试）
4. [ ] 新旧模型对比（修复前后）

---

## 快速检查脚本

```bash
#!/bin/bash
# 检查哪些图片已存在

echo "=== 实验图片存在性检查 ==="
echo ""

images=(
    "results/real_output.png"
    "results/samples/real_sample.png"
    "results/experiments/output_1e4.png"
    "results/experiments/output_1e5.png"
    "results/experiments/output_1e6.png"
    "results/samples/sample_1e4.png"
    "results/samples/sample_1e6.png"
    "results/output_10epochs.png"
    "results/output_15epochs.png"
    "results/samples/sample_10epochs.png"
    "results/samples/sample_15epochs.png"
    "results/output_512_final.png"
    "results/output_512_content2x.png"
    "results/samples/sample_512_content2x.png"
    "results/output_quick_test.png"
)

for img in "${images[@]}"; do
    if [ -f "$img" ]; then
        size=$(ls -lh "$img" | awk '{print $5}')
        echo "✅ $img ($size)"
    else
        echo "❌ $img"
    fi
done

echo ""
echo "=== 对比图（需手动制作） ==="
echo "❓ results/style_weight_comparison.png"
echo "❓ results/epochs_comparison.png"
echo "❓ results/resolution_comparison.png"
echo "❓ results/before_after_fix.png"

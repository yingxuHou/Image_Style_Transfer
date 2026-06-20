#!/usr/bin/env python3
# 预先下载 VGG16 权重

import os
os.environ['TORCH_HOME'] = os.path.expanduser('~/.cache/torch')
os.environ['XDG_CACHE_HOME'] = os.path.expanduser('~/.cache')

print("正在下载 VGG16 预训练权重...")
print(f"下载目录: {os.environ['TORCH_HOME']}")

from torchvision import models

# 下载 VGG16 权重
vgg = models.vgg16(weights=models.VGG16_Weights.IMAGENET1K_V1)
print("✅ VGG16 权重下载完成！")

# 测试加载
from models.vgg import Vgg16Features
vgg_features = Vgg16Features()
print("✅ VGG 特征提取器加载成功！")

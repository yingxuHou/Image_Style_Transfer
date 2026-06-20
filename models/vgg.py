from collections import namedtuple
import os

import torch
from torch import nn
from torchvision import models

# 强制设置 PyTorch 缓存目录到用户目录，避免权限问题
os.environ['TORCH_HOME'] = os.path.expanduser('~/.cache/torch')
os.environ['XDG_CACHE_HOME'] = os.path.expanduser('~/.cache')


VggOutputs = namedtuple("VggOutputs", ["relu1_2", "relu2_2", "relu3_3", "relu4_3"])


class Vgg16Features(nn.Module):
    def __init__(self):
        super().__init__()
        features = models.vgg16(weights=models.VGG16_Weights.IMAGENET1K_V1).features
        self.slice1 = nn.Sequential(*features[:4])
        self.slice2 = nn.Sequential(*features[4:9])
        self.slice3 = nn.Sequential(*features[9:16])
        self.slice4 = nn.Sequential(*features[16:23])
        for param in self.parameters():
            param.requires_grad = False

    def forward(self, x: torch.Tensor) -> VggOutputs:
        relu1_2 = self.slice1(x)
        relu2_2 = self.slice2(relu1_2)
        relu3_3 = self.slice3(relu2_2)
        relu4_3 = self.slice4(relu3_3)
        return VggOutputs(relu1_2, relu2_2, relu3_3, relu4_3)

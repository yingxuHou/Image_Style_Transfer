import torch
from torch import nn


def gram_matrix(features: torch.Tensor) -> torch.Tensor:
    batch, channels, height, width = features.shape
    flattened = features.view(batch, channels, height * width)
    gram = torch.bmm(flattened, flattened.transpose(1, 2))
    return gram / (channels * height * width)


def total_variation_loss(image: torch.Tensor) -> torch.Tensor:
    x_diff = image[:, :, :, 1:] - image[:, :, :, :-1]
    y_diff = image[:, :, 1:, :] - image[:, :, :-1, :]
    return torch.mean(torch.abs(x_diff)) + torch.mean(torch.abs(y_diff))


class PerceptualLoss(nn.Module):
    def __init__(self, content_weight: float, style_weight: float, tv_weight: float):
        super().__init__()
        self.content_weight = content_weight
        self.style_weight = style_weight
        self.tv_weight = tv_weight
        self.mse = nn.MSELoss()

        # 多层 style loss 权重：浅层降权，深层提权（关键修复！）
        # 避免浅层噪声主导
        self.style_layer_weights = [0.2, 0.3, 0.5, 1.0]  # relu1_2, relu2_2, relu3_3, relu4_3

    def forward(self, generated, content_features, generated_features, style_grams):
        # Content loss: 只用 relu3_3（保持结构）
        content_loss = self.mse(generated_features.relu3_3, content_features.relu3_3)

        # Style loss: 多层加权（浅层降权避免噪声）
        style_loss = 0.0
        for i, (generated_feature, target_gram) in enumerate(zip(generated_features, style_grams)):
            layer_loss = self.mse(gram_matrix(generated_feature), target_gram)
            style_loss = style_loss + self.style_layer_weights[i] * layer_loss

        # TV loss: 抑制噪声
        tv_loss = total_variation_loss(generated)

        total_loss = (
            self.content_weight * content_loss
            + self.style_weight * style_loss
            + self.tv_weight * tv_loss
        )
        return total_loss, content_loss, style_loss, tv_loss

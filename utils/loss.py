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

    def forward(self, generated, content_features, generated_features, style_grams):
        content_loss = self.mse(generated_features.relu3_3, content_features.relu3_3)
        style_loss = 0.0
        for generated_feature, target_gram in zip(generated_features, style_grams):
            style_loss = style_loss + self.mse(gram_matrix(generated_feature), target_gram)
        tv_loss = total_variation_loss(generated)
        total_loss = (
            self.content_weight * content_loss
            + self.style_weight * style_loss
            + self.tv_weight * tv_loss
        )
        return total_loss, content_loss, style_loss, tv_loss

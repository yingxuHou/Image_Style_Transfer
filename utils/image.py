from pathlib import Path

import torch
from PIL import Image
from torchvision import transforms


def load_image(path, image_size=None):
    image = Image.open(path).convert("RGB")
    steps = []
    if image_size:
        # 使用 Resize + CenterCrop 确保输出是正方形
        steps.append(transforms.Resize(image_size))
        steps.append(transforms.CenterCrop(image_size))
    steps.extend([transforms.ToTensor(), transforms.Lambda(lambda tensor: tensor * 255.0)])
    return transforms.Compose(steps)(image).unsqueeze(0)


def save_image(tensor: torch.Tensor, path):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    image = tensor.detach().cpu().clamp(0, 255).squeeze(0) / 255.0
    transforms.ToPILImage()(image).save(path)


def imagenet_preprocess_batch(batch: torch.Tensor) -> torch.Tensor:
    """Convert RGB [0, 255] tensors to BGR with VGG mean subtraction."""
    mean = batch.new_tensor([103.939, 116.779, 123.68]).view(1, 3, 1, 1)
    return batch[:, [2, 1, 0], :, :] - mean

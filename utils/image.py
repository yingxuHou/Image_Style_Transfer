from pathlib import Path

import torch
from PIL import Image
from torchvision import transforms


def load_image(path, image_size=None, keep_aspect_ratio=False, resize_mode='crop'):
    image = Image.open(path).convert("RGB")
    steps = []
    if image_size:
        if keep_aspect_ratio:
            # 保持宽高比，将长边缩放到 image_size，短边按比例缩放
            # 确保输出尺寸是 4 的倍数（模型有 2 次 stride=2 下采样）
            w, h = image.size
            if w > h:
                new_w = image_size
                new_h = int(h * image_size / w)
                # 调整到最近的 4 的倍数
                new_h = (new_h // 4) * 4
            else:
                new_h = image_size
                new_w = int(w * image_size / h)
                # 调整到最近的 4 的倍数
                new_w = (new_w // 4) * 4
            steps.append(transforms.Resize((new_h, new_w)))
        elif resize_mode == 'stretch':
            # 拉伸到正方形（会轻微变形，但保留全部内容）
            steps.append(transforms.Resize((image_size, image_size)))
        else:
            # 原来的方式：强制裁剪成正方形（用于训练）
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

import argparse
import csv
import time
from pathlib import Path

import torch

from models.transform_net import TransformNet
from models.vgg import Vgg16Features
from utils.image import imagenet_preprocess_batch, load_image, save_image
from utils.loss import gram_matrix, total_variation_loss


def parse_args():
    parser = argparse.ArgumentParser(description="Run style transfer inference.")
    parser.add_argument("--model", default="checkpoints/best_model.pth")
    parser.add_argument("--input", default="data/test_images/content.jpg")
    parser.add_argument("--output", default="results/comparisons/content_stylized.png")
    parser.add_argument("--image-size", type=int, default=512)
    parser.add_argument("--style-image", default="data/style_images/style.jpg")
    parser.add_argument("--metrics", default="results/metrics.csv")
    parser.add_argument("--device", default="auto", choices=["auto", "cpu", "cuda"])
    return parser.parse_args()


def main():
    args = parse_args()
    if args.device == "auto":
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    else:
        device = torch.device(args.device)

    transform_net = TransformNet().to(device)
    state_dict = torch.load(args.model, map_location=device)
    transform_net.load_state_dict(state_dict)
    transform_net.eval()

    # 保持原始宽高比，不裁剪也不变形
    content = load_image(args.input, args.image_size, keep_aspect_ratio=True).to(device)
    start_time = time.perf_counter()
    with torch.no_grad():
        generated = transform_net(content)
    delta_time = time.perf_counter() - start_time
    save_image(generated, args.output)

    vgg = Vgg16Features().to(device).eval()
    # style 图像使用正方形裁剪（训练时的方式），因为 gram matrix 不依赖空间尺寸
    style = load_image(args.style_image, args.image_size).to(device)
    with torch.no_grad():
        content_features = vgg(imagenet_preprocess_batch(content))
        generated_features = vgg(imagenet_preprocess_batch(generated))
        style_features = vgg(imagenet_preprocess_batch(style))
        # content_loss 要求特征图尺寸一致，所以只能比较相同尺寸的图像
        # 但由于 generated 的尺寸可能与 content 不同（保持宽高比），我们用自适应池化对齐
        content_loss = torch.nn.functional.mse_loss(
            generated_features.relu3_3, content_features.relu3_3
        )
        # style_loss 使用 gram matrix，不受空间尺寸影响
        style_loss = sum(
            torch.nn.functional.mse_loss(gram_matrix(gen), gram_matrix(sty))
            for gen, sty in zip(generated_features, style_features)
        )
        tv_loss = total_variation_loss(generated)

    metrics_path = Path(args.metrics)
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    file_exists = metrics_path.exists()
    with metrics_path.open("a", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        if not file_exists:
            writer.writerow(
                [
                    "input",
                    "output",
                    "model",
                    "device",
                    "image_size",
                    "delta_time",
                    "content_loss",
                    "style_loss",
                    "tv_loss",
                ]
            )
        writer.writerow(
            [
                args.input,
                args.output,
                args.model,
                str(device),
                args.image_size,
                f"{delta_time:.6f}",
                f"{float(content_loss.cpu()):.6f}",
                f"{float(style_loss.cpu()):.6f}",
                f"{float(tv_loss.cpu()):.6f}",
            ]
        )

    print(f"saved output: {args.output}")
    print(f"saved metrics: {metrics_path}")
    print(f"delta_time: {delta_time:.6f}s")
    print(f"content_loss: {float(content_loss.cpu()):.6f}")
    print(f"style_loss: {float(style_loss.cpu()):.6f}")


if __name__ == "__main__":
    main()

import argparse
import csv
import time
from pathlib import Path

import torch
from torch.utils.data import DataLoader
from tqdm import tqdm

from models.transform_net import TransformNet
from models.vgg import Vgg16Features
from utils.dataset import ImageFolderDataset
from utils.image import imagenet_preprocess_batch, load_image, save_image
from utils.loss import PerceptualLoss, gram_matrix


def parse_args():
    parser = argparse.ArgumentParser(description="Train a Fast Neural Style model.")
    parser.add_argument("--train-dir", default="data/train_images")
    parser.add_argument("--style-image", default="data/style_images/style.jpg")
    parser.add_argument("--output", default="checkpoints/best_model.pth")
    parser.add_argument("--epochs", type=int, default=2)
    parser.add_argument("--batch-size", type=int, default=4)
    parser.add_argument("--image-size", type=int, default=256)
    parser.add_argument("--content-weight", type=float, default=1.0)
    parser.add_argument("--style-weight", type=float, default=1e5)
    parser.add_argument("--tv-weight", type=float, default=1e-6)
    parser.add_argument("--device", default="auto", choices=["auto", "cpu", "cuda"])
    parser.add_argument("--max-steps", type=int, default=None)
    parser.add_argument("--log-file", default="logs/train_loss.csv")
    parser.add_argument("--sample-output", default="results/samples/train_sample.png")
    parser.add_argument("--num-workers", type=int, default=4)
    parser.add_argument(
        "--val-image",
        default=None,
        help="若提供,每个 epoch 末在该图上评估总损失,只保留损失最低的 checkpoint(避免保存训练尖峰/回退的模型)",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    if args.device == "auto":
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    else:
        device = torch.device(args.device)

    train_dataset = ImageFolderDataset(args.train_dir, args.image_size)
    if len(train_dataset) == 0:
        raise RuntimeError(f"No training images found in {args.train_dir}")

    train_loader = DataLoader(
        train_dataset,
        batch_size=args.batch_size,
        shuffle=True,
        num_workers=args.num_workers,
        drop_last=False,
    )

    transform_net = TransformNet().to(device)
    vgg = Vgg16Features().to(device).eval()
    criterion = PerceptualLoss(args.content_weight, args.style_weight, args.tv_weight)
    optimizer = torch.optim.Adam(transform_net.parameters(), lr=1e-3)

    style_image = load_image(args.style_image, args.image_size).to(device)
    with torch.no_grad():
        style_features = vgg(imagenet_preprocess_batch(style_image))
        style_grams = [gram_matrix(feature) for feature in style_features]

    # 验证图:每 epoch 末用它评估总损失,只保留最优 checkpoint
    val_image = None
    if args.val_image:
        val_image = load_image(args.val_image, args.image_size).to(device)

    def evaluate_val():
        """在验证图上计算总损失(与训练同口径)。"""
        transform_net.eval()
        if device.type == "cuda":
            torch.cuda.empty_cache()
        with torch.no_grad():
            gen = transform_net(val_image)
            cf = vgg(imagenet_preprocess_batch(val_image))
            gf = vgg(imagenet_preprocess_batch(gen))
            total, _, _, _ = criterion(gen, cf, gf, style_grams)
        transform_net.train()
        return float(total.cpu())

    log_path = Path(args.log_file)
    log_path.parent.mkdir(parents=True, exist_ok=True)
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    global_step = 0
    best_val = float("inf")
    best_epoch = 0
    start_time = time.perf_counter()
    with log_path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["step", "epoch", "total_loss", "content_loss", "style_loss", "tv_loss"])

        for epoch in range(1, args.epochs + 1):
            progress = tqdm(train_loader, desc=f"epoch {epoch}/{args.epochs}")
            for batch in progress:
                global_step += 1
                batch = batch.to(device)
                optimizer.zero_grad()

                generated = transform_net(batch)
                content_features = vgg(imagenet_preprocess_batch(batch))
                generated_features = vgg(imagenet_preprocess_batch(generated))
                total_loss, content_loss, style_loss, tv_loss = criterion(
                    generated, content_features, generated_features, style_grams
                )

                total_loss.backward()
                optimizer.step()

                writer.writerow(
                    [
                        global_step,
                        epoch,
                        float(total_loss.detach().cpu()),
                        float(content_loss.detach().cpu()),
                        float(style_loss.detach().cpu()),
                        float(tv_loss.detach().cpu()),
                    ]
                )
                progress.set_postfix(total=f"{float(total_loss.detach().cpu()):.2f}")

                if args.max_steps and global_step >= args.max_steps:
                    break

            if val_image is not None:
                val_loss = evaluate_val()
                progress.write(f"[epoch {epoch}] val_loss={val_loss:,.0f} (best={best_val:,.0f} @ep{best_epoch})")
                if val_loss < best_val:
                    best_val = val_loss
                    best_epoch = epoch
                    torch.save(transform_net.state_dict(), output_path)
                    progress.write(f"  -> 新最优,已保存 {output_path}")
            else:
                torch.save(transform_net.state_dict(), output_path)
            if args.max_steps and global_step >= args.max_steps:
                break

    elapsed = time.perf_counter() - start_time
    # 无验证图时,保存最后一个 epoch(维持原行为);有验证图时 output_path 已是最优,不再覆盖
    if val_image is None:
        torch.save(transform_net.state_dict(), output_path)
    sample_batch = next(iter(train_loader)).to(device)
    with torch.no_grad():
        sample = transform_net(sample_batch[:1])
    save_image(sample, args.sample_output)
    print(f"saved checkpoint: {output_path}")
    if val_image is not None:
        print(f"best epoch: {best_epoch}, best val_loss: {best_val:,.0f}")
    print(f"saved sample: {args.sample_output}")
    print(f"saved log: {log_path}")
    print(f"elapsed: {elapsed:.2f}s, steps: {global_step}, device: {device}")


if __name__ == "__main__":
    main()

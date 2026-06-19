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
        num_workers=0,
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

    log_path = Path(args.log_file)
    log_path.parent.mkdir(parents=True, exist_ok=True)
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    global_step = 0
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

            torch.save(transform_net.state_dict(), output_path)
            if args.max_steps and global_step >= args.max_steps:
                break

    elapsed = time.perf_counter() - start_time
    torch.save(transform_net.state_dict(), output_path)
    sample_batch = next(iter(train_loader)).to(device)
    with torch.no_grad():
        sample = transform_net(sample_batch[:1])
    save_image(sample, args.sample_output)
    print(f"saved checkpoint: {output_path}")
    print(f"saved sample: {args.sample_output}")
    print(f"saved log: {log_path}")
    print(f"elapsed: {elapsed:.2f}s, steps: {global_step}, device: {device}")


if __name__ == "__main__":
    main()

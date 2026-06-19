from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parent

DATA_DIR = ROOT_DIR / "data"
STYLE_DIR = DATA_DIR / "style_images"
TRAIN_DIR = DATA_DIR / "train_images"
TEST_DIR = DATA_DIR / "test_images"

CHECKPOINT_DIR = ROOT_DIR / "checkpoints"
RESULTS_DIR = ROOT_DIR / "results"
LOG_DIR = ROOT_DIR / "logs"

STYLE_IMAGE = STYLE_DIR / "style.jpg"
IMAGE_SIZE = 256
BATCH_SIZE = 4
EPOCHS = 2
LEARNING_RATE = 1e-3

CONTENT_WEIGHT = 1.0
STYLE_WEIGHT = 1e5
TV_WEIGHT = 1e-6

DEVICE = "cuda"

VGG_MEAN = [103.939, 116.779, 123.68]

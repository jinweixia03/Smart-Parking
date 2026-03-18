#!/usr/bin/env python3
"""
快速测试训练流程（使用少量数据）
"""
import os
import sys

# 修复 Windows OpenMP 重复初始化问题
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

from pathlib import Path

# 检查依赖
try:
    import torch
    print(f"✓ PyTorch {torch.__version__}")
    print(f"  CUDA可用: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"  CUDA设备: {torch.cuda.get_device_name(0)}")
except ImportError:
    print("✗ PyTorch 未安装")
    print("  运行: pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118")
    sys.exit(1)

try:
    from ultralytics import YOLO
    print("✓ Ultralytics 已安装")
except ImportError:
    print("✗ Ultralytics 未安装")
    print("  运行: pip install ultralytics")
    sys.exit(1)

try:
    import cv2
    print(f"✓ OpenCV {cv2.__version__} 已安装")
except ImportError:
    print("✗ OpenCV 未安装")
    print("  运行: pip install opencv-python")
    sys.exit(1)

# 检查数据集
data_root = Path("data/CCPD2019")
if not data_root.exists():
    print(f"\n✗ 数据集目录不存在: {data_root}")
    sys.exit(1)

ccpd_base = data_root / "ccpd_base"
if not ccpd_base.exists():
    print(f"\n✗ ccpd_base 目录不存在")
    sys.exit(1)

# 统计图像数量
images = list(ccpd_base.glob("*.jpg"))
print(f"\n✓ 数据集检查通过")
print(f"  找到 {len(images)} 张图像")

# 检查分割文件
splits_dir = data_root / "splits"
if splits_dir.exists():
    for split in ["train.txt", "val.txt", "test.txt"]:
        split_file = splits_dir / split
        if split_file.exists():
            with open(split_file) as f:
                lines = len(f.readlines())
            print(f"  {split}: {lines} 行")

print("\n" + "="*50)
print("环境检查完成，可以开始训练！")
print("="*50)
print("\n建议的训练命令:")
print("  # 完整训练（检测+识别）")
print("  python train_all.py --data-root data/CCPD2019")
print("")
print("  # 快速测试（仅3轮）")
print("  python train_detection.py --data-root data/CCPD2019 --epochs 3")
print("  python train_recognition.py --data-root data/CCPD2019 --epochs 3")

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CCPD2019 车牌检测模型训练脚本 (YOLOv8)
"""

import os
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import sys
import yaml
import argparse
from pathlib import Path
from tqdm import tqdm
import cv2
import numpy as np
# python train_detection.py --data-root data/CCPD2019 --skip-prepare --epochs 100 --batch 8

def parse_ccpd_filename(filename):
    """
    解析CCPD文件名中的标注信息
    文件名格式: 025-95_113-154&383_386&473-386&473_177&454_154&383_363&402-0_0_22_27_27_33_16-37-15.jpg
    """
    # 移除扩展名
    name = Path(filename).stem
    parts = name.split('-')

    # 解析边界框坐标 (第3个字段)
    bbox_part = parts[2]
    left_top, right_bottom = bbox_part.split('_')
    x1, y1 = map(int, left_top.split('&'))
    x2, y2 = map(int, right_bottom.split('&'))

    return {
        'bbox': [x1, y1, x2, y2]
    }


def convert_to_yolo_format(image_path, bbox):
    """
    将CCPD的边界框转换为YOLO格式 (归一化的中心点坐标和宽高)
    """
    img = cv2.imread(str(image_path))
    if img is None:
        return None

    h, w = img.shape[:2]
    x1, y1, x2, y2 = bbox

    # 转换为YOLO格式
    x_center = ((x1 + x2) / 2) / w
    y_center = ((y1 + y2) / 2) / h
    width = (x2 - x1) / w
    height = (y2 - y1) / h

    return x_center, y_center, width, height


def prepare_dataset(data_root, output_dir, splits_dir):
    """
    准备YOLO格式的数据集
    """
    print("准备YOLO格式数据集...")

    data_root = Path(data_root)
    output_dir = Path(output_dir)
    splits_dir = Path(splits_dir)

    # 创建目录结构
    for split in ['train', 'val', 'test']:
        (output_dir / 'images' / split).mkdir(parents=True, exist_ok=True)
        (output_dir / 'labels' / split).mkdir(parents=True, exist_ok=True)

    # 处理每个分割
    for split in ['train', 'val', 'test']:
        print(f"\n处理 {split} 集...")
        split_file = splits_dir / f'{split}.txt'

        if not split_file.exists():
            print(f"警告: {split_file} 不存在，跳过")
            continue

        with open(split_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        for line in tqdm(lines, desc=f"Processing {split}"):
            line = line.strip()
            if not line:
                continue

            # 解析路径 - 直接从 data_root 拼接完整路径
            img_path = data_root / line

            if not img_path.exists():
                continue

            try:
                # 解析标注
                anno = parse_ccpd_filename(img_path.name)
                yolo_bbox = convert_to_yolo_format(img_path, anno['bbox'])

                if yolo_bbox is None:
                    continue

                # 复制图像
                dst_img_path = output_dir / 'images' / split / img_path.name
                if not dst_img_path.exists():
                    import shutil
                    shutil.copy2(img_path, dst_img_path)

                # 写入YOLO格式标签
                label_path = output_dir / 'labels' / split / f"{img_path.stem}.txt"
                with open(label_path, 'w') as f:
                    f.write(f"0 {yolo_bbox[0]:.6f} {yolo_bbox[1]:.6f} {yolo_bbox[2]:.6f} {yolo_bbox[3]:.6f}\n")

            except Exception as e:
                print(f"处理 {img_path} 时出错: {e}")
                continue

    print(f"\n数据集准备完成！输出目录: {output_dir}")


def create_data_yaml(output_dir, dataset_path):
    """
    创建YOLO数据配置文件
    """
    # 确保目录存在
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    data = {
        'path': str(Path(dataset_path).absolute()),
        'train': 'images/train',
        'val': 'images/val',
        'test': 'images/test',
        'nc': 1,  # 类别数
        'names': {0: 'license_plate'}
    }

    yaml_path = Path(output_dir) / 'ccpd.yaml'
    with open(yaml_path, 'w', encoding='utf-8') as f:
        yaml.dump(data, f, allow_unicode=True)

    print(f"数据配置文件已创建: {yaml_path}")
    return yaml_path


def train_yolo(data_yaml, epochs=100, img_size=640, batch=16, model='yolov8n.pt'):
    """
    训练YOLOv8检测模型
    """
    try:
        from ultralytics import YOLO
    except ImportError:
        print("错误: 请先安装 ultralytics: pip install ultralytics")
        sys.exit(1)

    print(f"\n开始训练YOLOv8检测模型...")
    print(f"数据配置: {data_yaml}")
    print(f"模型: {model}")
    print(f"轮数: {epochs}")
    print(f"图像尺寸: {img_size}")
    print(f"批次大小: {batch}")

    # 加载预训练模型
    model = YOLO(model)

    # 训练 - 针对 RTX 4090 和 CCPD 数据集优化
    results = model.train(
        data=data_yaml,
        epochs=epochs,
        imgsz=img_size,
        batch=batch,
        patience=20,
        save=True,
        device=0,
        project='runs/detect',
        name='ccpd_plate',
        exist_ok=True,
        pretrained=True,
        optimizer='AdamW',
        lr0=0.001,
        lrf=0.01,
        momentum=0.937,
        weight_decay=0.0003,  # 适度正则化
        warmup_epochs=3.0,
        warmup_momentum=0.8,
        box=7.5,
        cls=0.5,
        dfl=1.5,
        # 数据增强 - 针对车牌场景优化
        hsv_h=0.015,      # HSV色调
        hsv_s=0.7,        # HSV饱和度
        hsv_v=0.4,        # HSV明度
        degrees=3.0,      # 减小旋转 (车牌角度变化小)
        translate=0.05,   # 减小平移 (车牌位置相对固定)
        scale=0.3,        # 减小缩放 (车牌大小变化有限)
        shear=1.0,        # 减小剪切
        perspective=0.0,  # 关闭透视变换 (文件名中已有真实透视)
        flipud=0.0,       # 关闭上下翻转 (车牌不会倒立)
        fliplr=0.5,       # 左右翻转
        mosaic=1.0,       # Mosaic增强
        mixup=0.0,        # 关闭Mixup (不适合车牌)
        copy_paste=0.0,   # 关闭CopyPaste
        # 其他优化
        workers=8,        # 数据加载线程
        cos_lr=True,      # 使用余弦学习率调度
    )

    # 验证
    print("\n运行验证...")
    metrics = model.val()
    print(f"验证结果:")
    print(f"  mAP@0.5: {metrics.box.map50:.4f}")
    print(f"  mAP@0.5:0.95: {metrics.box.map:.4f}")

    # 导出ONNX
    print("\n导出ONNX格式...")
    model.export(format='onnx', dynamic=True)

    return model, results


def main():
    parser = argparse.ArgumentParser(description='CCPD2019 车牌检测训练')
    parser.add_argument('--data-root', type=str, default='data/CCPD2019',
                        help='CCPD数据集根目录 (包含 ccpd_base 等子目录)')
    parser.add_argument('--splits-dir', type=str, default='data/CCPD2019/splits',
                        help='数据集分割文件目录')
    parser.add_argument('--output-dir', type=str, default='data/yolo_dataset',
                        help='YOLO格式数据集输出目录')
    parser.add_argument('--epochs', type=int, default=100, help='训练轮数')
    parser.add_argument('--img-size', type=int, default=640, help='输入图像尺寸')
    parser.add_argument('--batch', type=int, default=32, help='批次大小 (RTX 4090 建议32+)')
    parser.add_argument('--model', type=str, default='yolov8n.pt',
                        choices=['yolov8n.pt', 'yolov8s.pt', 'yolov8m.pt', 'yolov8l.pt'],
                        help='YOLO模型类型')
    parser.add_argument('--skip-prepare', default=True, action='store_true',
                        help='跳过数据集准备步骤')

    args = parser.parse_args()

    # 准备数据集
    if not args.skip_prepare:
        prepare_dataset(args.data_root, args.output_dir, args.splits_dir)

    # 确保配置目录存在
    os.makedirs('configs', exist_ok=True)

    # 创建数据配置文件
    yaml_path = create_data_yaml('configs', args.output_dir)

    # 训练模型
    train_yolo(
        data_yaml=str(yaml_path),
        epochs=args.epochs,
        img_size=args.img_size,
        batch=args.batch,
        model=args.model
    )

    print("\n训练完成！")
    print(f"模型保存在: runs/detect/ccpd_plate/")


if __name__ == '__main__':
    main()

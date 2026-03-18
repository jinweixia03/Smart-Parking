#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CCPD2019 端到端训练脚本
一键完成检测和识别模型训练
"""

import os
import sys
import argparse
import subprocess
from pathlib import Path
from datetime import datetime


def run_command(cmd, description):
    """运行命令并打印输出"""
    print(f"\n{'='*60}")
    print(f"开始: {description}")
    print(f"命令: {' '.join(cmd)}")
    print('='*60)

    result = subprocess.run(cmd, capture_output=False, text=True)

    if result.returncode != 0:
        print(f"错误: {description} 失败")
        return False

    print(f"完成: {description}")
    return True


def main():
    parser = argparse.ArgumentParser(
        description='CCPD2019 端到端训练',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 完整训练流程
  python train_all.py --data-root data/CCPD2019

  # 仅训练检测模型
  python train_all.py --data-root data/CCPD2019 --only-detection

  # 仅训练识别模型
  python train_all.py --data-root data/CCPD2019 --only-recognition

  # 使用自定义参数
  python train_all.py --data-root data/CCPD2019 --epochs 50 --batch 32
        """
    )

    parser.add_argument('--data-root', type=str, required=True,
                        help='CCPD2019 数据集根目录')
    parser.add_argument('--splits-dir', type=str, default=None,
                        help='分割文件目录 (默认: data-root/splits)')

    # 训练模式
    parser.add_argument('--only-detection', action='store_true',
                        help='仅训练检测模型')
    parser.add_argument('--only-recognition', action='store_true',
                        help='仅训练识别模型')

    # 检测模型参数
    parser.add_argument('--det-epochs', type=int, default=100,
                        help='检测模型训练轮数')
    parser.add_argument('--det-batch', type=int, default=16,
                        help='检测模型批次大小')
    parser.add_argument('--det-model', type=str, default='yolov8n.pt',
                        choices=['yolov8n.pt', 'yolov8s.pt', 'yolov8m.pt', 'yolov8l.pt'],
                        help='检测模型类型')
    parser.add_argument('--det-img-size', type=int, default=640,
                        help='检测模型输入尺寸')

    # 识别模型参数
    parser.add_argument('--rec-epochs', type=int, default=100,
                        help='识别模型训练轮数')
    parser.add_argument('--rec-batch', type=int, default=128,
                        help='识别模型批次大小')
    parser.add_argument('--rec-lr', type=float, default=0.001,
                        help='识别模型学习率')

    # 通用参数
    parser.add_argument('--skip-prepare', action='store_true',
                        help='跳过数据准备')
    parser.add_argument('--cpu', action='store_true',
                        help='强制使用CPU训练')

    args = parser.parse_args()

    # 设置默认值
    if args.splits_dir is None:
        args.splits_dir = os.path.join(args.data_root, 'splits')

    # 验证数据目录
    if not os.path.exists(args.data_root):
        print(f"错误: 数据目录不存在: {args.data_root}")
        print("请先下载 CCPD2019 数据集")
        print("运行: python download_ccpd.py --guide")
        sys.exit(1)

    start_time = datetime.now()
    print(f"训练开始时间: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")

    success = True

    # ========== 步骤 1: 数据准备 ==========
    if not args.skip_prepare and not args.only_recognition:
        cmd = [
            'python', 'train_detection.py',
            '--data-root', args.data_root,
            '--splits-dir', args.splits_dir,
            '--output-dir', 'data/yolo_dataset',
            '--skip-prepare', 'false'
        ]
        if not run_command(cmd, '数据准备'):
            success = False

    # ========== 步骤 2: 训练检测模型 ==========
    if success and not args.only_recognition:
        cmd = [
            'python', 'train_detection.py',
            '--data-root', args.data_root,
            '--splits-dir', args.splits_dir,
            '--output-dir', 'data/yolo_dataset',
            '--epochs', str(args.det_epochs),
            '--batch', str(args.det_batch),
            '--model', args.det_model,
            '--img-size', str(args.det_img_size),
            '--skip-prepare'
        ]
        if not run_command(cmd, '检测模型训练'):
            success = False

    # ========== 步骤 3: 训练识别模型 ==========
    if success and not args.only_detection:
        train_split = os.path.join(args.splits_dir, 'train.txt')
        val_split = os.path.join(args.splits_dir, 'val.txt')

        cmd = [
            'python', 'train_recognition.py',
            '--data-root', args.data_root,
            '--train-split', train_split,
            '--val-split', val_split,
            '--epochs', str(args.rec_epochs),
            '--batch-size', str(args.rec_batch),
            '--lr', str(args.rec_lr),
            '--output-dir', 'weights/recognition'
        ]
        if args.cpu:
            cmd.append('--cpu')

        if not run_command(cmd, '识别模型训练'):
            success = False

    # ========== 完成 ==========
    end_time = datetime.now()
    duration = end_time - start_time

    print(f"\n{'='*60}")
    if success:
        print("✓ 所有训练任务完成!")
    else:
        print("✗ 训练过程中出现错误")
    print(f"总耗时: {duration}")
    print(f"结束时间: {end_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print('='*60)

    if success:
        print("\n训练好的模型位置:")
        if not args.only_recognition:
            print("  检测模型: runs/detect/ccpd_plate/weights/best.pt")
        if not args.only_detection:
            print("  识别模型: weights/recognition/best_model.pth")

    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()

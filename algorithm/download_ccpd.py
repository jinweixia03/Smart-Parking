#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CCPD2019 数据集下载脚本
官方数据集需要通过 Google Drive 或百度网盘下载
此脚本提供下载指导和自动解压功能
"""

import os
import sys
import argparse
from pathlib import Path


CCPD_DOWNLOAD_URLS = {
    'google_drive': {
        'ccpd_base': 'https://drive.google.com/file/d/1rdEsCUcIUaYOVRkx5mStcWv3sRwsKYcu/view',
        'ccpd_blur': 'https://drive.google.com/file/d/1iCg9qUW4R2mTw3iTCw3MAkT2H2wR-L1R/view',
        'ccpd_challenge': 'https://drive.google.com/file/d/1WmR0-_2v3Y1O3K2Lau4umvW1IpThNZMv/view',
        'ccpd_db': 'https://drive.google.com/file/d/1B5pQ2SJcQfLeTk7t0MwGtoVZVqpeiKPr/view',
        'ccpd_fn': 'https://drive.google.com/file/d/1f0tdEOjK2vNVLGRDVZ9bSfC8CZm1Xf1E/view',
        'ccpd_np': 'https://drive.google.com/file/d/1YYmv9eM5yoKI_yzEsb8y4K9zK5fsGq4B/view',
        'ccpd_rotate': 'https://drive.google.com/file/d/1o2e0__JWLQK3ueM1_XxQfX_4IF1r2m36/view',
        'ccpd_tilt': 'https://drive.google.com/file/d/1o0TqUfDe1QhLg64NF_2zKj5hGmJ3c1yf/view',
        'ccpd_weather': 'https://drive.google.com/file/d/1_dEFaTotNZXPP8d4bBmpHLCYwAqWR7vJ/view',
    },
    'baidu_pan': {
        'url': 'https://pan.baidu.com/s/1i5AOjAbtkwb17Zy-NQGqkw',
        'code': 'hm3u'
    }
}


def print_download_guide():
    """打印下载指南"""
    print("=" * 60)
    print("CCPD2019 数据集下载指南")
    print("=" * 60)
    print()
    print("由于 CCPD 数据集文件较大 (约 10GB)，需要通过以下方式下载：")
    print()
    print("【推荐】百度网盘下载:")
    print(f"  链接: {CCPD_DOWNLOAD_URLS['baidu_pan']['url']}")
    print(f"  提取码: {CCPD_DOWNLOAD_URLS['baidu_pan']['code']}")
    print()
    print("Google Drive 下载:")
    for name, url in CCPD_DOWNLOAD_URLS['google_drive'].items():
        print(f"  {name}: {url}")
    print()
    print("=" * 60)
    print("下载完成后，请将文件放置到以下目录结构：")
    print()
    print("  algorithm/data/CCPD2019/")
    print("  ├── ccpd_base/          # 基础数据集 (约 10GB)")
    print("  │   ├── 000001.jpg")
    print("  │   ├── 000002.jpg")
    print("  │   └── ...")
    print("  ├── ccpd_blur/          # 模糊车牌 (可选)")
    print("  ├── ccpd_challenge/     # 困难样本 (可选)")
    print("  ├── splits/             # 数据分割文件")
    print("  │   ├── train.txt")
    print("  │   ├── val.txt")
    print("  │   └── test.txt")
    print("  └── README.md")
    print()
    print("=" * 60)


def verify_dataset(data_root):
    """验证数据集完整性"""
    data_root = Path(data_root)

    print("验证数据集完整性...")
    print()

    # 检查必要的子集
    required_subsets = ['ccpd_base']
    optional_subsets = ['ccpd_blur', 'ccpd_challenge', 'ccpd_db', 'ccpd_fn',
                       'ccpd_np', 'ccpd_rotate', 'ccpd_tilt', 'ccpd_weather']

    for subset in required_subsets:
        subset_path = data_root / subset
        if subset_path.exists():
            num_images = len(list(subset_path.glob('*.jpg')))
            print(f"  [✓] {subset}: {num_images} 张图像")
        else:
            print(f"  [✗] {subset}: 未找到")

    print()
    for subset in optional_subsets:
        subset_path = data_root / subset
        if subset_path.exists():
            num_images = len(list(subset_path.glob('*.jpg')))
            print(f"  [✓] {subset} (可选): {num_images} 张图像")

    # 检查分割文件
    print()
    splits_dir = data_root / 'splits'
    if splits_dir.exists():
        for split in ['train.txt', 'val.txt', 'test.txt']:
            split_file = splits_dir / split
            if split_file.exists():
                with open(split_file, 'r') as f:
                    num_lines = len(f.readlines())
                print(f"  [✓] splits/{split}: {num_lines} 行")
            else:
                print(f"  [✗] splits/{split}: 未找到")
    else:
        print(f"  [✗] splits 目录未找到")

    print()


def create_splits(data_root, train_ratio=0.7, val_ratio=0.15):
    """
    创建数据集分割文件
    如果已存在则不覆盖
    """
    data_root = Path(data_root)
    splits_dir = data_root / 'splits'
    splits_dir.mkdir(exist_ok=True)

    # 检查是否已存在
    if (splits_dir / 'train.txt').exists():
        print("分割文件已存在，跳过创建")
        return

    print("创建数据集分割...")

    # 获取所有图像文件
    all_images = []
    for subset in ['ccpd_base', 'ccpd_blur', 'ccpd_challenge', 'ccpd_db',
                   'ccpd_fn', 'ccpd_rotate', 'ccpd_tilt']:
        subset_path = data_root / subset
        if subset_path.exists():
            images = list(subset_path.glob('*.jpg'))
            all_images.extend([f"{subset}/{img.name}" for img in images])

    # 随机打乱
    import random
    random.seed(42)
    random.shuffle(all_images)

    # 计算分割点
    total = len(all_images)
    train_end = int(total * train_ratio)
    val_end = train_end + int(total * val_ratio)

    train_set = all_images[:train_end]
    val_set = all_images[train_end:val_end]
    test_set = all_images[val_end:]

    # 写入文件
    with open(splits_dir / 'train.txt', 'w') as f:
        f.write('\n'.join(train_set))
    with open(splits_dir / 'val.txt', 'w') as f:
        f.write('\n'.join(val_set))
    with open(splits_dir / 'test.txt', 'w') as f:
        f.write('\n'.join(test_set))

    print(f"  训练集: {len(train_set)}")
    print(f"  验证集: {len(val_set)}")
    print(f"  测试集: {len(test_set)}")


def main():
    parser = argparse.ArgumentParser(description='CCPD2019 数据集下载和准备')
    parser.add_argument('--guide', action='store_true', help='显示下载指南')
    parser.add_argument('--verify', type=str, metavar='PATH',
                        default='data/CCPD2019',
                        help='验证数据集完整性')
    parser.add_argument('--create-splits', type=str, metavar='PATH',
                        help='创建数据集分割文件')

    args = parser.parse_args()

    if args.guide or len(sys.argv) == 1:
        print_download_guide()
        return

    if args.verify:
        verify_dataset(args.verify)

    if args.create_splits:
        create_splits(args.create_splits)


if __name__ == '__main__':
    main()

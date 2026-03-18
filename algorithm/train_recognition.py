#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CCPD2019 车牌识别模型训练脚本 (LPRNet)
使用CTC Loss进行端到端训练
"""

import os
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import sys
import argparse
import random
import numpy as np
from pathlib import Path
from datetime import datetime
from tqdm import tqdm

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torch.nn.utils import clip_grad_norm_
import torchvision.transforms as transforms

import cv2

# 添加src目录到路径
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))
from models.recognition.lprnet import LPRNet, PlateRecognizer


# 字符集定义
CHARS = ['blank']  # CTC blank index = 0
CHARS += [str(i) for i in range(10)]  # 0-9
CHARS += [chr(i) for i in range(65, 91)]  # A-Z
# 省份简称
CHARS += ['皖', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
          '苏', '浙', '京', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤',
          '桂', '琼', '川', '贵', '云', '藏', '陕', '甘', '青', '宁', '新']

NUM_CLASSES = len(CHARS)
CHAR2IDX = {c: i for i, c in enumerate(CHARS)}
IDX2CHAR = {i: c for i, c in enumerate(CHARS)}


def parse_ccpd_filename(filename):
    """
    解析CCPD文件名中的车牌号码
    文件名格式: ...-0_0_22_27_27_33_16-37-15.jpg
    第5个字段是车牌号码的索引
    """
    name = Path(filename).stem
    parts = name.split('-')

    # 车牌号码字段
    plate_part = parts[4]
    indices = list(map(int, plate_part.split('_')))

    # CCPD索引到字符的映射
    provinces = ['皖', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
                 '苏', '浙', '京', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤',
                 '桂', '琼', '川', '贵', '云', '藏', '陕', '甘', '青', '宁', '新']
    alphabets = [chr(i) for i in range(65, 91)]  # A-Z
    ads = [str(i) for i in range(10)] + [chr(i) for i in range(65, 91)]  # 0-9, A-Z

    # 解析车牌
    plate = provinces[indices[0]] + alphabets[indices[1]]
    for idx in indices[2:]:
        plate += ads[idx]

    return plate


def parse_ccpd_bbox(filename):
    """
    解析CCPD文件名中的边界框坐标
    """
    name = Path(filename).stem
    parts = name.split('-')

    # 边界框坐标
    bbox_part = parts[2]
    left_top, right_bottom = bbox_part.split('_')
    x1, y1 = map(int, left_top.split('&'))
    x2, y2 = map(int, right_bottom.split('&'))

    return [x1, y1, x2, y2]


def parse_ccpd_vertices(filename):
    """
    解析CCPD文件名中的四个顶点坐标
    """
    name = Path(filename).stem
    parts = name.split('-')

    # 四个顶点坐标
    vertices_part = parts[3]
    vertices = []
    for v in vertices_part.split('_'):
        x, y = map(int, v.split('&'))
        vertices.append([x, y])

    return np.array(vertices, dtype=np.float32)


class CCPDDataset(Dataset):
    """
    CCPD2019数据集
    """
    def __init__(self, data_root, split_file, img_size=(94, 24), augment=False):
        self.data_root = Path(data_root)
        self.img_size = img_size
        self.augment = augment

        # 读取文件列表
        with open(split_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        self.samples = []
        for line in lines:
            line = line.strip()
            if not line:
                continue

            # 构建完整路径 - line 已经是相对路径如 'ccpd_base/xxx.jpg'
            img_path = self.data_root / line
            if img_path.exists():
                try:
                    plate = parse_ccpd_filename(img_path.name)
                    self.samples.append((str(img_path), plate))
                except Exception as e:
                    print(f"解析 {img_path.name} 失败: {e}")

        print(f"加载了 {len(self.samples)} 个样本")

        # 基础变换
        self.transform = transforms.Compose([
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.5, 0.5, 0.5], std=[0.5, 0.5, 0.5])
        ])

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        img_path, plate = self.samples[idx]

        # 读取图像
        img = cv2.imread(img_path)
        if img is None:
            # 返回空白图像
            img = np.zeros((self.img_size[1], self.img_size[0], 3), dtype=np.uint8)

        # 解析并裁剪车牌区域
        try:
            vertices = parse_ccpd_vertices(Path(img_path).name)

            # 透视变换将车牌矫正为矩形
            # CCPD顶点顺序: 右下、左下、左上、右上
            # 目标点需要与之一一对应
            dst_pts = np.array([
                [self.img_size[0], self.img_size[1]],  # 右下
                [0, self.img_size[1]],                 # 左下
                [0, 0],                                # 左上
                [self.img_size[0], 0]                  # 右上
            ], dtype=np.float32)

            M = cv2.getPerspectiveTransform(vertices, dst_pts)
            img = cv2.warpPerspective(img, M, self.img_size)

        except Exception as e:
            # 如果透视变换失败，直接resize
            img = cv2.resize(img, self.img_size)

        # 数据增强
        if self.augment:
            img = self._augment(img)

        # BGR to RGB
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # 应用变换
        img = self.transform(img)

        # 标签转换为索引
        label = [CHAR2IDX[c] for c in plate if c in CHAR2IDX]
        label_length = len(label)

        return img, torch.tensor(label, dtype=torch.long), label_length

    def _augment(self, img):
        """增强的数据增强 - 针对车牌识别场景优化"""
        h, w = img.shape[:2]

        # 1. 随机亮度调整 (概率70%，范围更大)
        if random.random() > 0.3:
            factor = random.uniform(0.6, 1.4)
            img = cv2.convertScaleAbs(img, alpha=factor, beta=0)

        # 2. 随机对比度 (概率70%)
        if random.random() > 0.3:
            mean = img.mean()
            factor = random.uniform(0.7, 1.3)
            img = np.clip((img - mean) * factor + mean, 0, 255).astype(np.uint8)

        # 3. 高斯模糊 (概率20%，模拟对焦不准)
        if random.random() > 0.8:
            kernel = random.choice([3, 5])
            img = cv2.GaussianBlur(img, (kernel, kernel), 0)

        # 4. 运动模糊 (概率10%，模拟车辆移动)
        if random.random() > 0.9:
            kernel_size = random.choice([3, 5])
            kernel = np.zeros((kernel_size, kernel_size))
            kernel[kernel_size // 2, :] = 1 / kernel_size
            img = cv2.filter2D(img, -1, kernel)

        # 5. 随机高斯噪声 (概率20%，噪声强度变化)
        if random.random() > 0.8:
            noise_level = random.uniform(3, 12)
            noise = np.random.normal(0, noise_level, img.shape).astype(np.float32)
            img = np.clip(img.astype(np.float32) + noise, 0, 255).astype(np.uint8)

        # 6. 随机裁剪 (概率30%，模拟检测框不准)
        if random.random() > 0.7:
            crop_ratio = random.uniform(0.02, 0.08)  # 裁剪2-8%的边
            x1 = int(w * random.uniform(0, crop_ratio))
            y1 = int(h * random.uniform(0, crop_ratio))
            x2 = int(w * (1 - random.uniform(0, crop_ratio)))
            y2 = int(h * (1 - random.uniform(0, crop_ratio)))
            img = img[y1:y2, x1:x2]
            img = cv2.resize(img, self.img_size)

        # 7. 随机水平平移 (概率20%，模拟车牌位置偏移)
        if random.random() > 0.8:
            shift_x = random.randint(-5, 5)
            M = np.float32([[1, 0, shift_x], [0, 1, 0]])
            img = cv2.warpAffine(img, M, self.img_size, borderMode=cv2.BORDER_REPLICATE)

        # 8. 饱和度调整 (概率30%)
        if random.random() > 0.7:
            hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV).astype(np.float32)
            saturation_factor = random.uniform(0.8, 1.2)
            hsv[:, :, 1] *= saturation_factor
            hsv[:, :, 1] = np.clip(hsv[:, :, 1], 0, 255)
            img = cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR)

        return img


def collate_fn(batch):
    """
    自定义collate函数处理变长序列
    """
    images, labels, label_lengths = zip(*batch)

    images = torch.stack(images, 0)
    labels = torch.cat(labels, 0)
    label_lengths = torch.tensor(label_lengths, dtype=torch.long)

    return images, labels, label_lengths


class CTCLabelConverter:
    """CTC标签转换器"""

    @staticmethod
    def encode(texts):
        """将文本编码为索引"""
        lengths = [len(text) for text in texts]
        indices = []
        for text in texts:
            indices += [CHAR2IDX[c] for c in text if c in CHAR2IDX]
        return torch.tensor(indices), torch.tensor(lengths)

    @staticmethod
    def decode(indices, lengths):
        """将索引解码为文本"""
        results = []
        idx = 0
        for length in lengths:
            text = ''.join([IDX2CHAR[int(indices[i])] for i in range(idx, idx + length)])
            results.append(text)
            idx += length
        return results


def train_epoch(model, dataloader, criterion, optimizer, device, scheduler=None):
    """训练一个epoch"""
    model.train()
    total_loss = 0
    correct = 0
    total = 0

    pbar = tqdm(dataloader, desc='Training')
    for images, labels, label_lengths in pbar:
        images = images.to(device)
        labels = labels.to(device)
        label_lengths = label_lengths.to(device)

        # 前向传播
        outputs = model(images)  # [T, B, C]

        # CTC输入长度 (T)
        input_lengths = torch.full(
            size=(outputs.size(1),),
            fill_value=outputs.size(0),
            dtype=torch.long,
            device=device
        )

        # 计算CTC Loss
        loss = criterion(outputs, labels, input_lengths, label_lengths)

        # 反向传播
        optimizer.zero_grad()
        loss.backward()
        clip_grad_norm_(model.parameters(), max_norm=5)
        optimizer.step()
        scheduler.step()

        total_loss += loss.item()

        # 计算准确率
        with torch.no_grad():
            preds = outputs.argmax(dim=2).cpu().numpy()
            # 简单CTC解码
            for b in range(preds.shape[1]):
                pred_seq = preds[:, b]
                prev = -1
                pred_text = ''
                for p in pred_seq:
                    if p != prev and p != 0:
                        pred_text += IDX2CHAR[p]
                    prev = p

                true_len = label_lengths[b].item()
                true_text = ''.join([IDX2CHAR[labels[i].item()] for i in range(sum(label_lengths[:b].tolist()), sum(label_lengths[:b].tolist()) + true_len)])

                if pred_text == true_text:
                    correct += 1
                total += 1

        pbar.set_postfix({
            'loss': f'{loss.item():.4f}',
            'acc': f'{100.*correct/total:.2f}%'
        })

    avg_loss = total_loss / len(dataloader)
    accuracy = correct / total if total > 0 else 0

    return avg_loss, accuracy


def validate(model, dataloader, criterion, device):
    """验证模型"""
    model.eval()
    total_loss = 0
    correct = 0
    total = 0

    with torch.no_grad():
        for images, labels, label_lengths in tqdm(dataloader, desc='Validating'):
            images = images.to(device)
            labels = labels.to(device)
            label_lengths = label_lengths.to(device)

            outputs = model(images)

            input_lengths = torch.full(
                size=(outputs.size(1),),
                fill_value=outputs.size(0),
                dtype=torch.long,
                device=device
            )

            loss = criterion(outputs, labels, input_lengths, label_lengths)
            total_loss += loss.item()

            # 计算准确率
            preds = outputs.argmax(dim=2).cpu().numpy()
            for b in range(preds.shape[1]):
                pred_seq = preds[:, b]
                prev = -1
                pred_text = ''
                for p in pred_seq:
                    if p != prev and p != 0:
                        pred_text += IDX2CHAR[p]
                    prev = p

                true_len = label_lengths[b].item()
                idx_start = sum(label_lengths[:b].tolist()) if b > 0 else 0
                true_text = ''.join([IDX2CHAR[labels[i].item()] for i in range(idx_start, idx_start + true_len)])

                if pred_text == true_text:
                    correct += 1
                total += 1

    avg_loss = total_loss / len(dataloader)
    accuracy = correct / total if total > 0 else 0

    return avg_loss, accuracy


def train(args):
    """主训练函数"""

    # 设置随机种子
    torch.manual_seed(args.seed)
    np.random.seed(args.seed)
    random.seed(args.seed)

    # 设备
    device = torch.device('cuda' if torch.cuda.is_available() and not args.cpu else 'cpu')
    print(f"使用设备: {device}")

    # 创建模型
    model = LPRNet(num_classes=NUM_CLASSES, dropout_rate=args.dropout)
    model = model.to(device)

    print(f"模型参数数量: {sum(p.numel() for p in model.parameters()):,}")

    # 数据集
    train_dataset = CCPDDataset(
        args.data_root,
        args.train_split,
        img_size=(args.img_width, args.img_height),
        augment=True
    )

    val_dataset = CCPDDataset(
        args.data_root,
        args.val_split,
        img_size=(args.img_width, args.img_height),
        augment=False
    )

    train_loader = DataLoader(
        train_dataset,
        batch_size=args.batch_size,
        shuffle=True,
        num_workers=args.num_workers,
        collate_fn=collate_fn,
        pin_memory=True
    )

    val_loader = DataLoader(
        val_dataset,
        batch_size=args.batch_size,
        shuffle=False,
        num_workers=args.num_workers,
        collate_fn=collate_fn,
        pin_memory=True
    )

    # 损失函数和优化器
    criterion = nn.CTCLoss(blank=0, reduction='mean', zero_infinity=True)
    optimizer = optim.AdamW(
        model.parameters(),
        lr=args.lr,
        weight_decay=args.weight_decay,
        betas=(0.9, 0.999),
        eps=1e-8
    )

    # 计算总步数
    total_steps = len(train_loader) * args.epochs
    warmup_steps = len(train_loader) * 3  # 3轮预热

    # 学习率调度: 预热 + 余弦退火
    def lr_lambda(step):
        if step < warmup_steps:
            # 线性预热
            return step / warmup_steps
        else:
            # 余弦退火
            progress = (step - warmup_steps) / (total_steps - warmup_steps)
            return 0.5 * (1 + np.cos(np.pi * progress))

    scheduler = optim.lr_scheduler.LambdaLR(optimizer, lr_lambda)

    print(f"总步数: {total_steps}, 预热步数: {warmup_steps}")

    # 创建输出目录
    os.makedirs(args.output_dir, exist_ok=True)

    # 训练循环
    best_acc = 0
    history = {'train_loss': [], 'train_acc': [], 'val_loss': [], 'val_acc': []}

    for epoch in range(args.epochs):
        print(f"\nEpoch {epoch+1}/{args.epochs}")
        print("-" * 50)

        # 训练
        train_loss, train_acc = train_epoch(
            model, train_loader, criterion, optimizer, device, None
        )

        # 验证
        val_loss, val_acc = validate(model, val_loader, criterion, device)

        # 获取当前学习率
        current_lr = optimizer.param_groups[0]['lr']

        print(f"Train Loss: {train_loss:.4f}, Train Acc: {train_acc*100:.2f}%, LR: {current_lr:.6f}")
        print(f"Val Loss: {val_loss:.4f}, Val Acc: {val_acc*100:.2f}%")

        history['train_loss'].append(train_loss)
        history['train_acc'].append(train_acc)
        history['val_loss'].append(val_loss)
        history['val_acc'].append(val_acc)

        # 保存最佳模型
        if val_acc > best_acc:
            best_acc = val_acc
            checkpoint = {
                'epoch': epoch,
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'val_acc': val_acc,
                'char_dict': {'chars': CHARS, 'char2idx': CHAR2IDX, 'idx2char': IDX2CHAR}
            }
            torch.save(checkpoint, os.path.join(args.output_dir, 'best_model.pth'))
            print(f"保存最佳模型，准确率: {val_acc*100:.2f}%")

        # 定期保存
        if (epoch + 1) % args.save_interval == 0:
            checkpoint = {
                'epoch': epoch,
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'val_acc': val_acc
            }
            torch.save(checkpoint, os.path.join(args.output_dir, f'checkpoint_epoch_{epoch+1}.pth'))

    print(f"\n训练完成！最佳验证准确率: {best_acc*100:.2f}%")
    print(f"模型保存在: {args.output_dir}")

    return history


def main():
    parser = argparse.ArgumentParser(description='CCPD2019 车牌识别训练 (LPRNet)')

    # 数据参数
    parser.add_argument('--data-root', type=str, default='data/CCPD2019',
                        help='CCPD数据集根目录')
    parser.add_argument('--train-split', type=str, default='data/CCPD2019/splits/train.txt',
                        help='训练集分割文件')
    parser.add_argument('--val-split', type=str, default='data/CCPD2019/splits/val.txt',
                        help='验证集分割文件')

    # 模型参数
    parser.add_argument('--img-width', type=int, default=94, help='输入图像宽度')
    parser.add_argument('--img-height', type=int, default=24, help='输入图像高度')
    parser.add_argument('--dropout', type=float, default=0.3, help='Dropout率 (适中即可，主要靠数据增强)')

    # 训练参数 - 针对 RTX 4090 Laptop 优化
    parser.add_argument('--epochs', type=int, default=100, help='训练轮数')
    parser.add_argument('--batch-size', type=int, default=256, help='批次大小 (RTX 4090 可支持256+)')
    parser.add_argument('--lr', type=float, default=0.001, help='学习率')
    parser.add_argument('--weight-decay', type=float, default=0.0003, help='权重衰减 (适度正则化)')
    parser.add_argument('--num-workers', type=int, default=8, help='数据加载线程数 (建议CPU核心数)')

    # 其他参数
    parser.add_argument('--output-dir', type=str, default='weights/recognition',
                        help='模型输出目录')
    parser.add_argument('--save-interval', type=int, default=10,
                        help='保存间隔（轮数）')
    parser.add_argument('--seed', type=int, default=42, help='随机种子')
    parser.add_argument('--cpu', action='store_true', help='强制使用CPU')

    args = parser.parse_args()

    # 训练
    train(args)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CCPD2019 车牌识别模型训练脚本 V2 (优化版)
使用CTC Loss进行端到端训练
优化点:
- 更强的数据增强策略
- 混合精度训练加速
- 早停机制防止过拟合
- 学习率动态调整
- 更多监控指标
"""
# python train_recognition_v2.py --data-root data/CCPD2019 --epochs 10 --batch-size 512

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
from torch.cuda.amp import autocast, GradScaler
import torchvision.transforms as transforms

import cv2

# 添加src目录到路径
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))
from models.recognition.lprnet import LPRNet, PlateRecognizer


# 字符集定义（与CCPD官方一致）
CHARS = ['blank']  # CTC blank index = 0
# 省份简称
CHARS += ['皖', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
          '苏', '浙', '京', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤',
          '桂', '琼', '川', '贵', '云', '藏', '陕', '甘', '青', '宁', '新', '警', '学']
# 字母（无I/O）
CHARS += ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
# 数字
CHARS += [str(i) for i in range(10)]

NUM_CLASSES = len(CHARS)
CHAR2IDX = {c: i for i, c in enumerate(CHARS)}
IDX2CHAR = {i: c for i, c in enumerate(CHARS)}


# 省份映射（官方CCPD定义）
PROVINCES = ['皖', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
             '苏', '浙', '京', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤',
             '桂', '琼', '川', '贵', '云', '藏', '陕', '甘', '青', '宁', '新', '警', '学', 'O']
ALPHABETS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'O']
ADS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'O']


def parse_ccpd_filename(filename):
    """解析CCPD文件名中的车牌号码"""
    name = Path(filename).stem
    parts = name.split('-')

    plate_part = parts[4]
    indices = list(map(int, plate_part.split('_')))

    plate = PROVINCES[indices[0]] + ALPHABETS[indices[1]]
    for idx in indices[2:]:
        plate += ADS[idx]

    return plate


def parse_ccpd_vertices(filename):
    """解析CCPD文件名中的四个顶点坐标"""
    name = Path(filename).stem
    parts = name.split('-')

    vertices_part = parts[3]
    vertices = []
    for v in vertices_part.split('_'):
        x, y = map(int, v.split('&'))
        vertices.append([x, y])

    return np.array(vertices, dtype=np.float32)


class CCPDDataset(Dataset):
    """
    CCPD2019数据集 - 优化版
    """
    def __init__(self, data_root, split_file, img_size=(94, 24), augment=False, augment_level='medium'):
        self.data_root = Path(data_root)
        self.img_size = img_size
        self.augment = augment
        self.augment_level = augment_level

        # 读取文件列表
        with open(split_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        self.samples = []
        for line in lines:
            line = line.strip()
            if not line:
                continue

            img_path = self.data_root / line
            if img_path.exists():
                try:
                    plate = parse_ccpd_filename(img_path.name)
                    self.samples.append((str(img_path), plate))
                except Exception as e:
                    pass

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
            img = np.zeros((self.img_size[1], self.img_size[0], 3), dtype=np.uint8)

        # 解析并裁剪车牌区域
        try:
            vertices = parse_ccpd_vertices(Path(img_path).name)

            # 透视变换将车牌矫正为矩形
            dst_pts = np.array([
                [self.img_size[0], self.img_size[1]],  # 右下
                [0, self.img_size[1]],                 # 左下
                [0, 0],                                # 左上
                [self.img_size[0], 0]                  # 右上
            ], dtype=np.float32)

            M = cv2.getPerspectiveTransform(vertices, dst_pts)
            img = cv2.warpPerspective(img, M, self.img_size)

        except Exception as e:
            img = cv2.resize(img, self.img_size)

        # 数据增强
        if self.augment:
            img = self._augment(img)

        # BGR to RGB
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = self.transform(img)

        # 标签转换为索引
        label = [CHAR2IDX[c] for c in plate if c in CHAR2IDX]
        label_length = len(label)

        return img, torch.tensor(label, dtype=torch.long), label_length

    def _augment(self, img):
        """增强版数据增强 - 针对车牌识别场景深度优化"""
        img = np.ascontiguousarray(img)  # 确保内存连续，避免OpenCV异常
        h, w = img.shape[:2]

        if self.augment_level == 'light':
            probs = {
                'brightness': 0.5, 'contrast': 0.5, 'blur': 0.2,
                'noise': 0.3, 'crop': 0.3, 'shift': 0.3,
                'saturation': 0.3, 'rotation': 0.0, 'perspective': 0.0,
                'morph': 0.1
            }
        elif self.augment_level == 'medium':
            probs = {
                'brightness': 0.7, 'contrast': 0.7, 'blur': 0.3,
                'noise': 0.4, 'crop': 0.4, 'shift': 0.4,
                'saturation': 0.4, 'rotation': 0.2, 'perspective': 0.15,
                'morph': 0.2
            }
        else:  # strong
            probs = {
                'brightness': 0.8, 'contrast': 0.8, 'blur': 0.4,
                'noise': 0.5, 'crop': 0.5, 'shift': 0.5,
                'saturation': 0.5, 'rotation': 0.3, 'perspective': 0.25,
                'morph': 0.3
            }

        # 1. 随机亮度调整
        if random.random() < probs['brightness']:
            factor = random.uniform(0.5, 1.5)
            img = cv2.convertScaleAbs(img, alpha=factor, beta=0)

        # 2. 随机对比度
        if random.random() < probs['contrast']:
            mean = img.mean()
            factor = random.uniform(0.6, 1.4)
            img = np.clip((img - mean) * factor + mean, 0, 255).astype(np.uint8)

        # 3. 高斯模糊
        if random.random() < probs['blur']:
            kernel = 3  # 固定kernel大小避免异常
            if min(img.shape[:2]) >= 3:  # 确保图像足够大
                img = cv2.GaussianBlur(img, (kernel, kernel), 0)

        # 4. 高斯噪声
        if random.random() < probs['noise']:
            noise_level = random.uniform(2, 15)
            noise = np.random.normal(0, noise_level, img.shape).astype(np.float32)
            img = np.clip(img.astype(np.float32) + noise, 0, 255).astype(np.uint8)

        # 5. 随机裁剪（模拟检测框不准）
        if random.random() < probs['crop']:
            crop_ratio = random.uniform(0.01, 0.05)
            x1 = int(w * random.uniform(0, crop_ratio))
            y1 = int(h * random.uniform(0, crop_ratio))
            x2 = int(w * (1 - random.uniform(0, crop_ratio)))
            y2 = int(h * (1 - random.uniform(0, crop_ratio)))
            # 确保有效裁剪
            x2 = max(x2, x1 + 1)
            y2 = max(y2, y1 + 1)
            img = img[y1:y2, x1:x2]
            if img.size > 0:
                img = cv2.resize(img, self.img_size)

        # 6. 随机水平平移
        if random.random() < probs['shift']:
            shift_x = random.randint(-3, 3)
            M = np.float32([[1, 0, shift_x], [0, 1, 0]])
            img = cv2.warpAffine(img, M, self.img_size, borderMode=cv2.BORDER_REPLICATE)

        # 7. 饱和度调整
        if random.random() < probs['saturation']:
            hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV).astype(np.float32)
            saturation_factor = random.uniform(0.7, 1.3)
            hsv[:, :, 1] *= saturation_factor
            hsv[:, :, 1] = np.clip(hsv[:, :, 1], 0, 255)
            img = cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR)

        # 8. 随机旋转（轻度，模拟车牌倾斜）
        if random.random() < probs['rotation']:
            angle = random.uniform(-3, 3)  # 小角度旋转
            center = (w // 2, h // 2)
            M = cv2.getRotationMatrix2D(center, angle, 1.0)
            img = cv2.warpAffine(img, M, self.img_size, borderMode=cv2.BORDER_REPLICATE)

        # 9. 透视变换增强（模拟视角变化）
        if random.random() < probs['perspective'] and min(w, h) > 10:
            # 随机扰动四个角点
            pts1 = np.float32([[0, 0], [w, 0], [w, h], [0, h]])
            max_shift = min(3, w//10, h//10)  # 确保不超过图像尺寸
            pts2 = np.float32([
                [random.uniform(0, max_shift), random.uniform(0, max_shift)],
                [w - random.uniform(0, max_shift), random.uniform(0, max_shift)],
                [w - random.uniform(0, max_shift), h - random.uniform(0, max_shift)],
                [random.uniform(0, max_shift), h - random.uniform(0, max_shift)]
            ])
            try:
                M = cv2.getPerspectiveTransform(pts1, pts2)
                img = cv2.warpPerspective(img, M, self.img_size, borderMode=cv2.BORDER_REPLICATE)
            except cv2.error:
                pass  # 如果失败则跳过此增强

        # 10. 形态学操作（腐蚀/膨胀，模拟字符粗细变化）
        if random.random() < probs['morph'] and min(img.shape[:2]) >= 3:
            kernel_size = 3  # 固定3x3避免异常
            kernel = np.ones((kernel_size, kernel_size), np.uint8)
            if random.random() > 0.5:
                img = cv2.erode(img, kernel, iterations=1)  # 腐蚀（变细）
            else:
                img = cv2.dilate(img, kernel, iterations=1)  # 膨胀（变粗）

        return img


def collate_fn(batch):
    """自定义collate函数处理变长序列"""
    images, labels, label_lengths = zip(*batch)

    images = torch.stack(images, 0)
    labels = torch.cat(labels, 0)
    label_lengths = torch.tensor(label_lengths, dtype=torch.long)

    return images, labels, label_lengths


def decode_ctc(pred_seq, blank=0):
    """CTC解码 - 移除重复和blank"""
    prev = -1
    result = ''
    for p in pred_seq:
        if p != prev and p != blank:
            result += IDX2CHAR.get(p, '')
        prev = p
    return result


def train_epoch(model, dataloader, criterion, optimizer, device, scheduler=None, scaler=None, use_amp=True):
    """训练一个epoch - 支持混合精度"""
    model.train()
    total_loss = 0
    correct = 0
    total = 0
    char_correct = 0
    char_total = 0

    pbar = tqdm(dataloader, desc='Training')
    for images, labels, label_lengths in pbar:
        images = images.to(device)
        labels = labels.to(device)
        label_lengths = label_lengths.to(device)

        # 使用混合精度
        with autocast(enabled=use_amp):
            outputs = model(images)  # [T, B, C]

            input_lengths = torch.full(
                size=(outputs.size(1),),
                fill_value=outputs.size(0),
                dtype=torch.long,
                device=device
            )

            loss = criterion(outputs.log_softmax(2), labels, input_lengths, label_lengths)

        # 反向传播
        optimizer.zero_grad()

        if use_amp and scaler is not None:
            scaler.scale(loss).backward()
            scaler.unscale_(optimizer)
            clip_grad_norm_(model.parameters(), max_norm=5)
            scaler.step(optimizer)
            scaler.update()
        else:
            loss.backward()
            clip_grad_norm_(model.parameters(), max_norm=5)
            optimizer.step()

        if scheduler is not None:
            scheduler.step()

        total_loss += loss.item()

        # 计算准确率
        with torch.no_grad():
            preds = outputs.argmax(dim=2).cpu().numpy()
            label_list = labels.cpu().numpy()

            # 解码并计算准确率
            idx_start = 0
            for b in range(preds.shape[1]):
                pred_text = decode_ctc(preds[:, b])

                true_len = label_lengths[b].item()
                true_text = ''.join([IDX2CHAR.get(label_list[idx_start + i], '') for i in range(true_len)])
                idx_start += true_len

                # 整串准确率
                if pred_text == true_text:
                    correct += 1
                total += 1

                # 字符级准确率
                min_len = min(len(pred_text), len(true_text))
                for i in range(min_len):
                    if pred_text[i] == true_text[i]:
                        char_correct += 1
                char_total += len(true_text)

        pbar.set_postfix({
            'loss': f'{loss.item():.4f}',
            'acc': f'{100.*correct/total:.2f}%',
            'char_acc': f'{100.*char_correct/char_total:.2f}%'
        })

    avg_loss = total_loss / len(dataloader)
    accuracy = correct / total if total > 0 else 0
    char_accuracy = char_correct / char_total if char_total > 0 else 0

    return avg_loss, accuracy, char_accuracy


def validate(model, dataloader, criterion, device, use_amp=True):
    """验证模型 - 支持混合精度"""
    model.eval()
    total_loss = 0
    correct = 0
    total = 0
    char_correct = 0
    char_total = 0

    with torch.no_grad():
        for images, labels, label_lengths in tqdm(dataloader, desc='Validating'):
            images = images.to(device)
            labels = labels.to(device)
            label_lengths = label_lengths.to(device)

            with autocast(enabled=use_amp):
                outputs = model(images)

                input_lengths = torch.full(
                    size=(outputs.size(1),),
                    fill_value=outputs.size(0),
                    dtype=torch.long,
                    device=device
                )

                loss = criterion(outputs.log_softmax(2), labels, input_lengths, label_lengths)
                total_loss += loss.item()

            # 计算准确率
            preds = outputs.argmax(dim=2).cpu().numpy()
            label_list = labels.cpu().numpy()

            idx_start = 0
            for b in range(preds.shape[1]):
                pred_text = decode_ctc(preds[:, b])

                true_len = label_lengths[b].item()
                true_text = ''.join([IDX2CHAR.get(label_list[idx_start + i], '') for i in range(true_len)])
                idx_start += true_len

                if pred_text == true_text:
                    correct += 1
                total += 1

                min_len = min(len(pred_text), len(true_text))
                for i in range(min_len):
                    if pred_text[i] == true_text[i]:
                        char_correct += 1
                char_total += len(true_text)

    avg_loss = total_loss / len(dataloader)
    accuracy = correct / total if total > 0 else 0
    char_accuracy = char_correct / char_total if char_total > 0 else 0

    return avg_loss, accuracy, char_accuracy


def train(args):
    """主训练函数 - 优化版"""

    # 设置随机种子
    torch.manual_seed(args.seed)
    np.random.seed(args.seed)
    random.seed(args.seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed(args.seed)
        torch.backends.cudnn.deterministic = True
        torch.backends.cudnn.benchmark = True  # 启用benchmark加速

    # 设备
    device = torch.device('cuda' if torch.cuda.is_available() and not args.cpu else 'cpu')
    print(f"使用设备: {device}")
    if device.type == 'cuda':
        print(f"GPU: {torch.cuda.get_device_name(0)}")
        print(f"显存: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB")

    # 创建模型
    model = LPRNet(num_classes=NUM_CLASSES, dropout_rate=args.dropout)
    model = model.to(device)

    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"模型总参数: {total_params:,}")
    print(f"可训练参数: {trainable_params:,}")

    # 数据集
    train_dataset = CCPDDataset(
        args.data_root,
        args.train_split,
        img_size=(args.img_width, args.img_height),
        augment=True,
        augment_level=args.augment_level
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
        pin_memory=True,
        persistent_workers=True if args.num_workers > 0 else False
    )

    val_loader = DataLoader(
        val_dataset,
        batch_size=args.batch_size,
        shuffle=False,
        num_workers=args.num_workers,
        collate_fn=collate_fn,
        pin_memory=True
    )

    # 损失函数
    criterion = nn.CTCLoss(blank=0, reduction='mean', zero_infinity=True)

    # 优化器
    if args.optimizer == 'adamw':
        optimizer = optim.AdamW(
            model.parameters(),
            lr=args.lr,
            weight_decay=args.weight_decay,
            betas=(0.9, 0.999)
        )
    elif args.optimizer == 'adam':
        optimizer = optim.Adam(
            model.parameters(),
            lr=args.lr,
            weight_decay=args.weight_decay
        )
    else:  # sgd
        optimizer = optim.SGD(
            model.parameters(),
            lr=args.lr,
            momentum=0.9,
            weight_decay=args.weight_decay
        )

    # 学习率调度
    total_steps = len(train_loader) * args.epochs
    warmup_steps = len(train_loader) * args.warmup_epochs

    if args.scheduler == 'cosine':
        def lr_lambda(step):
            if step < warmup_steps:
                return step / warmup_steps
            else:
                progress = (step - warmup_steps) / (total_steps - warmup_steps)
                return 0.5 * (1 + np.cos(np.pi * progress))
        scheduler = optim.lr_scheduler.LambdaLR(optimizer, lr_lambda)
    elif args.scheduler == 'step':
        scheduler = optim.lr_scheduler.StepLR(
            optimizer, step_size=len(train_loader) * 20, gamma=0.5
        )
    else:
        scheduler = None

    print(f"总步数: {total_steps}, 预热步数: {warmup_steps}")
    print(f"优化器: {args.optimizer}, 调度器: {args.scheduler}")
    print(f"学习率: {args.lr}, 数据增强: {args.augment_level}")

    # 创建输出目录
    os.makedirs(args.output_dir, exist_ok=True)

    # 混合精度训练
    scaler = GradScaler() if args.amp and torch.cuda.is_available() else None
    if args.amp:
        print("启用混合精度训练 (AMP)")

    # 训练循环
    best_acc = 0
    best_char_acc = 0
    patience_counter = 0
    history = {
        'train_loss': [], 'train_acc': [], 'train_char_acc': [],
        'val_loss': [], 'val_acc': [], 'val_char_acc': []
    }

    for epoch in range(args.epochs):
        print(f"\nEpoch {epoch+1}/{args.epochs}")
        print("-" * 60)

        # 训练
        train_loss, train_acc, train_char_acc = train_epoch(
            model, train_loader, criterion, optimizer, device, scheduler, scaler, args.amp
        )

        # 验证
        val_loss, val_acc, val_char_acc = validate(model, val_loader, criterion, device, args.amp)

        # 获取当前学习率
        current_lr = optimizer.param_groups[0]['lr']

        print(f"Train Loss: {train_loss:.4f}, Acc: {train_acc*100:.2f}%, Char Acc: {train_char_acc*100:.2f}%")
        print(f"Val   Loss: {val_loss:.4f}, Acc: {val_acc*100:.2f}%, Char Acc: {val_char_acc*100:.2f}%")
        print(f"LR: {current_lr:.6f}")

        history['train_loss'].append(train_loss)
        history['train_acc'].append(train_acc)
        history['train_char_acc'].append(train_char_acc)
        history['val_loss'].append(val_loss)
        history['val_acc'].append(val_acc)
        history['val_char_acc'].append(val_char_acc)

        # 保存最佳模型
        improved = False
        if val_acc > best_acc:
            best_acc = val_acc
            improved = True
            checkpoint = {
                'epoch': epoch,
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'val_acc': val_acc,
                'val_char_acc': val_char_acc,
                'char_dict': {'chars': CHARS, 'char2idx': CHAR2IDX, 'idx2char': IDX2CHAR},
                'args': vars(args)
            }
            torch.save(checkpoint, os.path.join(args.output_dir, 'best_model.pth'))
            print(f"★ 保存最佳模型，准确率: {val_acc*100:.2f}%")

        if val_char_acc > best_char_acc:
            best_char_acc = val_char_acc

        # 早停检查
        if not improved:
            patience_counter += 1
            if patience_counter >= args.patience:
                print(f"\n早停！{args.patience} 轮未改善")
                break
        else:
            patience_counter = 0

        # 定期保存
        if (epoch + 1) % args.save_interval == 0:
            checkpoint = {
                'epoch': epoch,
                'model_state_dict': model.state_dict(),
                'val_acc': val_acc,
                'val_char_acc': val_char_acc
            }
            torch.save(checkpoint, os.path.join(args.output_dir, f'checkpoint_epoch_{epoch+1}.pth'))

    print(f"\n{'='*60}")
    print(f"训练完成！")
    print(f"最佳整串准确率: {best_acc*100:.2f}%")
    print(f"最佳字符准确率: {best_char_acc*100:.2f}%")
    print(f"模型保存在: {args.output_dir}")
    print(f"{'='*60}")

    return history


def main():
    parser = argparse.ArgumentParser(description='CCPD2019 车牌识别训练 V2 (优化版)')

    # 数据参数
    parser.add_argument('--data-root', type=str, default='data/CCPD2019')
    parser.add_argument('--train-split', type=str, default='data/CCPD2019/splits/train.txt')
    parser.add_argument('--val-split', type=str, default='data/CCPD2019/splits/val.txt')

    # 模型参数
    parser.add_argument('--img-width', type=int, default=94)
    parser.add_argument('--img-height', type=int, default=24)
    parser.add_argument('--dropout', type=float, default=0.3)

    # 训练参数
    parser.add_argument('--epochs', type=int, default=50)
    parser.add_argument('--batch-size', type=int, default=512)
    parser.add_argument('--lr', type=float, default=0.001)
    parser.add_argument('--weight-decay', type=float, default=0.0003)
    parser.add_argument('--num-workers', type=int, default=8)

    # 优化器选择
    parser.add_argument('--optimizer', type=str, default='adamw', choices=['adamw', 'adam', 'sgd'])
    parser.add_argument('--scheduler', type=str, default='cosine', choices=['cosine', 'step', 'none'])

    # 数据增强
    parser.add_argument('--augment-level', type=str, default='medium', choices=['light', 'medium', 'strong'])

    # 早停
    parser.add_argument('--patience', type=int, default=10, help='早停耐心值')
    parser.add_argument('--warmup-epochs', type=int, default=3, help='预热轮数')

    # 混合精度
    parser.add_argument('--amp', action='store_true', default=True, help='启用混合精度训练')
    parser.add_argument('--no-amp', action='store_true', help='禁用混合精度训练')

    # 其他参数
    parser.add_argument('--output-dir', type=str, default='weights/recognition')
    parser.add_argument('--save-interval', type=int, default=10)
    parser.add_argument('--seed', type=int, default=42)
    parser.add_argument('--cpu', action='store_true')

    args = parser.parse_args()

    if args.no_amp:
        args.amp = False

    train(args)


if __name__ == '__main__':
    main()

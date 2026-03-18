#!/usr/bin/env python3
"""
简化版车牌识别训练脚本 (LPRNet)
"""
import os
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import sys
import random
import numpy as np
from pathlib import Path
from tqdm import tqdm

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torch.nn.utils import clip_grad_norm_
import torchvision.transforms as transforms
import cv2

sys.path.insert(0, 'src')
from models.recognition.lprnet import LPRNet

# 字符集
CHARS = ['blank'] + [str(i) for i in range(10)] + [chr(i) for i in range(65, 91)] + \
        ['皖', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
         '苏', '浙', '京', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤',
         '桂', '琼', '川', '贵', '云', '藏', '陕', '甘', '青', '宁', '新']
CHAR2IDX = {c: i for i, c in enumerate(CHARS)}
IDX2CHAR = {i: c for i, c in enumerate(CHARS)}

def parse_plate(filename):
    """从CCPD文件名解析车牌"""
    parts = Path(filename).stem.split('-')
    indices = list(map(int, parts[4].split('_')))

    provinces = ['皖', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
                 '苏', '浙', '京', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤',
                 '桂', '琼', '川', '贵', '云', '藏', '陕', '甘', '青', '宁', '新']
    alphabets = [chr(i) for i in range(65, 91)]
    ads = [str(i) for i in range(10)] + alphabets

    plate = provinces[indices[0]] + alphabets[indices[1]]
    for idx in indices[2:]:
        plate += ads[idx]
    return plate

def parse_vertices(filename):
    """解析四个顶点"""
    parts = Path(filename).stem.split('-')
    vertices = []
    for v in parts[3].split('_'):
        x, y = map(int, v.split('&'))
        vertices.append([x, y])
    return np.array(vertices, dtype=np.float32)

class PlateDataset(Dataset):
    def __init__(self, split_file, img_size=(94, 24), augment=False):
        self.data_root = Path('data/CCPD2019')
        self.img_size = img_size
        self.augment = augment

        with open(split_file, 'r') as f:
            lines = f.readlines()

        self.samples = []
        for line in lines:
            line = line.strip()
            if line:
                img_path = self.data_root / line
                if img_path.exists():
                    try:
                        plate = parse_plate(img_path.name)
                        self.samples.append((str(img_path), plate))
                    except:
                        pass

        print(f"{split_file}: {len(self.samples)} 个样本")

        self.transform = transforms.Compose([
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.5, 0.5, 0.5], std=[0.5, 0.5, 0.5])
        ])

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        img_path, plate = self.samples[idx]

        img = cv2.imread(img_path)
        if img is None:
            img = np.zeros((self.img_size[1], self.img_size[0], 3), dtype=np.uint8)

        # 透视变换矫正
        try:
            vertices = parse_vertices(Path(img_path).name)
            dst_pts = np.array([
                [self.img_size[0], self.img_size[1]],
                [0, self.img_size[1]],
                [0, 0],
                [self.img_size[0], 0]
            ], dtype=np.float32)
            M = cv2.getPerspectiveTransform(vertices, dst_pts)
            img = cv2.warpPerspective(img, M, self.img_size)
        except:
            img = cv2.resize(img, self.img_size)

        # 数据增强
        if self.augment:
            img = self.augment_img(img)

        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = self.transform(img)

        label = [CHAR2IDX[c] for c in plate if c in CHAR2IDX]
        return img, torch.tensor(label, dtype=torch.long), len(label)

    def augment_img(self, img):
        h, w = img.shape[:2]

        if random.random() > 0.3:
            img = cv2.convertScaleAbs(img, alpha=random.uniform(0.6, 1.4), beta=0)

        if random.random() > 0.3:
            mean = img.mean()
            factor = random.uniform(0.7, 1.3)
            img = np.clip((img - mean) * factor + mean, 0, 255).astype(np.uint8)

        if random.random() > 0.8:
            kernel = random.choice([3, 5])
            img = cv2.GaussianBlur(img, (kernel, kernel), 0)

        if random.random() > 0.8:
            noise = np.random.normal(0, random.uniform(3, 12), img.shape)
            img = np.clip(img.astype(np.float32) + noise, 0, 255).astype(np.uint8)

        if random.random() > 0.7:
            crop = random.uniform(0.02, 0.08)
            x1, y1 = int(w * crop), int(h * crop)
            x2, y2 = int(w * (1-crop)), int(h * (1-crop))
            img = cv2.resize(img[y1:y2, x1:x2], self.img_size)

        return img

def collate_fn(batch):
    images, labels, lengths = zip(*batch)
    return torch.stack(images, 0), torch.cat(labels, 0), torch.tensor(lengths, dtype=torch.long)

def train():
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"设备: {device}\n")

    # 数据集
    train_dataset = PlateDataset('data/CCPD2019/splits/train.txt', augment=True)
    val_dataset = PlateDataset('data/CCPD2019/splits/val.txt', augment=False)

    train_loader = DataLoader(train_dataset, batch_size=512, shuffle=True,
                              num_workers=8, collate_fn=collate_fn, pin_memory=True)
    val_loader = DataLoader(val_dataset, batch_size=512, shuffle=False,
                            num_workers=8, collate_fn=collate_fn, pin_memory=True)

    # 模型
    model = LPRNet(num_classes=len(CHARS), dropout_rate=0.3).to(device)
    print(f"模型参数: {sum(p.numel() for p in model.parameters()):,}\n")

    # 优化器
    criterion = nn.CTCLoss(blank=0, reduction='mean', zero_infinity=True)
    optimizer = optim.AdamW(model.parameters(), lr=0.001, weight_decay=0.0003)

    # 学习率调度: 预热 + 余弦退火
    total_steps = len(train_loader) * 10
    warmup_steps = len(train_loader) * 3

    def lr_lambda(step):
        if step < warmup_steps:
            return step / warmup_steps
        else:
            return 0.5 * (1 + np.cos(np.pi * (step - warmup_steps) / (total_steps - warmup_steps)))

    scheduler = optim.lr_scheduler.LambdaLR(optimizer, lr_lambda)

    best_acc = 0

    for epoch in range(10):
        # 训练
        model.train()
        train_loss, correct, total = 0, 0, 0

        for images, labels, label_lengths in tqdm(train_loader, desc=f'Epoch {epoch+1}/10'):
            images = images.to(device)
            labels = labels.to(device)
            label_lengths = label_lengths.to(device)

            outputs = model(images)  # [T, B, C]

            input_lengths = torch.full((outputs.size(1),), outputs.size(0), dtype=torch.long, device=device)
            loss = criterion(outputs, labels, input_lengths, label_lengths)

            optimizer.zero_grad()
            loss.backward()
            clip_grad_norm_(model.parameters(), max_norm=5)
            optimizer.step()
            scheduler.step()

            train_loss += loss.item()

            # 计算准确率
            preds = outputs.argmax(dim=2).cpu().numpy()
            for b in range(preds.shape[1]):
                pred_seq = preds[:, b]
                prev = -1
                pred_text = ''.join([IDX2CHAR[p] for p in pred_seq if p != prev and p != 0 and not (prev := p)])

                idx_start = sum(label_lengths[:b].tolist()) if b > 0 else 0
                true_len = label_lengths[b].item()
                true_text = ''.join([IDX2CHAR[labels[i].item()] for i in range(idx_start, idx_start + true_len)])

                if pred_text == true_text:
                    correct += 1
                total += 1

        train_acc = correct / total if total > 0 else 0

        # 验证
        model.eval()
        val_loss, correct, total = 0, 0, 0

        with torch.no_grad():
            for images, labels, label_lengths in val_loader:
                images = images.to(device)
                labels = labels.to(device)
                label_lengths = label_lengths.to(device)

                outputs = model(images)
                input_lengths = torch.full((outputs.size(1),), outputs.size(0), dtype=torch.long, device=device)
                loss = criterion(outputs, labels, input_lengths, label_lengths)
                val_loss += loss.item()

                preds = outputs.argmax(dim=2).cpu().numpy()
                for b in range(preds.shape[1]):
                    pred_seq = preds[:, b]
                    prev = -1
                    pred_text = ''.join([IDX2CHAR[p] for p in pred_seq if p != prev and p != 0 and not (prev := p)])

                    idx_start = sum(label_lengths[:b].tolist()) if b > 0 else 0
                    true_len = label_lengths[b].item()
                    true_text = ''.join([IDX2CHAR[labels[i].item()] for i in range(idx_start, idx_start + true_len)])

                    if pred_text == true_text:
                        correct += 1
                    total += 1

        val_acc = correct / total if total > 0 else 0
        current_lr = optimizer.param_groups[0]['lr']

        print(f"Epoch {epoch+1}: Train Loss={train_loss/len(train_loader):.4f}, Train Acc={train_acc*100:.2f}%, "
              f"Val Loss={val_loss/len(val_loader):.4f}, Val Acc={val_acc*100:.2f}%, LR={current_lr:.6f}")

        # 保存最佳模型
        if val_acc > best_acc:
            best_acc = val_acc
            Path('weights').mkdir(exist_ok=True)
            torch.save({
                'epoch': epoch,
                'model_state_dict': model.state_dict(),
                'val_acc': val_acc,
                'chars': CHARS
            }, 'weights/lprnet_best.pth')
            print(f"  -> 保存最佳模型 (Val Acc: {val_acc*100:.2f}%)")

    print(f"\n训练完成！最佳验证准确率: {best_acc*100:.2f}%")

if __name__ == '__main__':
    train()

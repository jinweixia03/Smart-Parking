# CCPD2019 训练策略完整指南

## 一、当前训练策略分析

### 1.1 检测模型 (YOLOv8) 策略

```python
# 优化器配置
optimizer='AdamW'           # Adam + 权重衰减解耦
lr0=0.001                   # 初始学习率
lrf=0.01                    # 最终学习率 = lr0 * lrf = 0.00001
momentum=0.937             # SGD动量 (AdamW中使用beta1)
weight_decay=0.0005        # L2正则化

# 学习率调度
warmup_epochs=3.0          # 预热轮数
warmup_momentum=0.8        # 预热期间动量
# 主调度: CosineAnnealing (余弦退火)

# 早停机制
patience=20                # 20轮无改善则停止
```

**学习率曲线**:
```
学习率
  │    ╭────╮
  │   ╱      ╲_______
  │  ╱  预热  ╲      余弦退火
  │ ╱          ╲
  │╱____________╲__________
  └──────────────────────────▶ Epoch
    0     3              100
```

### 1.2 识别模型 (LPRNet) 策略

```python
# 优化器配置
optimizer = AdamW(
    lr=0.001,              # 初始学习率
    weight_decay=0.0005    # L2正则化
)

# 学习率调度: 余弦退火热重启
scheduler = CosineAnnealingWarmRestarts(
    T_0=10,                # 第一次重启周期
    T_mult=2               # 每次重启后周期翻倍 (10, 20, 40...)
)

# 损失函数
criterion = nn.CTCLoss(
    blank=0,               # 空白标签索引
    reduction='mean',      # 平均损失
    zero_infinity=True     # 防止无穷大损失
)

# 梯度裁剪
clip_grad_norm_(max_norm=5)  # 防止梯度爆炸
```

**学习率曲线 (热重启)**:
```
学习率
  │╮   ╭╮       ╭╮
  │ ╲ ╱  ╲     ╱  ╲
  │  ╳    ╲   ╱    ╲
  │ ╱ ╲    ╲ ╱      ╲
  │╱   ╲____╳________╲___
  └──────────────────────────▶ Epoch
    0  10  20  40      80
       ↑   ↑   ↑
      重启点
```

---

## 二、不同场景的训练策略

### 2.1 快速收敛策略 (适合实验验证)

```bash
# 检测模型 - 快速验证
python train_detection.py \
    --data-root data/CCPD2019 \
    --epochs 50 \
    --batch 64 \
    --lr0 0.005 \
    --lrf 0.05 \
    --warmup_epochs 1 \
    --patience 10 \
    --model yolov8n.pt

# 识别模型 - 快速验证
python train_recognition.py \
    --data-root data/CCPD2019 \
    --epochs 50 \
    --batch-size 512 \
    --lr 0.002 \
    --weight-decay 0.0001
```

**特点**:
- 大学习率 (0.002-0.005): 快速探索损失空间
- 大批量 (64-512): 稳定的梯度估计
- 少轮数 (50): 快速验证代码正确性
- 短预热 (1 epoch): 快速进入正常训练

**适用场景**: 代码调试、超参搜索、快速验证

---

### 2.2 高精度策略 (适合生产部署)

```bash
# 检测模型 - 高精度
python train_detection.py \
    --data-root data/CCPD2019 \
    --epochs 200 \
    --batch 16 \
    --lr0 0.001 \
    --lrf 0.001 \
    --warmup_epochs 5 \
    --patience 50 \
    --model yolov8m.pt \
    --img-size 800

# 识别模型 - 高精度
python train_recognition.py \
    --data-root data/CCPD2019 \
    --epochs 200 \
    --batch-size 128 \
    --lr 0.0005 \
    --weight-decay 0.001 \
    --dropout 0.3
```

**特点**:
- 小学习率 (0.0005): 精细调整权重
- 小衰减系数 (0.001): 学习率缓慢下降
- 多轮数 (200): 充分训练
- 大模型 (YOLOv8m): 更强的表达能力
- 高分辨率 (800): 更精细的特征

**适用场景**: 生产环境、高精度要求

---

### 2.3 边缘部署策略 (适合移动端/嵌入式)

```bash
# 检测模型 - 轻量化
python train_detection.py \
    --data-root data/CCPD2019 \
    --epochs 150 \
    --batch 32 \
    --lr0 0.001 \
    --lrf 0.01 \
    --model yolov8n.pt \
    --img-size 480

# 识别模型 - 轻量化 (需要修改模型结构)
```

**模型轻量化修改** (LPRNet):
```python
# 减少通道数
class LPRNet_Light(nn.Module):
    def __init__(self, num_classes):
        super().__init__()
        # 原: 64 -> 128 -> 256 -> 256
        # 改: 32 -> 64 -> 128 -> 128
        self.stem = nn.Sequential(
            nn.Conv2d(3, 32, kernel_size=3, padding=1),  # 减半
            ...
        )
        self.block1 = self._make_block(32, 64)
        self.block2 = self._make_block(64, 128)
        self.block3 = self._make_block(128, 128)
```

**特点**:
- 小模型 (YOLOv8n): 参数量少
- 低分辨率 (480): 计算量小
- 知识蒸馏: 用大模型指导小模型训练

---

## 三、学习率调度策略详解

### 3.1 预热 (Warmup) 的必要性

**问题**: 训练初期使用大学习率会导致：
- 梯度爆炸
- 权重更新过大
- 模型收敛到次优解

**解决方案**:
```python
# 线性预热: 从0逐渐增加到初始学习率
if epoch < warmup_epochs:
    lr = initial_lr * (epoch / warmup_epochs)
```

**效果对比**:
```
无预热:    损失震荡大，收敛慢
有预热:    损失平稳下降，收敛快
```

### 3.2 余弦退火 (Cosine Annealing)

**公式**:
```
η_t = η_min + (η_max - η_min) * (1 + cos(πT_cur/T_i)) / 2
```

**PyTorch实现**:
```python
# 简单余弦退火
scheduler = CosineAnnealingLR(optimizer, T_max=100, eta_min=0)

# 热重启余弦退火 (推荐)
scheduler = CosineAnnealingWarmRestarts(
    optimizer,
    T_0=10,      # 初始周期
    T_mult=2     # 周期倍增因子
)
```

**为什么热重启有效**:
1. 周期性增大学习率，跳出局部最优
2. 模拟集成学习效果
3. 探索更广阔的参数空间

### 3.3 学习率与批次大小的关系

**线性缩放规则**:
```
lr_new = lr_base * (batch_size_new / batch_size_base)
```

**示例**:
```
基础配置: lr=0.001, batch=16
增大到batch=64: lr = 0.001 * (64/16) = 0.004
```

**注意**: 使用AdamW时，这个规则不那么严格，但仍建议适当增大学习率。

---

## 四、数据增强策略

### 4.1 检测模型增强 (YOLOv8内置)

```python
# 当前配置
hsv_h=0.015,      # HSV色调变化 ±1.5%
hsv_s=0.7,        # HSV饱和度变化 ±70%
hsv_v=0.4,        # HSV明度变化 ±40%
degrees=5.0,      # 旋转 ±5度
translate=0.1,    # 平移 ±10%
scale=0.5,        # 缩放 50%-150%
shear=2.0,        # 剪切 ±2度
mosaic=1.0,       # Mosaic增强概率100%
fliplr=0.5,       # 左右翻转概率50%
```

**针对车牌场景的优化建议**:
```python
# 车牌通常不会大幅旋转或翻转
degrees=3.0       # 减小旋转，车牌角度变化小
translate=0.05    # 减小平移，车牌位置相对固定
scale=0.3         # 减小缩放，车牌大小变化有限
flipud=0.0        # 不进行上下翻转（车牌不会倒立）
```

### 4.2 识别模型增强

**当前实现**:
```python
def _augment(self, img):
    # 随机亮度 ±20%
    if random.random() > 0.5:
        factor = random.uniform(0.8, 1.2)
        img = np.clip(img * factor, 0, 255).astype(np.uint8)

    # 随机对比度 ±20%
    if random.random() > 0.5:
        mean = img.mean()
        factor = random.uniform(0.8, 1.2)
        img = np.clip((img - mean) * factor + mean, 0, 255).astype(np.uint8)

    # 随机高斯噪声 (20%概率)
    if random.random() > 0.8:
        noise = np.random.normal(0, 5, img.shape).astype(np.float32)
        img = np.clip(img.astype(np.float32) + noise, 0, 255).astype(np.uint8)

    return img
```

**增强建议**:
```python
def _augment_advanced(self, img):
    """针对车牌识别的增强"""
    # 1. 亮度调整 (模拟不同光照)
    if random.random() > 0.3:
        factor = random.uniform(0.6, 1.4)  # 更大的范围
        img = cv2.convertScaleAbs(img, alpha=factor, beta=0)

    # 2. 对比度调整
    if random.random() > 0.3:
        factor = random.uniform(0.7, 1.3)
        img = np.clip(img * factor, 0, 255).astype(np.uint8)

    # 3. 高斯模糊 (模拟对焦不准)
    if random.random() > 0.9:
        kernel = random.choice([3, 5])
        img = cv2.GaussianBlur(img, (kernel, kernel), 0)

    # 4. 高斯噪声
    if random.random() > 0.8:
        noise = np.random.normal(0, random.uniform(3, 10), img.shape)
        img = np.clip(img.astype(np.float32) + noise, 0, 255).astype(np.uint8)

    # 5. 随机裁剪 (模拟检测框不准)
    if random.random() > 0.7:
        h, w = img.shape[:2]
        crop_ratio = random.uniform(0.02, 0.08)
        x1 = int(w * random.uniform(0, crop_ratio))
        y1 = int(h * random.uniform(0, crop_ratio))
        x2 = int(w * (1 - random.uniform(0, crop_ratio)))
        y2 = int(h * (1 - random.uniform(0, crop_ratio)))
        img = img[y1:y2, x1:x2]
        img = cv2.resize(img, (self.img_size[0], self.img_size[1]))

    return img
```

---

## 五、正则化策略

### 5.1 Weight Decay (L2正则化)

**作用**: 防止过拟合，限制权重大小

**配置对比**:
| 模型大小 | Weight Decay | 说明 |
|---------|-------------|------|
| 小模型 (YOLOv8n) | 0.0005 | 较小正则，避免欠拟合 |
| 大模型 (YOLOv8m/l) | 0.001 | 较大正则，防止过拟合 |
| 数据量小 | 0.001-0.01 | 强正则防止过拟合 |
| 数据量大 | 0.0001-0.0005 | 弱正则充分利用数据 |

### 5.2 Dropout

**当前配置**: Dropout=0.5

**建议**:
```python
# 数据量充足 (10万+)
nn.Dropout(0.3)  # 适度Dropout

# 数据量较少
nn.Dropout(0.5)  # 强Dropout

# 大模型
nn.Dropout(0.5)  # 强Dropout防过拟合
```

### 5.3 Label Smoothing (标签平滑)

**CTC Loss 不支持直接标签平滑，可在数据层面实现**:

```python
# 多路径数据加载 (Hard Example Mining)
# 对困难样本重复采样
class WeightedSampler:
    def __init__(self, dataset, error_probs):
        self.weights = 1 + error_probs  # 易错样本权重更高

    def sample(self):
        return random.choices(self.dataset, weights=self.weights)
```

---

## 六、训练监控与调参

### 6.1 关键监控指标

**检测模型**:
```python
metrics = {
    'mAP@0.5': '> 0.98',        # 主要指标
    'mAP@0.5:0.95': '> 0.85',   # 严格指标
    'Precision': '> 0.95',      # 精确率
    'Recall': '> 0.95',         # 召回率
    'Box Loss': '< 0.5',        # 边界框损失
    'Cls Loss': '< 0.3',        # 分类损失
}
```

**识别模型**:
```python
metrics = {
    'Accuracy': '> 0.95',       # 整牌准确率
    'Char Accuracy': '> 0.99',  # 字符级准确率
    'CTC Loss': '< 1.0',        # CTC损失
    'Edit Distance': '< 0.1',   # 编辑距离
}
```

### 6.2 训练曲线诊断

```
损失曲线正常:
Train Loss  ╲____          Val Loss  ╲____
             ╲    ╲                  ╲    ╲___
              ╲    ╲____              ╲      ╲___
               ╲________╲              ╲__________╲

损失曲线异常 (过拟合):
Train Loss  ╲                    Val Loss  ╲____
             ╲____                          ╲    ╲╱╲
                  ╲___                       ╲     ╲╱╲
                       ╲___                   ╲______╲

损失曲线异常 (欠拟合):
Train Loss  ╲____                Val Loss  ╲____
                 ╲_╱_╲                        ╲_╱_╲
                    ╲_╱_╲                        ╲_╱_╲
                       ╲_╱_╲                        ╲
```

### 6.3 调参决策树

```
训练效果不佳?
│
├─► 损失不下降 (震荡/高位)
│   ├─► 降低学习率 (lr * 0.1)
│   ├─► 增加预热轮数
│   └─► 检查数据归一化
│
├─► 训练损失下降，验证损失上升 (过拟合)
│   ├─► 增加 Weight Decay
│   ├─► 增加 Dropout
│   ├─► 增加数据增强
│   └─► 早停 (减少轮数)
│
├─► 训练和验证损失都高 (欠拟合)
│   ├─► 增大模型 (n→s→m)
│   ├─► 增加轮数
│   ├─► 降低正则化
│   └─► 增加学习率
│
└─► 收敛速度慢
    ├─► 增大学习率
    ├─► 增大批次大小
    └─► 使用学习率热重启
```

---

## 七、高级技巧

### 7.1 分层学习率

**骨干网络用小学习率，头部网络用大学习率**:

```python
# YOLOv8 内置支持
model.train(
    lr0=0.001,
    freeze=10,  # 冻结前10层
)

# LPRNet 手动实现
optim_groups = [
    {'params': model.stem.parameters(), 'lr': 0.0001},      # 底层小学习率
    {'params': model.block1.parameters(), 'lr': 0.0005},
    {'params': model.block2.parameters(), 'lr': 0.001},
    {'params': model.classifier.parameters(), 'lr': 0.001}, # 分类层大学习率
]
optimizer = AdamW(optim_groups, weight_decay=0.0005)
```

### 7.2 混合精度训练

```python
from torch.cuda.amp import autocast, GradScaler

scaler = GradScaler()

for batch in dataloader:
    optimizer.zero_grad()

    with autocast():  # 自动混合精度
        outputs = model(inputs)
        loss = criterion(outputs, targets)

    scaler.scale(loss).backward()
    scaler.step(optimizer)
    scaler.update()
```

**效果**: 速度提升30-50%，显存节省40%

### 7.3 渐进式调整图像尺寸

```python
# 先在小分辨率训练，再增大
epochs_schedule = [
    (0, 20, 320),    # 前20轮 320x320
    (20, 50, 480),   # 中间30轮 480x480
    (50, 100, 640),  # 后50轮 640x640
]
```

---

## 八、推荐配置汇总

### RTX 4090 Laptop (16GB)

**检测模型**:
```bash
python train_detection.py \
    --data-root data/CCPD2019 \
    --epochs 100 \
    --batch 32 \
    --img-size 640 \
    --lr0 0.001 \
    --lrf 0.01 \
    --warmup_epochs 3 \
    --patience 20 \
    --model yolov8n.pt
```

**识别模型**:
```bash
python train_recognition.py \
    --data-root data/CCPD2019 \
    --epochs 100 \
    --batch-size 256 \
    --lr 0.001 \
    --weight-decay 0.0005 \
    --dropout 0.3
```

### 预期结果

| 模型 | mAP/准确率 | 训练时间 | 模型大小 |
|-----|-----------|---------|---------|
| YOLOv8n | 98.5% | 1小时 | 6MB |
| LPRNet | 96.0% | 2小时 | 2MB |

---

## 九、常见问题排查

### Q: 损失为 NaN
- 降低学习率 (lr * 0.1)
- 检查输入数据归一化
- 减小梯度裁剪阈值 (max_norm=1)

### Q: 验证准确率 plateau (停滞)
- 使用学习率热重启
- 降低学习率
- 增加数据增强

### Q: 训练速度慢
- 增大 batch size
- 使用混合精度训练
- 增加 num_workers
- 使用 SSD 而非 HDD

### Q: 模型过拟合
- 增加 Weight Decay
- 增加 Dropout
- 增加数据增强
- 使用更大的数据集

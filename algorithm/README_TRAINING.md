# 智能停车场 - 算法模型训练

本目录包含基于 CCPD2019 数据集的车牌检测和识别模型训练代码。

## 目录结构

```
algorithm/
├── train_detection.py      # 车牌检测训练 (YOLOv8)
├── train_recognition.py    # 车牌识别训练 (LPRNet)
├── train_all.py            # 一键训练脚本
├── download_ccpd.py        # 数据集下载工具
├── TRAINING_GUIDE.md       # 详细训练指南
├── app.py                  # Flask API 服务
├── requirements.txt        # 依赖列表
├── src/
│   └── models/
│       ├── detection/
│       │   └── yolo_detector.py
│       └── recognition/
│           └── lprnet.py
└── data/
    └── CCPD2019/           # 数据集目录
```

## 快速开始

### 1. 安装依赖

```bash
cd algorithm
pip install -r requirements.txt
pip install torch torchvision ultralytics opencv-python
```

### 2. 下载数据集

```bash
# 查看下载指南
python download_ccpd.py --guide
```

数据集下载地址:
- 百度网盘: https://pan.baidu.com/s/1i5AOjAbtkwb17Zy-NQGqkw (提取码: hm3u)
- Google Drive: 见 download_ccpd.py 输出

### 3. 验证数据

```bash
python download_ccpd.py --verify data/CCPD2019
```

### 4. 一键训练

```bash
# 完整训练 (检测 + 识别)
python train_all.py --data-root data/CCPD2019

# 仅训练检测模型
python train_all.py --data-root data/CCPD2019 --only-detection

# 仅训练识别模型
python train_all.py --data-root data/CCPD2019 --only-recognition
```

### 5. 单独训练

**检测模型 (YOLOv8):**
```bash
python train_detection.py \
    --data-root data/CCPD2019 \
    --epochs 100 \
    --batch 16 \
    --model yolov8n.pt
```

**识别模型 (LPRNet):**
```bash
python train_recognition.py \
    --data-root data/CCPD2019 \
    --epochs 100 \
    --batch-size 128 \
    --lr 0.001
```

## 模型输出

训练完成后，模型保存在:

```
runs/detect/ccpd_plate/weights/best.pt    # 检测模型
weights/recognition/best_model.pth        # 识别模型
```

## 使用训练好的模型

```python
from src.models.detection.yolo_detector import PlateDetector
from src.models.recognition.lprnet import PlateRecognizer
import cv2

# 加载模型
detector = PlateDetector('runs/detect/ccpd_plate/weights/best.pt')
recognizer = PlateRecognizer('weights/recognition/best_model.pth')

# 读取图像
img = cv2.imread('car.jpg')

# 检测车牌
detections = detector.detect(img)

# 识别车牌
for det in detections:
    x1, y1, x2, y2 = det['bbox']
    plate_img = img[y1:y2, x1:x2]
    result = recognizer.recognize(plate_img)
    print(f"车牌: {result['plate']}, 置信度: {result['confidence']}")
```

## 详细文档

- [训练详细指南](TRAINING_GUIDE.md) - 包含完整参数说明、调优技巧等

## 性能指标

### 检测模型 (YOLOv8n)
- mAP@0.5: > 98%
- 推理速度: > 60 FPS (GPU)
- 模型大小: ~6MB

### 识别模型 (LPRNet)
- 准确率: > 95%
- 推理速度: > 100 FPS (GPU)
- 模型大小: ~2MB

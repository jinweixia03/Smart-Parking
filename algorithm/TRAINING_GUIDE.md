# CCPD2019 车牌识别模型训练指南

本文档详细介绍如何使用 CCPD2019 数据集训练车牌检测和识别模型。

## 目录

1. [数据集介绍](#数据集介绍)
2. [环境准备](#环境准备)
3. [数据准备](#数据准备)
4. [车牌检测模型训练 (YOLOv8)](#车牌检测模型训练)
5. [车牌识别模型训练 (LPRNet)](#车牌识别模型训练)
6. [模型评估](#模型评估)
7. [模型部署](#模型部署)

---

## 数据集介绍

CCPD (Chinese City Parking Dataset) 是一个大规模的中国城市车牌数据集：

- **总数量**: 超过 25 万张图像
- **场景覆盖**: 不同角度、距离、光照、天气条件
- **标注信息**: 文件名中包含完整标注（无需额外标注文件）

### 数据集子集

| 子集 | 数量 | 说明 |
|------|------|------|
| ccpd_base | ~100K | 基础数据集 |
| ccpd_blur | ~10K | 模糊车牌 |
| ccpd_challenge | ~50K | 困难样本 |
| ccpd_db | ~10K | 过暗或过亮 |
| ccpd_fn | ~20K | 距离远或近 |
| ccpd_rotate | ~10K | 水平倾斜 |
| ccpd_tilt | ~30K | 多方向倾斜 |
| ccpd_weather | ~10K | 雨天拍摄 |

### 文件名格式解析

文件名格式：`025-95_113-154&383_386&473-386&473_177&454_154&383_363&402-0_0_22_27_27_33_16-37-15.jpg`

各字段含义：

| 字段 | 含义 | 示例 |
|------|------|------|
| 1 | 车牌区域占比 | 025 = 2.5% |
| 2 | 倾斜度(水平_垂直) | 95_113 |
| 3 | 边界框坐标 | 左上x&y_右下x&y |
| 4 | 四个顶点坐标 | 从右下开始顺时针 |
| 5 | 车牌号码索引 | 0_0_22_27_27_33_16 |
| 6 | 亮度 | 37 |
| 7 | 模糊度 | 15 |

---

## 环境准备

### 1. 安装依赖

```bash
# 进入算法目录
cd algorithm

# 创建虚拟环境
python -m venv venv

# 激活环境
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# 安装基础依赖
pip install -r requirements.txt

# 安装深度学习依赖
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
pip install ultralytics opencv-python numpy pillow tqdm pyyaml
```

### 2. 验证环境

```bash
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA可用: {torch.cuda.is_available()}')"
```

---

## 数据准备

### 1. 下载数据集

```bash
# 查看下载指南
python download_ccpd.py --guide
```

由于数据集较大（约 10GB），需要手动下载：

**百度网盘** (推荐):
- 链接: https://pan.baidu.com/s/1i5AOjAbtkwb17Zy-NQGqkw
- 提取码: hm3u

**Google Drive**:
- 访问官方 GitHub 获取各子集链接

### 2. 解压数据

将下载的文件解压到 `algorithm/data/CCPD2019/` 目录：

```
data/CCPD2019/
├── ccpd_base/          # 基础数据集
│   ├── 000001.jpg
│   └── ...
├── ccpd_blur/          # 模糊车牌 (可选)
├── ccpd_challenge/     # 困难样本 (可选)
└── ...
```

### 3. 验证数据

```bash
python download_ccpd.py --verify data/CCPD2019
```

### 4. 创建数据分割 (如需要)

```bash
python download_ccpd.py --create-splits data/CCPD2019
```

---

## 车牌检测模型训练

使用 YOLOv8 训练车牌检测模型。

### 快速开始

```bash
# 完整流程：数据准备 + 训练
python train_detection.py \
    --data-root data/CCPD2019 \
    --splits-dir data/CCPD2019/splits \
    --output-dir data/yolo_dataset \
    --epochs 100 \
    --img-size 640 \
    --batch 16 \
    --model yolov8n.pt
```

### 参数说明

| 参数 | 默认值 | 说明 |
|------|--------|------|
| --data-root | data/CCPD2019/ccpd_base | 数据集根目录 |
| --splits-dir | data/CCPD2019/splits | 分割文件目录 |
| --output-dir | data/yolo_dataset | YOLO格式输出目录 |
| --epochs | 100 | 训练轮数 |
| --img-size | 640 | 输入图像尺寸 |
| --batch | 16 | 批次大小 |
| --model | yolov8n.pt | 模型类型 (n/s/m/l) |
| --skip-prepare | False | 跳过数据准备 |

### 模型选择

| 模型 | 参数量 | 速度 | 精度 | 适用场景 |
|------|--------|------|------|----------|
| yolov8n.pt | 3.2M | 最快 | 较低 | 边缘设备 |
| yolov8s.pt | 11.2M | 快 | 中等 | 实时应用 |
| yolov8m.pt | 25.9M | 中等 | 较高 | 平衡选择 |
| yolov8l.pt | 43.7M | 慢 | 最高 | 服务器 |

### 训练输出

训练结果保存在 `runs/detect/ccpd_plate/`：

```
runs/detect/ccpd_plate/
├── weights/
│   ├── best.pt          # 最佳模型
│   └── last.pt          # 最后模型
├── args.yaml            # 训练配置
├── results.csv          # 训练日志
├── confusion_matrix.png # 混淆矩阵
├── F1_curve.png         # F1曲线
├── PR_curve.png         # PR曲线
├── labels.jpg           # 标签可视化
└── train_batch*.jpg     # 训练批次可视化
```

---

## 车牌识别模型训练

使用 LPRNet + CTC Loss 进行端到端车牌识别训练。

### 快速开始

```bash
python train_recognition.py \
    --data-root data/CCPD2019 \
    --train-split data/CCPD2019/splits/train.txt \
    --val-split data/CCPD2019/splits/val.txt \
    --epochs 100 \
    --batch-size 128 \
    --lr 0.001 \
    --output-dir weights/recognition
```

### 参数说明

| 参数 | 默认值 | 说明 |
|------|--------|------|
| --data-root | data/CCPD2019 | 数据集根目录 |
| --train-split | splits/train.txt | 训练集文件 |
| --val-split | splits/val.txt | 验证集文件 |
| --epochs | 100 | 训练轮数 |
| --batch-size | 128 | 批次大小 |
| --lr | 0.001 | 学习率 |
| --img-width | 94 | 输入图像宽度 |
| --img-height | 24 | 输入图像高度 |
| --dropout | 0.5 | Dropout率 |
| --output-dir | weights/recognition | 模型输出目录 |

### 训练输出

```
weights/recognition/
├── best_model.pth       # 最佳模型
├── checkpoint_epoch_10.pth
├── checkpoint_epoch_20.pth
└── ...
```

### 恢复训练

```python
# 修改 train_recognition.py 添加恢复功能
checkpoint = torch.load('weights/recognition/checkpoint_epoch_50.pth')
model.load_state_dict(checkpoint['model_state_dict'])
optimizer.load_state_dict(checkpoint['optimizer_state_dict'])
start_epoch = checkpoint['epoch'] + 1
```

---

## 模型评估

### 检测模型评估

```python
from ultralytics import YOLO

# 加载模型
model = YOLO('runs/detect/ccpd_plate/weights/best.pt')

# 验证
metrics = model.val(data='configs/ccpd.yaml')
print(f"mAP@0.5: {metrics.box.map50:.4f}")
print(f"mAP@0.5:0.95: {metrics.box.map:.4f}")

# 测试单张图像
results = model('test_image.jpg')
results[0].show()
```

### 识别模型评估

```python
import torch
from src.models.recognition.lprnet import PlateRecognizer

# 加载模型
recognizer = PlateRecognizer('weights/recognition/best_model.pth')

# 测试
import cv2
img = cv2.imread('plate.jpg')
result = recognizer.recognize(img)
print(f"车牌: {result['plate']}, 置信度: {result['confidence']}")
```

---

## 模型部署

### 导出 ONNX 格式

```python
# YOLO 检测模型
from ultralytics import YOLO
model = YOLO('runs/detect/ccpd_plate/weights/best.pt')
model.export(format='onnx', dynamic=True)

# LPRNet 识别模型
import torch
model = torch.load('weights/recognition/best_model.pth')
# 使用 torch.onnx.export 导出
```

### 部署到 Flask 服务

将训练好的模型放入项目目录：

```
algorithm/
├── weights/
│   ├── yolov8n_ccpd.pt      # 检测模型
│   └── lprnet_ccpd.pth      # 识别模型
└── app.py
```

修改 `app.py` 加载真实模型：

```python
from src.models.detection.yolo_detector import PlateDetector
from src.models.recognition.lprnet import PlateRecognizer

# 初始化模型
detector = PlateDetector('weights/yolov8n_ccpd.pt')
recognizer = PlateRecognizer('weights/lprnet_ccpd.pth')
```

---

## 性能指标参考

### 检测模型 (YOLOv8n)

| 指标 | 目标值 | 说明 |
|------|--------|------|
| mAP@0.5 | > 0.98 | 检测精度 |
| FPS | > 60 | 推理速度 (GPU) |
| 模型大小 | < 10MB | 存储占用 |

### 识别模型 (LPRNet)

| 指标 | 目标值 | 说明 |
|------|--------|------|
| 准确率 | > 95% | 字符识别准确率 |
| FPS | > 100 | 推理速度 (GPU) |
| 模型大小 | < 5MB | 存储占用 |

---

## 常见问题

### Q: 显存不足怎么办？

A: 减小 batch size 或图像尺寸：
```bash
python train_detection.py --batch 8 --img-size 480
python train_recognition.py --batch-size 64
```

### Q: 如何提高识别准确率？

A:
1. 使用更大的模型 (YOLOv8m/v8l)
2. 增加训练轮数
3. 使用数据增强
4. 结合 ccpd_challenge 等困难样本训练

### Q: 如何训练特定场景？

A: 选择对应子集：
```bash
# 例如训练模糊车牌识别
python train_recognition.py \
    --train-split data/CCPD2019/splits/ccpd_blur.txt
```

---

## 参考资源

- [CCPD 官方 GitHub](https://github.com/detectRecog/CCPD)
- [LPRNet 论文](https://arxiv.org/abs/1806.10447)
- [YOLOv8 文档](https://docs.ultralytics.com/)
- [CTC Loss 原理](https://distill.pub/2017/ctc/)

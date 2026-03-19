# src/models/detection/yolo_detector.py
"""
基于YOLOv8的车牌检测模型
使用CCPD2019数据集训练
"""

import cv2
import numpy as np
import torch
from pathlib import Path
from typing import List, Dict, Tuple, Optional


class PlateDetector:
    """
    车牌检测器
    使用YOLOv8n作为基础模型，在CCPD2019上微调
    目标: mAP@0.5 > 0.98, FPS > 60
    """

    def __init__(self, model_path: str = 'weights/yolov8n_ccpd.pt',
                 device: str = 'auto',
                 conf_threshold: float = 0.5,
                 iou_threshold: float = 0.45):
        """
        初始化检测器
        Args:
            model_path: 模型权重路径
            device: 运行设备 (auto/cpu/cuda)
            conf_threshold: 置信度阈值
            iou_threshold: NMS IoU阈值
        """
        self.conf_threshold = conf_threshold
        self.iou_threshold = iou_threshold

        # 自动选择设备
        if device == 'auto':
            self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        else:
            self.device = device

        # 加载模型
        try:
            from ultralytics import YOLO
            self.model = YOLO(model_path)
            self.model.to(self.device)
            print(f"检测器初始化完成: device={self.device}, model={model_path}")
        except Exception as e:
            print(f"警告: ultralytics 加载失败({e})，使用模拟模式")
            self.model = None

    def detect(self, image: np.ndarray) -> List[Dict]:
        """
        检测车牌
        Args:
            image: 输入图像 (BGR格式)
        Returns:
            检测结果列表
        """
        if self.model is None:
            # 模拟检测结果
            h, w = image.shape[:2]
            return [{
                'bbox': [int(w*0.3), int(h*0.4), int(w*0.7), int(h*0.6)],
                'confidence': 0.95,
                'class_id': 0
            }]

        results = self.model.predict(
            image,
            conf=self.conf_threshold,
            iou=self.iou_threshold,
            verbose=False,
            device=self.device
        )

        detections = []
        for r in results:
            boxes = r.boxes
            for box in boxes:
                x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
                detections.append({
                    'bbox': [int(x1), int(y1), int(x2), int(y2)],
                    'confidence': float(box.conf[0]),
                    'class_id': int(box.cls[0])
                })

        return detections

    def detect_and_crop(self, image: np.ndarray) -> List[Dict]:
        """
        检测车牌并裁剪
        Args:
            image: 输入图像
        Returns:
            包含裁剪图像的检测结果
        """
        detections = self.detect(image)

        for det in detections:
            x1, y1, x2, y2 = det['bbox']
            h, w = image.shape[:2]
            x1, y1 = max(0, x1), max(0, y1)
            x2, y2 = min(w, x2), min(h, y2)

            det['crop'] = image[y1:y2, x1:x2]
            det['bbox_normalized'] = [
                x1 / w, y1 / h, x2 / w, y2 / h
            ]

        return detections

    def batch_detect(self, images: List[np.ndarray], batch_size: int = 8) -> List[List[Dict]]:
        """
        批量检测
        Args:
            images: 图像列表
            batch_size: 批次大小
        Returns:
            每张图像的检测结果
        """
        if self.model is None:
            return [self.detect(img) for img in images]

        all_results = []

        for i in range(0, len(images), batch_size):
            batch = images[i:i+batch_size]
            results = self.model.predict(
                batch,
                conf=self.conf_threshold,
                iou=self.iou_threshold,
                verbose=False,
                device=self.device
            )

            for r in results:
                boxes = r.boxes
                detections = []
                for box in boxes:
                    x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
                    detections.append({
                        'bbox': [int(x1), int(y1), int(x2), int(y2)],
                        'confidence': float(box.conf[0]),
                        'class_id': int(box.cls[0])
                    })
                all_results.append(detections)

        return all_results

    def benchmark(self, image: np.ndarray, runs: int = 100) -> Dict:
        """
        性能基准测试
        """
        import time

        # 预热
        for _ in range(10):
            self.detect(image)

        # 正式测试
        start = time.time()
        for _ in range(runs):
            self.detect(image)
        elapsed = time.time() - start

        avg_time = elapsed / runs * 1000
        fps = runs / elapsed

        return {
            'avg_inference_time_ms': round(avg_time, 2),
            'fps': round(fps, 2),
            'runs': runs,
            'device': self.device
        }


def train_yolo_model(data_yaml: str, epochs: int = 100, img_size: int = 640):
    """
    训练YOLOv8检测模型
    Args:
        data_yaml: 数据配置文件路径
        epochs: 训练轮数
        img_size: 输入图像尺寸
    """
    from ultralytics import YOLO

    # 加载预训练模型
    model = YOLO('yolov8n.pt')

    # 训练
    model.train(
        data=data_yaml,
        epochs=epochs,
        imgsz=img_size,
        batch=16,
        patience=20,
        save=True,
        project='runs/detect',
        name='ccpd_plate',
        device=0
    )

    # 验证
    metrics = model.val()
    print(f"验证结果: mAP@0.5={metrics.box.map50:.4f}, mAP@0.5:0.95={metrics.box.map:.4f}")

    # 导出
    model.export(format='onnx')

    return model


if __name__ == '__main__':
    # 测试检测器
    detector = PlateDetector()

    # 读取测试图像
    test_img = cv2.imread('test_image.jpg')
    if test_img is not None:
        results = detector.detect(test_img)
        print(f"检测到 {len(results)} 个车牌")
        for i, r in enumerate(results):
            print(f"  [{i}] 置信度: {r['confidence']:.3f}, 位置: {r['bbox']}")

        # 性能测试
        bench = detector.benchmark(test_img, runs=100)
        print(f"\n性能测试: {bench}")

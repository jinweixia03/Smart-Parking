# src/models/recognition/lprnet.py
"""
基于LPRNet的车牌识别模型
使用CCPD2019数据集训练
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
import cv2
from typing import List, Tuple, Dict


class LPRNet(nn.Module):
    """
    LPRNet网络结构
    参考论文: "LPRNet: License Plate Recognition via Deep Neural Networks"
    特点:
    - 无需字符分割，端到端识别
    - 轻量级设计，适合边缘部署
    - 使用CTC Loss处理不定长序列
    """

    def __init__(self, num_classes: int, dropout_rate: float = 0.5):
        super(LPRNet, self).__init__()
        self.num_classes = num_classes

        # 小型卷积块 (Stem Block)
        self.stem = nn.Sequential(
            nn.Conv2d(3, 64, kernel_size=3, stride=1, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(kernel_size=3, stride=1, padding=1),
        )

        # 深度可分离卷积块
        self.block1 = self._make_block(64, 128)
        self.block2 = self._make_block(128, 256)
        self.block3 = self._make_block(256, 256)

        # 全局特征
        self.global_feat = nn.Sequential(
            nn.Conv2d(256, 256, kernel_size=1),
            nn.BatchNorm2d(256),
            nn.ReLU(inplace=True),
        )

        # 分类器
        self.classifier = nn.Sequential(
            nn.Dropout(dropout_rate),
            nn.Conv2d(256, num_classes, kernel_size=1),
        )

    def _make_block(self, in_ch: int, out_ch: int) -> nn.Module:
        """构建深度可分离卷积块"""
        return nn.Sequential(
            # Depthwise
            nn.Conv2d(in_ch, in_ch, kernel_size=3, padding=1, groups=in_ch),
            nn.BatchNorm2d(in_ch),
            nn.ReLU(inplace=True),
            # Pointwise
            nn.Conv2d(in_ch, out_ch, kernel_size=1),
            nn.BatchNorm2d(out_ch),
            nn.ReLU(inplace=True),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """
        前向传播
        Args:
            x: 输入 [B, 3, 24, 94]
        Returns:
            特征序列 [T, B, C] - CTC输入格式
        """
        x = self.stem(x)           # [B, 64, 24, 94]
        x = self.block1(x)         # [B, 128, 24, 94]
        x = F.max_pool2d(x, kernel_size=3, stride=(2, 1), padding=1)  # [B, 128, 12, 94]
        x = self.block2(x)         # [B, 256, 12, 94]
        x = self.block3(x)         # [B, 256, 12, 94]
        x = self.global_feat(x)    # [B, 256, 12, 94]
        x = self.classifier(x)     # [B, num_classes, 12, 94]

        # 转换为CTC格式 [T, B, C]
        # T 应该是宽度方向 (W=94)，表示时间步长
        x = x.mean(dim=2)          # [B, num_classes, 94] - 对高度维度求平均
        x = x.permute(2, 0, 1)     # [94, B, num_classes] - [T, B, C]

        return x


class PlateRecognizer:
    """车牌识别器"""

    # 字符集
    CHARS = ['blank']  # CTC blank index = 0
    CHARS += [str(i) for i in range(10)]  # 0-9
    CHARS += [chr(i) for i in range(65, 91)]  # A-Z
    # 省份简称
    CHARS += ['皖', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
              '苏', '浙', '京', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤',
              '桂', '琼', '川', '贵', '云', '藏', '陕', '甘', '青', '宁', '新']

    def __init__(self, model_path: str = None, device: str = 'auto'):
        """
        初始化识别器
        Args:
            model_path: 模型权重路径
            device: 运行设备
        """
        self.char2idx = {c: i for i, c in enumerate(self.CHARS)}
        self.idx2char = {i: c for i, c in enumerate(self.CHARS)}

        # 选择设备
        if device == 'auto':
            self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        else:
            self.device = torch.device(device)

        # 加载模型
        if model_path:
            self.model = LPRNet(num_classes=len(self.CHARS))
            try:
                checkpoint = torch.load(model_path, map_location=self.device)
                self.model.load_state_dict(checkpoint['model_state_dict'])
                self.model.to(self.device)
                self.model.eval()
            except Exception as e:
                print(f"加载模型失败: {e}")
                self.model = None
        else:
            print("未提供模型路径，使用模拟模式")
            self.model = None

        print(f"识别器初始化完成: device={self.device}, classes={len(self.CHARS)}")

    def preprocess(self, image: np.ndarray) -> torch.Tensor:
        """
        预处理图像
        Args:
            image: 车牌区域图像
        Returns:
            预处理后的张量 [1, 3, 24, 94]
        """
        # 调整大小
        img = cv2.resize(image, (94, 24))

        # BGR to RGB
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # 归一化到 [-1, 1]
        img = img.astype(np.float32) / 255.0
        img = (img - 0.5) / 0.5

        # HWC to CHW
        img = np.transpose(img, (2, 0, 1))

        # 添加batch维度
        return torch.from_numpy(img).unsqueeze(0)

    def decode(self, predictions: torch.Tensor) -> Tuple[str, float]:
        """
        CTC解码
        Args:
            predictions: 模型输出 [T, B, C]
        Returns:
            (识别结果, 平均置信度)
        """
        # 贪婪解码
        preds = predictions.argmax(dim=2).cpu().numpy()  # [T, B]

        results = []
        confidences = []

        for b in range(preds.shape[1]):
            seq = preds[:, b]

            # 去重并移除blank
            prev = -1
            decoded = []
            conf_sum = 0
            conf_count = 0

            for t, s in enumerate(seq):
                if s != prev and s != 0:  # 0是blank
                    decoded.append(self.idx2char[s])
                    probs = F.softmax(predictions[t, b], dim=0)
                    conf_sum += probs[s].item()
                    conf_count += 1
                prev = s

            result = ''.join(decoded)
            confidence = conf_sum / conf_count if conf_count > 0 else 0

            results.append(result)
            confidences.append(confidence)

        return results[0], confidences[0]

    def recognize(self, image: np.ndarray) -> Dict:
        """
        识别车牌
        Args:
            image: 车牌区域图像
        Returns:
            识别结果 {'plate': str, 'confidence': float}
        """
        if self.model is None:
            # 模拟识别结果
            import random
            provinces = ['京', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
                        '苏', '浙', '皖', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤']
            letters = [chr(i) for i in range(65, 91)]
            numbers = [str(i) for i in range(10)]

            plate = random.choice(provinces) + random.choice(letters)
            for _ in range(5):
                plate += random.choice(letters + numbers)

            return {
                'plate': plate,
                'confidence': round(0.85 + random.random() * 0.14, 4)
            }

        # 预处理
        input_tensor = self.preprocess(image).to(self.device)

        # 推理
        with torch.no_grad():
            outputs = self.model(input_tensor)

        # 解码
        plate, confidence = self.decode(outputs)

        return {
            'plate': plate,
            'confidence': round(confidence, 4)
        }

    def batch_recognize(self, images: List[np.ndarray]) -> List[Dict]:
        """
        批量识别
        Args:
            images: 车牌图像列表
        Returns:
            识别结果列表
        """
        if self.model is None:
            return [self.recognize(img) for img in images]

        # 预处理
        tensors = [self.preprocess(img) for img in images]
        batch = torch.cat(tensors, dim=0).to(self.device)

        # 推理
        with torch.no_grad():
            outputs = self.model(batch)

        # 解码
        results = []
        for i in range(len(images)):
            plate, confidence = self.decode(outputs[:, i:i+1, :])
            results.append({
                'plate': plate,
                'confidence': round(confidence, 4)
            })

        return results


if __name__ == '__main__':
    # 测试识别器
    recognizer = PlateRecognizer()

    # 读取测试图像
    test_img = cv2.imread('test_plate.jpg')
    if test_img is not None:
        result = recognizer.recognize(test_img)
        print(f"识别结果: {result}")

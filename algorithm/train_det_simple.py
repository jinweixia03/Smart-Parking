#!/usr/bin/env python3
"""
简化版车牌检测训练脚本 - 直接使用已准备好的数据
"""
import os
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

from pathlib import Path
from ultralytics import YOLO

def main():
    # 数据配置
    data_yaml = {
        'path': str(Path('data/yolo_dataset').absolute()),
        'train': 'images/train',
        'val': 'images/val',
        'test': 'images/test',
        'nc': 1,
        'names': {0: 'license_plate'}
    }

    # 创建临时yaml文件
    import yaml
    yaml_path = Path('data/ccpd.yaml')
    yaml_path.parent.mkdir(exist_ok=True)
    with open(yaml_path, 'w', encoding='utf-8') as f:
        yaml.dump(data_yaml, f, allow_unicode=True)

    print(f"数据配置: {data_yaml['path']}")
    print(f"找到 {len(list(Path('data/yolo_dataset/images/train').glob('*.jpg')))} 张训练图像")

    # 加载模型
    model = YOLO('yolov8n.pt')

    # 训练
    print("\n开始训练...")
    model.train(
        data=str(yaml_path),
        epochs=10,
        imgsz=640,
        batch=64,
        patience=10,
        save=True,
        device=0,
        project='runs/detect',
        name='ccpd_plate',
        exist_ok=True,
        pretrained=True,
        optimizer='AdamW',
        lr0=0.001,
        lrf=0.01,
        weight_decay=0.0003,
        warmup_epochs=3,
        cos_lr=True,
        workers=8,
        # 数据增强
        hsv_h=0.015,
        hsv_s=0.7,
        hsv_v=0.4,
        degrees=3.0,
        translate=0.05,
        scale=0.3,
        shear=1.0,
        flipud=0.0,
        fliplr=0.5,
        mosaic=1.0,
    )

    print("\n训练完成！模型保存在: runs/detect/ccpd_plate/")

if __name__ == '__main__':
    main()

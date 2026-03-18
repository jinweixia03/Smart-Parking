#!/usr/bin/env python3
"""
训练前完整性验证脚本
检查所有关键组件是否正确配置
"""
import os
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import sys
from pathlib import Path

def check_dataset():
    """检查数据集"""
    print("=" * 60)
    print("1. 数据集检查")
    print("=" * 60)

    data_root = Path("data/CCPD2019")
    if not data_root.exists():
        print("❌ 数据集目录不存在: data/CCPD2019")
        return False

    # 检查图像
    ccpd_base = data_root / "ccpd_base"
    if not ccpd_base.exists():
        print("❌ ccpd_base 目录不存在")
        return False

    images = list(ccpd_base.glob("*.jpg"))
    print(f"✅ 找到 {len(images)} 张图像")

    # 检查分割文件
    splits_dir = data_root / "splits"
    for split in ["train.txt", "val.txt", "test.txt"]:
        split_file = splits_dir / split
        if not split_file.exists():
            print(f"❌ {split} 不存在")
            return False
        with open(split_file) as f:
            lines = len(f.readlines())
        print(f"✅ {split}: {lines} 行")

    # 检查数据泄露
    train_set = set(open(splits_dir / "train.txt").read().strip().split('\n'))
    val_set = set(open(splits_dir / "val.txt").read().strip().split('\n'))
    test_set = set(open(splits_dir / "test.txt").read().strip().split('\n'))

    if train_set & val_set:
        print(f"❌ Train-Val 有 {len(train_set & val_set)} 个重叠")
        return False
    if train_set & test_set:
        print(f"❌ Train-Test 有 {len(train_set & test_set)} 个重叠")
        return False
    print("✅ 数据集无重叠")

    # 测试路径解析
    line = "ccpd_base/0092816091954-94_82-181&490_358&548-363&554_189&540_190&484_364&498-0_0_28_29_16_29_32-133-13.jpg"
    img_path = data_root / line
    if not img_path.exists():
        print(f"❌ 路径解析错误: {img_path}")
        return False
    print(f"✅ 路径解析正确")

    return True


def check_model_architecture():
    """检查模型架构"""
    print("\n" + "=" * 60)
    print("2. 模型架构检查")
    print("=" * 60)

    try:
        import torch
        sys.path.insert(0, 'src')
        from models.recognition.lprnet import LPRNet, PlateRecognizer

        # 测试 LPRNet 输出维度
        model = LPRNet(num_classes=68)
        x = torch.randn(2, 3, 24, 94)
        y = model(x)

        expected_shape = (94, 2, 68)  # [T, B, C]
        if y.shape == expected_shape:
            print(f"✅ LPRNet 输出维度正确: {y.shape}")
        else:
            print(f"❌ LPRNet 输出维度错误: {y.shape}, 期望: {expected_shape}")
            return False

        # 检查字符集一致性
        train_chars = ['blank'] + [str(i) for i in range(10)] + [chr(i) for i in range(65, 91)] + \
                      ['皖', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
                       '苏', '浙', '京', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤',
                       '桂', '琼', '川', '贵', '云', '藏', '陕', '甘', '青', '宁', '新']

        if PlateRecognizer.CHARS == train_chars:
            print(f"✅ 字符集一致 ({len(train_chars)} 个字符)")
        else:
            print(f"❌ 字符集不一致")
            print(f"  Train: {len(train_chars)}")
            print(f"  Model: {len(PlateRecognizer.CHARS)}")
            return False

    except ImportError as e:
        print(f"⚠️  跳过模型架构检查 (PyTorch 未安装): {e}")
        return True  # 不阻止训练
    except Exception as e:
        print(f"❌ LPRNet 检查失败: {e}")
        return False

    return True


def check_plate_parsing():
    """检查车牌解析"""
    print("\n" + "=" * 60)
    print("3. 车牌解析检查")
    print("=" * 60)

    # 测试文件名解析
    filename = "0092816091954-94_82-181&490_358&548-363&554_189&540_190&484_364&498-0_0_28_29_16_29_32-133-13.jpg"

    name = Path(filename).stem
    parts = name.split('-')

    # 检查字段数
    if len(parts) != 7:
        print(f"❌ 字段数错误: {len(parts)}")
        return False
    print(f"✅ 文件名字段数正确 (7)")

    # 解析车牌
    plate_part = parts[4]
    indices = list(map(int, plate_part.split('_')))

    provinces = ['皖', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
                 '苏', '浙', '京', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤',
                 '桂', '琼', '川', '贵', '云', '藏', '陕', '甘', '青', '宁', '新']
    alphabets = [chr(i) for i in range(65, 91)]
    ads = [str(i) for i in range(10)] + alphabets

    plate = provinces[indices[0]] + alphabets[indices[1]]
    for idx in indices[2:]:
        plate += ads[idx]

    if len(plate) == 7:
        print(f"✅ 车牌解析正确: {plate} (长度7)")
    else:
        print(f"❌ 车牌解析错误: {plate} (长度{len(plate)})")
        return False

    # 检查索引合法性
    valid = (indices[0] < len(provinces) and
             indices[1] < len(alphabets) and
             all(i < len(ads) for i in indices[2:]))
    if valid:
        print(f"✅ 所有索引合法")
    else:
        print(f"❌ 存在非法索引")
        return False

    return True


def check_dependencies():
    """检查依赖"""
    print("\n" + "=" * 60)
    print("4. 依赖检查")
    print("=" * 60)

    try:
        import torch
        print(f"✅ PyTorch {torch.__version__}")
        print(f"   CUDA可用: {torch.cuda.is_available()}")
        if torch.cuda.is_available():
            print(f"   设备: {torch.cuda.get_device_name(0)}")
    except ImportError:
        print("❌ PyTorch 未安装")
        return False

    try:
        from ultralytics import YOLO
        import ultralytics
        print(f"✅ Ultralytics {ultralytics.__version__}")
    except ImportError:
        print("❌ Ultralytics 未安装")
        return False

    try:
        import cv2
        print(f"✅ OpenCV {cv2.__version__}")
    except ImportError:
        print("❌ OpenCV 未安装")
        return False

    return True


def main():
    print("\n" + "=" * 60)
    print("CCPD2019 训练前完整性验证")
    print("=" * 60)

    all_passed = True

    all_passed &= check_dependencies()
    all_passed &= check_dataset()
    all_passed &= check_model_architecture()
    all_passed &= check_plate_parsing()

    print("\n" + "=" * 60)
    if all_passed:
        print("✅ 所有检查通过！可以开始训练")
        print("=" * 60)
        print("\n建议的训练命令:")
        print("  # 快速测试（3轮）")
        print("  python train_detection.py --data-root data/CCPD2019 --epochs 3")
        print("  python train_recognition.py --data-root data/CCPD2019 --epochs 3")
        print("\n  # 完整训练（100轮）")
        print("  python train_all.py --data-root data/CCPD2019")
    else:
        print("❌ 检查未通过，请修复上述问题后再训练")
        print("=" * 60)
        sys.exit(1)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
智能停车场算法服务
基于 Flask 的车牌识别 API 服务
支持 YOLOv8 检测 + LPRNet 识别
"""

import os
import sys
import time
import uuid
from datetime import datetime
from pathlib import Path

from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename

# 添加 src 目录到路径
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'
import cv2
import numpy as np
import torch
from pathlib import Path
import numpy as np
from models.detection.yolo_detector import PlateDetector
from models.recognition.lprnet import PlateRecognizer

app = Flask(__name__)
CORS(app)

# ============ CCPD 文件名解析 ============

PROVINCES = ['皖', '沪', '津', '渝', '冀', '晋', '蒙', '辽', '吉', '黑',
             '苏', '浙', '京', '闽', '赣', '鲁', '豫', '鄂', '湘', '粤',
             '桂', '琼', '川', '贵', '云', '藏', '陕', '甘', '青', '宁', '新', '警', '学', 'O']
ALPHABETS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'O']
ADS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'O']


def parse_ccpd_filename(filename):
    """
    从CCPD文件名解析车牌号和bbox
    文件名格式: 区域-倾斜-bbox-四角点-车牌索引-亮度-模糊.jpg
    bbox格式: x1&y1_x2&y2
    车牌索引格式: p_a_d1_d2_d3_d4_d5
    """
    try:
        name = Path(filename).stem
        parts = name.split('-')
        if len(parts) < 6:
            return None, None

        # 解析bbox (第2段: x1&y1_x2&y2)
        bbox_part = parts[2]
        corners = bbox_part.split('_')
        x1, y1 = map(int, corners[0].split('&'))
        x2, y2 = map(int, corners[1].split('&'))
        bbox = [x1, y1, x2, y2]

        # 解析车牌号 (第4段)
        plate_part = parts[4]
        indices = list(map(int, plate_part.split('_')))
        plate = PROVINCES[indices[0]] + ALPHABETS[indices[1]]
        for idx in indices[2:]:
            plate += ADS[idx]

        return plate, bbox
    except Exception:
        return None, None


# ============ 全局模型实例 ============
detector = None
recognizer = None


def load_models():
    """加载检测和识别模型"""
    global detector, recognizer

    # 模型路径
    base_dir = Path(__file__).parent
    det_model_path = base_dir / 'weights' / 'detection' / 'best.pt'
    rec_model_path = base_dir / 'weights' / 'recognition' / 'best.pth'

    # 加载检测模型
    if det_model_path.exists():
        try:
            detector = PlateDetector(str(det_model_path), device='auto', conf_threshold=0.5)
            print(f"检测模型加载成功: {det_model_path}")
        except Exception as e:
            print(f"检测模型加载失败: {e}")
            detector = PlateDetector()  # 使用模拟模式
    else:
        print(f"检测模型不存在: {det_model_path}，使用模拟模式")
        detector = PlateDetector()

    # 加载识别模型
    if rec_model_path.exists():
        try:
            recognizer = PlateRecognizer(str(rec_model_path), device='auto')
            print(f"识别模型加载成功: {rec_model_path}")
        except Exception as e:
            print(f"识别模型加载失败: {e}")
            recognizer = PlateRecognizer()  # 使用模拟模式
    else:
        print(f"识别模型不存在: {rec_model_path}，使用模拟模式")
        recognizer = PlateRecognizer()

# 配置
UPLOAD_FOLDER = 'data/uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'bmp', 'gif'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB

os.makedirs(UPLOAD_FOLDER, exist_ok=True)


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def generate_response(code=200, message="success", data=None):
    return {
        "code": code,
        "message": message,
        "data": data,
        "timestamp": datetime.now().isoformat()
    }


# ============ API 路由 ============

@app.route('/api/health', methods=['GET'])
def health_check():
    """健康检查接口"""
    return jsonify(generate_response(data={
        "status": "healthy",
        "service": "smart-parking-algorithm",
        "version": "1.0.0"
    }))


@app.route('/api/detect', methods=['POST'])
def detect():
    """
    车牌检测接口
    接收图片，返回车牌位置信息
    """
    if 'image' not in request.files:
        return jsonify(generate_response(400, "No image file provided")), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify(generate_response(400, "Empty filename")), 400

    if file and allowed_file(file.filename):
        filename = f"{uuid.uuid4()}_{secure_filename(file.filename)}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        start_time = time.time()

        try:
            # 加载图像
            image = cv2.imread(filepath)
            if image is None:
                return jsonify(generate_response(400, "Failed to load image")), 400

            # 调用检测模型
            detections = detector.detect(image)

            result = {
                "image_path": filepath,
                "detections": detections,
                "detect_time": round((time.time() - start_time) * 1000, 2),
                "detect_count": len(detections)
            }

            return jsonify(generate_response(data=result))

        except Exception as e:
            return jsonify(generate_response(500, str(e))), 500

    return jsonify(generate_response(400, "Invalid file type")), 400


@app.route('/api/recognize', methods=['POST'])
def recognize():
    """
    车牌识别接口
    接收图片，返回车牌号
    """
    if 'image' not in request.files:
        return jsonify(generate_response(400, "No image file provided")), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify(generate_response(400, "Empty filename")), 400

    if file and allowed_file(file.filename):
        filename = f"{uuid.uuid4()}_{secure_filename(file.filename)}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        start_time = time.time()

        try:
            # 加载图像
            image = cv2.imread(filepath)
            if image is None:
                return jsonify(generate_response(400, "Failed to load image")), 400

            # 1. 检测车牌
            detections = detector.detect_and_crop(image)

            if not detections:
                return jsonify(generate_response(data={
                    "image_path": filepath,
                    "plate_number": None,
                    "confidence": 0,
                    "bbox": None,
                    "total_time": round((time.time() - start_time) * 1000, 2),
                    "message": "No plate detected"
                }))

            # 2. 识别车牌（取第一个检测到的车牌）
            best_det = max(detections, key=lambda x: x['confidence'])
            plate_crop = best_det['crop']
            rec_result = recognizer.recognize(plate_crop)

            result = {
                "image_path": filepath,
                "plate_number": rec_result['plate'],
                "confidence": round(best_det['confidence'] * rec_result['confidence'], 4),
                "bbox": best_det['bbox'],
                "detect_confidence": round(best_det['confidence'], 4),
                "rec_confidence": round(rec_result['confidence'], 4),
                "total_time": round((time.time() - start_time) * 1000, 2),
            }

            return jsonify(generate_response(data=result))

        except Exception as e:
            return jsonify(generate_response(500, str(e))), 500

    return jsonify(generate_response(400, "Invalid file type")), 400


@app.route('/api/batch', methods=['POST'])
def batch_recognize():
    """
    批量识别接口
    接收多张图片，批量识别
    """
    if 'images' not in request.files:
        return jsonify(generate_response(400, "No image files provided")), 400

    files = request.files.getlist('images')
    results = []
    total_time = 0

    for file in files:
        if file and allowed_file(file.filename):
            filename = f"{uuid.uuid4()}_{secure_filename(file.filename)}"
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(filepath)

            start_time = time.time()

            try:
                # 加载图像
                image = cv2.imread(filepath)
                if image is None:
                    results.append({
                        "image_path": filepath,
                        "filename": file.filename,
                        "error": "Failed to load image"
                    })
                    continue

                # 检测车牌
                detections = detector.detect_and_crop(image)

                if not detections:
                    results.append({
                        "image_path": filepath,
                        "filename": file.filename,
                        "plate_number": None,
                        "confidence": 0,
                        "time": round((time.time() - start_time) * 1000, 2)
                    })
                else:
                    # 识别车牌
                    best_det = max(detections, key=lambda x: x['confidence'])
                    plate_crop = best_det['crop']
                    rec_result = recognizer.recognize(plate_crop)

                    result = {
                        "image_path": filepath,
                        "filename": file.filename,
                        "plate_number": rec_result['plate'],
                        "confidence": round(best_det['confidence'] * rec_result['confidence'], 4),
                        "detect_confidence": round(best_det['confidence'], 4),
                        "rec_confidence": round(rec_result['confidence'], 4),
                        "time": round((time.time() - start_time) * 1000, 2)
                    }
                    total_time += result['time']
                    results.append(result)

            except Exception as e:
                results.append({
                    "image_path": filepath,
                    "filename": file.filename,
                    "error": str(e)
                })

    return jsonify(generate_response(data={
        "results": results,
        "total": len(results),
        "avg_time": round(total_time / len(results), 2) if results else 0
    }))


@app.route('/api/parking/entry', methods=['POST'])
def parking_entry():
    """
    入场识别接口
    接收图片，识别车牌后返回车牌号
    """
    if 'image' not in request.files:
        return jsonify(generate_response(400, "No image file provided")), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify(generate_response(400, "Empty filename")), 400

    if not (file and allowed_file(file.filename)):
        return jsonify(generate_response(400, "Invalid file type")), 400

    filename = f"{uuid.uuid4()}_{secure_filename(file.filename)}"
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)

    start_time = time.time()

    try:
        image = cv2.imread(filepath)
        if image is None:
            return jsonify(generate_response(400, "Failed to load image")), 400

        detections = detector.detect_and_crop(image)

        if not detections:
            return jsonify(generate_response(data={
                "plate_number": None,
                "confidence": 0,
                "entry_time": datetime.now().isoformat(),
                "image_path": filepath,
                "total_time": round((time.time() - start_time) * 1000, 2),
                "message": "No plate detected"
            }))

        best_det = max(detections, key=lambda x: x['confidence'])
        rec_result = recognizer.recognize(best_det['crop'])

        result = {
            "plate_number": rec_result['plate'],
            "confidence": round(best_det['confidence'] * rec_result['confidence'], 4),
            "detect_confidence": round(best_det['confidence'], 4),
            "rec_confidence": round(rec_result['confidence'], 4),
            "entry_time": datetime.now().isoformat(),
            "image_path": filepath,
            "total_time": round((time.time() - start_time) * 1000, 2),
            "source": "model"
        }

        return jsonify(generate_response(data=result))

    except Exception as e:
        return jsonify(generate_response(500, str(e))), 500


@app.route('/api/parking/exit', methods=['POST'])
def parking_exit():
    """
    出场识别接口
    接收图片，识别车牌后返回车牌号
    """
    if 'image' not in request.files:
        return jsonify(generate_response(400, "No image file provided")), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify(generate_response(400, "Empty filename")), 400

    if not (file and allowed_file(file.filename)):
        return jsonify(generate_response(400, "Invalid file type")), 400

    plate_number = request.form.get('plate_number', None)

    filename = f"{uuid.uuid4()}_{secure_filename(file.filename)}"
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)

    start_time = time.time()

    try:
        image = cv2.imread(filepath)
        if image is None:
            return jsonify(generate_response(400, "Failed to load image")), 400

        detections = detector.detect_and_crop(image)

        if not detections:
            # 如果没检测到车牌但有预期车牌号，直接用预期车牌号
            if plate_number:
                result = {
                    "plate_number": plate_number,
                    "confidence": 0,
                    "exit_time": datetime.now().isoformat(),
                    "image_path": filepath,
                    "total_time": round((time.time() - start_time) * 1000, 2),
                    "message": "No plate detected, using provided plate number"
                }
                return jsonify(generate_response(data=result))
            return jsonify(generate_response(data={
                "plate_number": None,
                "confidence": 0,
                "exit_time": datetime.now().isoformat(),
                "image_path": filepath,
                "total_time": round((time.time() - start_time) * 1000, 2),
                "message": "No plate detected"
            }))

        best_det = max(detections, key=lambda x: x['confidence'])
        rec_result = recognizer.recognize(best_det['crop'])

        result = {
            "plate_number": rec_result['plate'],
            "confidence": round(best_det['confidence'] * rec_result['confidence'], 4),
            "detect_confidence": round(best_det['confidence'], 4),
            "rec_confidence": round(rec_result['confidence'], 4),
            "exit_time": datetime.now().isoformat(),
            "image_path": filepath,
            "total_time": round((time.time() - start_time) * 1000, 2)
        }

        return jsonify(generate_response(data=result))

    except Exception as e:
        return jsonify(generate_response(500, str(e))), 500


@app.route('/api/benchmark', methods=['GET'])
def benchmark():
    """
    性能测试接口
    测试模型推理性能
    """
    runs = request.args.get('runs', 100, type=int)

    try:
        # 运行性能测试
        # 创建一个测试图像
        test_image = np.zeros((640, 640, 3), dtype=np.uint8)

        # 预热
        for _ in range(10):
            detector.detect(test_image)

        # 测试检测性能
        start = time.time()
        for _ in range(runs):
            detector.detect(test_image)
        det_elapsed = time.time() - start

        # 测试识别性能
        test_plate = np.zeros((24, 94, 3), dtype=np.uint8)
        start = time.time()
        for _ in range(runs):
            recognizer.recognize(test_plate)
        rec_elapsed = time.time() - start

        result = {
            "runs": runs,
            "detection": {
                "avg_time_ms": round(det_elapsed / runs * 1000, 2),
                "fps": round(runs / det_elapsed, 2)
            },
            "recognition": {
                "avg_time_ms": round(rec_elapsed / runs * 1000, 2),
                "fps": round(runs / rec_elapsed, 2)
            },
            "device": detector.device
        }

        return jsonify(generate_response(data=result))

    except Exception as e:
        return jsonify(generate_response(500, str(e))), 500


@app.route('/api/model/info', methods=['GET'])
def model_info():
    """
    模型信息接口
    返回当前加载的模型信息
    """
    det_loaded = detector is not None and detector.model is not None
    rec_loaded = recognizer is not None and recognizer.model is not None

    info = {
        "detection_model": {
            "name": "YOLOv8n",
            "version": "8.0.0",
            "loaded": det_loaded,
            "input_size": [640, 640],
            "classes": ["license_plate"],
            "confidence_threshold": detector.conf_threshold if detector else 0.5,
            "device": detector.device if detector else "cpu"
        },
        "recognition_model": {
            "name": "LPRNet",
            "version": "1.0.0",
            "loaded": rec_loaded,
            "input_size": [94, 24],
            "charset": recognizer.CHARS if recognizer else [],
            "support_chinese": True,
            "device": str(recognizer.device) if recognizer else "cpu"
        },
        "device": detector.device if detector else "cpu",
        "cuda_available": torch.cuda.is_available() if 'torch' in globals() else False
    }

    return jsonify(generate_response(data=info))


# ============ 主程序入口 ============

if __name__ == '__main__':
    print("=" * 50)
    print("智能停车场算法服务")
    print("API 文档: http://localhost:5000")
    print("=" * 50)

    # 加载模型
    load_models()
    print("-" * 50)

    app.run(host='0.0.0.0', port=5000, debug=True)

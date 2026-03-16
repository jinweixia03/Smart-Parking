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

app = Flask(__name__)
CORS(app)

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
            # TODO: 调用检测模型
            # 模拟检测结果
            result = {
                "image_path": filepath,
                "detections": [
                    {
                        "bbox": [100, 200, 300, 280],
                        "confidence": 0.95,
                        "class_id": 0
                    }
                ],
                "detect_time": round((time.time() - start_time) * 1000, 2),
                "detect_count": 1
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
            # TODO: 调用检测+识别模型
            # 模拟识别结果
            result = {
                "image_path": filepath,
                "plate_number": "京A12345",
                "confidence": 0.92,
                "bbox": [100, 200, 300, 280],
                "total_time": round((time.time() - start_time) * 1000, 2)
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
                # TODO: 调用识别模型
                result = {
                    "image_path": filepath,
                    "filename": file.filename,
                    "plate_number": "京A12345",
                    "confidence": 0.92,
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
    模拟入场场景，返回车牌号
    """
    data = request.get_json()

    # 支持从CCPD数据集随机选取图片进行仿真
    simulate_mode = data.get('simulate', False)

    start_time = time.time()

    try:
        # TODO: 从CCPD数据集加载图片进行识别
        # 模拟识别结果
        result = {
            "plate_number": "京A12345",
            "confidence": 0.95,
            "entry_time": datetime.now().isoformat(),
            "image_url": "/uploads/entry_sample.jpg",
            "process_time": round((time.time() - start_time) * 1000, 2)
        }

        return jsonify(generate_response(data=result))

    except Exception as e:
        return jsonify(generate_response(500, str(e))), 500


@app.route('/api/parking/exit', methods=['POST'])
def parking_exit():
    """
    出场识别接口
    模拟出场场景，返回车牌号和停车费用
    """
    data = request.get_json()
    plate_number = data.get('plate_number', '')

    start_time = time.time()

    try:
        # TODO: 从CCPD数据集加载图片进行识别
        # 模拟识别结果
        result = {
            "plate_number": plate_number or "京A12345",
            "confidence": 0.94,
            "exit_time": datetime.now().isoformat(),
            "image_url": "/uploads/exit_sample.jpg",
            "process_time": round((time.time() - start_time) * 1000, 2)
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
        # TODO: 运行性能测试
        result = {
            "runs": runs,
            "avg_time_ms": 45.5,
            "fps": 21.9,
            "device": "cpu"
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
    info = {
        "detection_model": {
            "name": "YOLOv8n",
            "version": "8.0.0",
            "input_size": [640, 640],
            "classes": ["license_plate"],
            "confidence_threshold": 0.5
        },
        "recognition_model": {
            "name": "LPRNet",
            "version": "1.0.0",
            "input_size": [94, 24],
            "charset": "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
            "support_chinese": True
        },
        "device": "cpu",
        "cuda_available": False
    }

    return jsonify(generate_response(data=info))


# ============ 主程序入口 ============

if __name__ == '__main__':
    print("=" * 50)
    print("智能停车场算法服务")
    print("API 文档: http://localhost:5000")
    print("=" * 50)

    app.run(host='0.0.0.0', port=5000, debug=True)

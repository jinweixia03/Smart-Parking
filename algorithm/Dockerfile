# Python 3.10 slim（CPU）
FROM python:3.10-slim

WORKDIR /app

# 系统依赖（OpenCV 需要）
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 \
    libgl1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 先装 CPU 版 PyTorch（单独装避免被 requirements.txt 装成 GPU 版）
RUN pip install --no-cache-dir \
    torch==2.1.0+cpu \
    torchvision==0.16.0+cpu \
    --index-url https://download.pytorch.org/whl/cpu

# 再装其他依赖
COPY requirements-docker.txt .
RUN pip install --no-cache-dir -r requirements-docker.txt

COPY . .

RUN mkdir -p data/uploads

EXPOSE 5000

CMD ["python", "app.py"]

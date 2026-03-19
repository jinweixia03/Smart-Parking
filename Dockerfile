# ================================================================
# Smart Parking System - All-in-One Image
# 包含：MySQL 8 + Spring Boot + Flask(CPU) + Nginx
# ================================================================

# ── 阶段1：前端构建 ─────────────────────────────────────────────
FROM node:18-alpine AS frontend-builder
WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm install --legacy-peer-deps
COPY frontend/ .
RUN npm run build

# ── 阶段2：后端构建 ─────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS backend-builder
WORKDIR /backend
COPY backend/pom.xml .
RUN mvn dependency:go-offline -q
COPY backend/src ./src
RUN mvn package -DskipTests -q

# ── 阶段3：最终镜像 ─────────────────────────────────────────────
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Java 运行时
    openjdk-17-jre-headless \
    # Python
    python3.10 python3-pip python3.10-venv \
    # MySQL
    mysql-server \
    # Nginx
    nginx \
    # 进程管理
    supervisor \
    # 工具
    curl libglib2.0-0 libgl1 tzdata git \
    && rm -rf /var/lib/apt/lists/* \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# ── 安装 Python 依赖 ────────────────────────────────────────────
COPY algorithm/requirements-docker.txt /tmp/
RUN pip3 install --no-cache-dir \
    torch==2.1.0+cpu torchvision==0.16.0+cpu \
    --index-url https://download.pytorch.org/whl/cpu \
    && pip3 install --no-cache-dir -r /tmp/requirements-docker.txt

# ── 复制各服务文件 ──────────────────────────────────────────────
# 后端 jar
COPY --from=backend-builder /backend/target/*.jar /app/backend/app.jar

# 算法服务
COPY algorithm/ /app/algorithm/

# 前端静态文件
COPY --from=frontend-builder /frontend/dist /app/frontend/dist

# 数据库初始化 SQL
COPY backend/src/main/resources/db/sp.sql /app/init.sql

# ── Nginx 配置 ──────────────────────────────────────────────────
COPY docker/nginx.conf /etc/nginx/sites-enabled/default

# ── Supervisor 配置 ─────────────────────────────────────────────
COPY docker/supervisord.conf /etc/supervisor/conf.d/parking.conf

# ── 启动脚本 ────────────────────────────────────────────────────
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

# 创建目录
RUN mkdir -p /app/backend/uploads /app/algorithm/data/uploads /var/log/parking

EXPOSE 3000

CMD ["/start.sh"]

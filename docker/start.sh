#!/bin/bash
set -e

echo "=== Smart Parking System Starting ==="

# ── 初始化 MySQL ────────────────────────────────────────────────
echo "[1/4] Initializing MySQL..."

# 初始化数据目录（首次启动）
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
fi

# 启动 MySQL（临时）
mysqld_safe --user=mysql &
MYSQL_PID=$!

# 等待 MySQL 就绪
echo "Waiting for MySQL..."
for i in $(seq 1 30); do
    if mysqladmin ping -u root --silent 2>/dev/null; then
        break
    fi
    sleep 1
done

# 设置 root 密码并初始化数据库
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
CREATE DATABASE IF NOT EXISTS smart_parking CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smart_parking;
SOURCE /app/init.sql;
FLUSH PRIVILEGES;
EOF

echo "[MySQL] Initialized."

# 停止临时 MySQL（交由 supervisor 管理）
kill $MYSQL_PID
sleep 2

# ── 启动所有服务 ────────────────────────────────────────────────
echo "[2/4] Starting all services via supervisor..."
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

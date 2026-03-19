#!/bin/bash
set -e

echo "=== Smart Parking System Starting ==="

# ── 初始化 MySQL ────────────────────────────────────────────────
echo "[1/4] Initializing MySQL..."

# 清理残留 socket/pid（容器重启时可能遗留）
rm -f /var/run/mysqld/mysqld.pid /var/run/mysqld/mysqld.sock
mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld

# 初始化数据目录（仅首次）
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First run: initializing MySQL data directory..."
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
fi

if [ ! -f "/var/lib/mysql/.parking_initialized" ]; then
    echo "Setting up database for first time..."

    # 第一步：skip-grant-tables 启动，清空 root 密码并改为 native password
    mysqld --user=mysql --daemonize \
        --pid-file=/var/run/mysqld/mysqld-init.pid \
        --skip-grant-tables --skip-networking

    for i in $(seq 1 20); do
        if mysqladmin ping --silent 2>/dev/null; then break; fi
        sleep 1
    done

    mysql -u root mysql <<'SQLEOF'
UPDATE user SET authentication_string='', plugin='mysql_native_password' WHERE User='root' AND Host='localhost';
FLUSH PRIVILEGES;
SQLEOF

    # 关闭 skip-grant-tables 实例
    mysqladmin shutdown 2>/dev/null || true
    sleep 3
    rm -f /var/run/mysqld/mysqld-init.pid /var/run/mysqld/mysqld.sock

    # 第二步：正常启动，设密码并导入数据
    mysqld --user=mysql --daemonize --pid-file=/var/run/mysqld/mysqld-init.pid

    for i in $(seq 1 30); do
        if mysqladmin ping -u root --silent 2>/dev/null; then break; fi
        sleep 1
    done

    mysql -u root <<'SQLEOF'
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
CREATE DATABASE IF NOT EXISTS smart_parking CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
FLUSH PRIVILEGES;
SQLEOF

    mysql -u root -p123456 --default-character-set=utf8mb4 smart_parking < /app/init.sql
    mysql -u root -p123456 --default-character-set=utf8mb4 smart_parking < /app/init_data.sql
    touch /var/lib/mysql/.parking_initialized
    echo "[MySQL] Data imported."

    # 关闭临时实例
    mysqladmin -u root -p123456 shutdown 2>/dev/null || true
    sleep 3
    rm -f /var/run/mysqld/mysqld-init.pid /var/run/mysqld/mysqld.sock
fi

echo "[MySQL] Initialization complete. Handing off to supervisor..."

# ── 启动所有服务 ────────────────────────────────────────────────
echo "[2/4] Starting all services via supervisor..."
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

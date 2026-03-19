<p align="center">
  <img src="frontend/src/assets/images/logo.svg" alt="Smart Parking Logo" width="120" height="120">
</p>

<h1 align="center">Smart Parking 智能停车场管理系统</h1>

<p align="center">
  <strong>基于深度学习的智能停车场管理系统</strong>
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/Spring%20Boot-3.2.5-6DB33F?logo=springboot" alt="Spring Boot"></a>
  <a href="#"><img src="https://img.shields.io/badge/Vue.js-3.4-4FC08D?logo=vue.js" alt="Vue.js"></a>
  <a href="#"><img src="https://img.shields.io/badge/Python-3.10-3776AB?logo=python" alt="Python"></a>
  <a href="#"><img src="https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql" alt="MySQL"></a>
</p>

---

## 目录

- [方式一：Docker 一键运行（推荐，最简单）](#方式一docker-一键运行推荐最简单)
- [方式二：本地手动运行（开发者）](#方式二本地手动运行开发者)
- [默认账号](#默认账号)
- [项目结构](#项目结构)
- [技术栈](#技术栈)

---

## 方式一：Docker 一键运行（推荐，最简单）

> 适合所有人，无需安装 Java / Python / MySQL / Node.js，只需要安装 Docker。

### 第一步：安装 Docker Desktop

1. 打开浏览器，访问：**https://www.docker.com/products/docker-desktop/**
2. 点击页面上的 **"Download for Windows"** 按钮下载安装包
3. 双击下载好的 `.exe` 文件，一路点击 **"下一步"** 安装
4. 安装完成后，**重启电脑**
5. 重启后桌面上会出现 Docker Desktop 图标，双击打开它
6. 等待 Docker Desktop 启动完毕（底部状态栏显示绿色小圆点即为就绪）

> ⚠️ 如果提示需要安装 WSL2，按照提示点击安装即可，然后重启。

---

### 第二步：获取镜像文件

**如果你有 `smart-parking.tar` 文件（通过U盘/网盘获取）：**

跳过此步，直接进入第三步。

**如果你想自己构建（需要先 clone 代码）：**

1. 安装 Git：https://git-scm.com/download/win，一路默认安装
2. 右键桌面，选择 **"Git Bash Here"**，输入：
   ```bash
   git clone https://github.com/jinweixia03/Smart-Parking.git
   cd Smart-Parking
   ```
3. 双击运行项目里的 `build-image.bat`，等待 10-20 分钟自动构建
4. 构建完成后会生成 `smart-parking.tar` 文件

---

### 第三步：加载并运行镜像

1. 按下键盘 `Win + R`，输入 `cmd`，按回车，打开命令提示符
2. 输入以下命令（注意把路径换成你的 tar 文件实际位置）：

```cmd
docker load -i C:\Users\你的用户名\Desktop\smart-parking.tar
```

> 例如文件在桌面，用户名是 zhang，就输入：
> `docker load -i C:\Users\zhang\Desktop\smart-parking.tar`

3. 加载完成后，输入以下命令启动：

```cmd
docker run -d -p 3000:3000 --name parking --restart always smart-parking
```

4. 等待约 **30 秒**，然后打开浏览器，访问：

```
http://localhost:3000
```

看到登录页面说明启动成功 🎉

---

### 常用 Docker 命令

```cmd
# 查看运行状态
docker ps

# 停止服务
docker stop parking

# 再次启动（下次开机后用这个，无需重新 load）
docker start parking

# 查看日志
docker logs parking

# 彻底删除容器（数据会丢失）
docker rm -f parking
```

---

## 方式二：本地手动运行（开发者）

> 适合需要修改代码的开发者。需要逐步安装所有环境。

### 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| Java JDK | 17 | 运行后端 |
| Maven | 3.9 | 构建后端 |
| Node.js | 18+ | 运行前端 |
| Python | 3.10 | 运行算法服务 |
| MySQL | 8.0 | 数据库 |
| MiniConda | 最新 | 管理 Python 环境 |

---

### 第一步：安装 Java 17

1. 访问：https://adoptium.net/
2. 选择 **Temurin 17 (LTS)**，点击下载 Windows x64 `.msi` 安装包
3. 双击安装，**安装时勾选 "Set JAVA_HOME variable"**（重要！）
4. 安装完成后，打开命令提示符（Win+R → cmd），输入：
   ```cmd
   java -version
   ```
   看到 `openjdk version "17..."` 说明安装成功

---

### 第二步：安装 Maven

1. 访问：https://maven.apache.org/download.cgi
2. 下载 **Binary zip archive**（如 `apache-maven-3.9.x-bin.zip`）
3. 解压到一个固定目录，例如 `D:\Environments\maven\apache-maven-3.9.x`
4. 配置环境变量：
   - 右键 "此电脑" → 属性 → 高级系统设置 → 环境变量
   - 在 **系统变量** 中，找到 `Path`，点击编辑
   - 点击新建，输入你的 Maven bin 目录，例如：`D:\Environments\maven\apache-maven-3.9.x\bin`
   - 一路点确定保存
5. 重新打开命令提示符，输入：
   ```cmd
   mvn -version
   ```
   看到版本号说明安装成功

---

### 第三步：安装 Node.js

1. 访问：https://nodejs.org/
2. 下载 **LTS 版本**（长期支持版），点击下载
3. 双击 `.msi` 安装包，一路默认安装（**不要修改安装路径**）
4. 安装完成后，打开新的命令提示符，输入：
   ```cmd
   node -v
   npm -v
   ```
   两个都显示版本号说明安装成功

---

### 第四步：安装 MiniConda（Python 环境管理）

1. 访问：https://docs.conda.io/en/latest/miniconda.html
2. 下载 **Miniconda3 Windows 64-bit**
3. 双击安装，安装时：
   - **勾选 "Add Miniconda3 to my PATH"**（重要！）
   - 安装路径建议用默认路径或 `D:\Environments\MiniConda3`
4. 安装完成后，打开新的命令提示符，输入：
   ```cmd
   conda -V
   ```
   显示版本号说明安装成功
5. 创建并激活 Python 环境：
   ```cmd
   conda create -n yolo python=3.10 -y
   conda activate yolo
   ```
6. 安装算法依赖（在 yolo 环境中）：
   ```cmd
   cd 项目目录\algorithm
   pip install torch==2.1.0 torchvision==0.16.0 --index-url https://download.pytorch.org/whl/cu118
   pip install -r requirements.txt
   ```

---

### 第五步：安装 MySQL 8.0

1. 访问：https://dev.mysql.com/downloads/mysql/
2. 选择 **MySQL Community Server 8.0**，下载 Windows 安装包
3. 双击安装，选择 **Developer Default**，一路下一步
4. 设置 root 密码时，**密码设置为 `123456`**（与项目配置一致）
5. 安装完成后，打开命令提示符，输入：
   ```cmd
   mysql -u root -p
   ```
   输入密码 `123456`，能进入 MySQL 说明安装成功
6. 初始化数据库（在 MySQL 命令行中）：
   ```sql
   CREATE DATABASE smart_parking CHARACTER SET utf8mb4;
   USE smart_parking;
   SOURCE D:/你的项目路径/backend/src/main/resources/db/sp.sql;
   EXIT;
   ```

---

### 第六步：修改 start-all.bat 路径配置

打开项目根目录的 `start-all.bat`，用记事本或 VSCode 打开，修改开头的路径变量：

```bat
REM ⚠️ 根据你的实际安装路径修改以下变量

set "BACKEND_DIR=D:\1_Source\BSYCode\backend"      ← 改成你的项目路径
set "FRONTEND_DIR=D:\1_Source\BSYCode\frontend"    ← 改成你的项目路径
set "ALGORITHM_DIR=D:\1_Source\BSYCode\algorithm"  ← 改成你的项目路径
set "MAVEN_CMD=D:\Environments\maven\apache-maven-3.9.10\bin\mvn.cmd"  ← 改成你的 Maven 路径
set "CONDA_DIR=D:\Environments\MiniConda3"         ← 改成你的 MiniConda 安装路径
set "CONDA_ENV=yolo"                                ← 保持不变
```

**如何找到你的项目路径：**
- 在文件资源管理器中打开项目文件夹
- 点击地址栏，复制完整路径，例如 `C:\Users\zhang\Desktop\Smart-Parking`

**如何找到 Maven 路径：**
- 找到你解压 Maven 的文件夹，复制 `bin\mvn.cmd` 的完整路径

**如何找到 MiniConda 路径：**
- 默认安装在 `C:\Users\你的用户名\miniconda3`
- 如果选择了自定义路径，找到安装时选择的目录

---

### 第七步：启动所有服务

修改好路径后，双击运行 `start-all.bat`，等待所有服务启动。

窗口显示以下内容说明启动成功：
```
[OK] All services started!
Frontend:  http://localhost:3000
Backend:   http://localhost:8080/api
Algorithm: http://localhost:5000/api/health
```

打开浏览器访问：**http://localhost:3000**

---

## 默认账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | `admin` | `admin123` |
| 普通用户 | `user` | `admin123` |

---

## 常见问题

**Q: 端口被占用怎么办？**

打开命令提示符，输入（以 8080 端口为例）：
```cmd
netstat -ano | findstr :8080
```
找到占用的进程 PID，然后：
```cmd
taskkill /F /PID 进程号
```

**Q: MySQL 连不上？**

检查 MySQL 服务是否启动：Win+R → `services.msc` → 找到 MySQL，右键启动。

**Q: 算法服务识别很慢？**

CPU 模式下识别较慢（约 5-15 秒），属于正常现象。如果有 NVIDIA 显卡，重新安装 GPU 版 PyTorch 可大幅提速。

**Q: Docker 容器启动后页面打不开？**

等待 30-60 秒再试，MySQL 初始化需要时间。也可以用 `docker logs parking` 查看启动日志。

---

## 项目结构

```
Smart-Parking/
├── frontend/           # Vue3 前端
├── backend/            # Spring Boot 后端
├── algorithm/          # Python 算法服务（车牌识别）
│   └── weights/        # 训练好的模型权重
├── docker/             # Docker 相关配置
├── Dockerfile          # All-in-One 镜像构建文件
├── docker-compose.yml  # 多容器编排（开发用）
├── build-image.bat     # 一键构建 Docker 镜像脚本
└── start-all.bat       # 本地一键启动脚本
```

---

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | Vue 3 + Vite + Element Plus + ECharts + Three.js |
| 后端 | Spring Boot 3 + MyBatis Plus + Spring Security + JWT |
| 算法 | PyTorch + YOLOv8 + LPRNet + Flask |
| 数据库 | MySQL 8.0 |
| 部署 | Docker + Nginx + Supervisor |

---

## 许可证

[MIT License](LICENSE) © 2024 Smart Parking

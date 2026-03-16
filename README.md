# 智能停车场管理系统

基于深度学习的完整智能停车场仿真管理系统，使用 CCPD2019 数据集构建。

## 技术栈

- **前端**: Vue3 + Element-Plus + Vite
- **后端**: SpringBoot + MyBatis-Plus
- **数据库**: MySQL + Redis
- **算法**: Python + PyTorch + YOLOv8 + LPRNet
- **部署**: Docker + Docker Compose

## 项目结构

```
BSYCode/
├── database/           # 数据库SQL脚本
│   └── smart_parking.sql
├── backend/            # Spring Boot后端
│   ├── src/main/java/com/parking/
│   │   ├── controller/ # 控制器
│   │   ├── service/    # 业务逻辑
│   │   ├── mapper/     # 数据访问
│   │   ├── entity/     # 实体类
│   │   ├── config/     # 配置类
│   │   └── utils/      # 工具类
│   └── pom.xml
├── frontend/           # Vue3前端
│   ├── src/
│   │   ├── api/        # API接口
│   │   ├── views/      # 页面组件
│   │   ├── stores/     # Pinia状态管理
│   │   └── router/     # 路由配置
│   └── package.json
├── algorithm/          # Python算法服务
│   ├── src/models/     # 模型代码
│   ├── app.py          # Flask主应用
│   └── requirements.txt
└── docker/             # Docker部署
    ├── docker-compose.yml
    └── Dockerfile.*
```

## 快速开始

### 1. 环境要求

- Docker 20.10+
- Docker Compose 2.0+
- Java 17+ (本地开发)
- Node.js 20+ (本地开发)
- Python 3.10+ (本地开发)

### 2. Docker一键部署

```bash
cd docker
docker-compose up -d
```

访问：
- 前端页面: http://localhost
- 后端API: http://localhost:8080/api
- 算法服务: http://localhost:5000

### 3. 本地开发

#### 后端

```bash
cd backend
mvn spring-boot:run
```

#### 前端

```bash
cd frontend
npm install
npm run dev
```

#### 算法服务

```bash
cd algorithm
pip install -r requirements.txt
python app.py
```

## 数据库初始化

数据库会在Docker启动时自动初始化，或手动执行：

```bash
mysql -u root -p < database/smart_parking.sql
```

## 默认账号

- 管理员: admin / admin123
- 操作员: operator / admin123

## 核心功能

- **车牌识别**: 基于YOLOv8 + LPRNet的端到端车牌识别
- **停车管理**: 车辆入场、出场、缴费全流程管理
- **车位管理**: 实时车位状态监控与分配
- **数据统计**: 停车流量、收入统计、图表展示
- **仿真系统**: 基于CCPD数据集的入场/出场仿真
- **用户系统**: 用户注册、车辆绑定、缴费记录

## 算法模型

### YOLOv8 检测模型
- 输入尺寸: 640x640
- 检测目标: 车牌区域
- 输出: 边界框坐标 + 置信度

### LPRNet 识别模型
- 输入尺寸: 94x24
- 字符集: 数字 + 字母 + 31个省级行政区
- 输出: 车牌字符串 + 置信度

## API文档

启动后访问：http://localhost:8080/api/swagger-ui.html

## 开发计划

1. 完善算法模型训练与部署
2. 添加更多仿真场景
3. 集成支付接口
4. 移动端H5适配
5. 添加视频监控模块

## 许可证

MIT License

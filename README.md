<p align="center">
  <img src="frontend/src/assets/images/logo.svg" alt="Star Parking Logo" width="120" height="120">
</p>

<h1 align="center">Star Parking</h1>

<p align="center">
  <strong>基于深度学习的智能停车场管理系统</strong>
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/Spring%20Boot-3.2.5-6DB33F?logo=springboot" alt="Spring Boot"></a>
  <a href="#"><img src="https://img.shields.io/badge/Vue.js-3.4-4FC08D?logo=vue.js" alt="Vue.js"></a>
  <a href="#"><img src="https://img.shields.io/badge/Python-3.10-3776AB?logo=python" alt="Python"></a>
  <a href="#"><img src="https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql" alt="MySQL"></a>
  <a href="#"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
</p>

<p align="center">
  <b>简体中文</b> | <a href="#">English</a>
</p>

---

## ✨ 特性

- 🚗 **车牌智能识别** - 基于 YOLO + LPRNet 的端到端车牌检测与识别
- 📊 **数据可视化大屏** - 实时车位状态、收入统计、流量分析
- 🅿️ **停车全流程管理** - 车辆入场、出场、计费、缴费一体化
- 🔐 **JWT 认证授权** - Spring Security + JWT 安全认证机制
- 🎨 **现代化 UI** - Element Plus + 流畅动画效果
- 📱 **响应式设计** - 支持桌面端、平板端访问

## 🚀 快速开始

### 环境要求

| 组件 | 版本 |
|------|------|
| Java | 17+ |
| Node.js | 20+ |
| Python | 3.10+ |
| MySQL | 8.0+ |

### 1. 克隆项目

```bash
git clone https://github.com/jinweixia03/Star-Parking.git
cd Star-Parking
```

### 2. 数据库初始化

```bash
mysql -u root -p < database/smart_parking.sql
```

### 3. 启动后端

```bash
cd backend
mvn spring-boot:run
```

后端服务默认运行在 `http://localhost:8080/api`

### 4. 启动前端

```bash
cd frontend
npm install
npm run dev
```

前端开发服务器默认运行在 `http://localhost:5173`

### 5. 启动算法服务（可选）

```bash
cd algorithm
pip install -r requirements.txt
python app.py
```

算法服务默认运行在 `http://localhost:5000`

## 📁 项目结构

```
Star-Parking/
├── frontend/                 # Vue3 前端项目
│   ├── src/
│   │   ├── api/             # API 接口
│   │   ├── views/           # 页面视图
│   │   ├── stores/          # Pinia 状态管理
│   │   └── router/          # 路由配置
│   └── package.json
├── backend/                  # Spring Boot 后端项目
│   ├── src/main/java/com/parking/
│   │   ├── controller/      # 控制器层
│   │   ├── service/         # 业务逻辑层
│   │   ├── mapper/          # 数据访问层
│   │   ├── entity/          # 实体类
│   │   └── utils/           # 工具类
│   ├── src/main/resources/mapper/  # MyBatis XML
│   └── pom.xml
├── algorithm/                # Python 算法服务
│   ├── src/models/          # 模型定义
│   ├── app.py               # Flask 主应用
│   └── requirements.txt
└── database/
    └── smart_parking.sql    # 数据库初始化脚本
```

## 🛠️ 技术栈

### 前端

- **框架**: [Vue 3](https://vuejs.org/) + Composition API
- **构建工具**: [Vite 5](https://vitejs.dev/)
- **UI 组件库**: [Element Plus](https://element-plus.org/)
- **状态管理**: [Pinia](https://pinia.vuejs.org/)
- **路由**: [Vue Router 4](https://router.vuejs.org/)
- **图表**: [ECharts 5](https://echarts.apache.org/)
- **动画**: [GSAP](https://greensock.com/gsap/)
- **工具库**: [VueUse](https://vueuse.org/)

### 后端

- **框架**: [Spring Boot 3.2](https://spring.io/projects/spring-boot)
- **ORM**: [MyBatis Plus 3.5](https://baomidou.com/)
- **安全**: Spring Security + JWT
- **实时通信**: WebSocket
- **JSON 处理**: FastJSON2
- **工具库**: Hutool

### 算法

- **Web 框架**: Flask
- **数据处理**: Pandas, NumPy
- **可视化**: Matplotlib
- **深度学习**: PyTorch (预留接口)

## 📸 截图

| 登录页面 | 数据大屏 | 停车管理 |
|:--------:|:--------:|:--------:|
| <img src="docs/images/login.png" width="280"> | <img src="docs/images/dashboard.png" width="280"> | <img src="docs/images/parking.png" width="280"> |

## 🔑 默认账号

```
管理员: admin / admin123
```

## 🔌 API 文档

后端启动后访问 Swagger UI：

```
http://localhost:8080/api/swagger-ui.html
```

## 📝 配置说明

### 后端配置 (`backend/src/main/resources/application.yml`)

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/smart_parking
    username: root
    password: your_password

jwt:
  secret: your-secret-key
  expiration: 86400000  # 24 hours
```

### 前端代理配置 (`frontend/vite.config.ts`)

开发环境已配置代理：

```typescript
server: {
  proxy: {
    '/api': 'http://localhost:8080'
  }
}
```

## 📜 许可证

[MIT License](LICENSE) © 2024 Star Parking Team

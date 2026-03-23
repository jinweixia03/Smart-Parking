<template>
  <div class="login-page">
    <!-- 背景动画 -->
    <div class="bg-animation">
      <div class="bg-circle circle-1"></div>
      <div class="bg-circle circle-2"></div>
      <div class="bg-circle circle-3"></div>
    </div>

    <!-- 登录容器 - 圆角卡片形式 -->
    <div class="login-container" :class="{ 'fade-in': showContainer }">
      <!-- 左侧品牌区域 -->
      <div class="brand-section">
        <div class="brand-content">
          <div class="logo-wrapper">
            <div class="logo-icon">
              <img src="@/assets/images/logo-white.svg" alt="Logo" class="logo-img" />
            </div>
            <h1 class="brand-title">Star Parking</h1>
          </div>
          <div class="brand-text">
            <p class="greeting">Hi! 你好!</p>
            <p class="welcome">欢迎进入IPMS</p>
            <p class="description">基于深度学习的车牌识别与停车管理解决方案</p>
          </div>
          <div class="features">
            <div class="feature-item" v-for="(item, index) in features" :key="index">
              <el-icon :size="20" color="#67e8f9"><Check /></el-icon>
              <span>{{ item }}</span>
            </div>
          </div>
        </div>
        <div class="brand-image">
          <img src="@/assets/parking.jpg" alt="parking" />
        </div>
      </div>

      <!-- 右侧登录表单 -->
      <div class="form-section">
        <div class="form-wrapper" :class="{ 'slide-up': showForm }">
          <h2 class="form-title">登录系统</h2>
          <p class="form-subtitle">请输入您的账号信息</p>

          <el-form
            ref="loginFormRef"
            :model="loginForm"
            :rules="loginRules"
            class="login-form"
            @keyup.enter="handleLogin"
          >
            <!-- 用户名输入框 -->
            <el-form-item prop="username" class="form-item-animated" :class="{ 'focused': usernameFocused }">
              <div class="input-label">
                <span>用户账号</span>
                <a class="link-text" @click="$router.push('/register')">注册账号</a>
              </div>
              <el-input
                v-model="loginForm.username"
                placeholder="请输入用户名"
                size="large"
                class="custom-input"
                @focus="usernameFocused = true"
                @blur="usernameFocused = false"
              >
                <template #prefix>
                  <el-icon :size="18"><User /></el-icon>
                </template>
              </el-input>
            </el-form-item>

            <!-- 密码输入框 -->
            <el-form-item prop="password" class="form-item-animated" :class="{ 'focused': passwordFocused }">
              <div class="input-label">
                <span>用户密码</span>
                <a class="link-text" @click="forgotPassword">忘记密码?</a>
              </div>
              <el-input
                v-model="loginForm.password"
                type="password"
                placeholder="请输入密码"
                size="large"
                class="custom-input"
                show-password
                @focus="passwordFocused = true"
                @blur="passwordFocused = false"
              >
                <template #prefix>
                  <el-icon :size="18"><Lock /></el-icon>
                </template>
              </el-input>
            </el-form-item>

            <!-- 记住密码 -->
            <div class="form-options">
              <el-checkbox v-model="rememberMe" class="remember-checkbox">
                记住密码
              </el-checkbox>
            </div>

            <!-- 登录按钮 -->
            <el-form-item>
              <el-button
                type="primary"
                size="large"
                :loading="loading"
                class="login-btn"
                @click="handleLogin"
              >
                <span class="btn-text">登 录</span>
                <el-icon class="btn-icon" v-if="!loading"><ArrowRight /></el-icon>
              </el-button>
            </el-form-item>
          </el-form>

          <!-- 其他登录方式 -->
          <div class="other-login">
            <div class="divider">
              <span>其他登录方式</span>
            </div>
            <div class="login-icons">
              <div class="icon-item" @click="otherLogin('wechat')">
                <el-icon :size="24" color="#07c160"><ChatDotRound /></el-icon>
              </div>
              <div class="icon-item" @click="otherLogin('phone')">
                <el-icon :size="24" color="#409eff"><Iphone /></el-icon>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 页脚 -->
    <div class="login-footer">
      <p>© 2024 智能停车场综合管理系统 (IPMS) | 版权所有</p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock, ArrowRight, Check, ChatDotRound, Iphone } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

// 响应式状态
const loginFormRef = ref(null)
const loading = ref(false)
const rememberMe = ref(false)
const showContainer = ref(false)
const showForm = ref(false)
const usernameFocused = ref(false)
const passwordFocused = ref(false)

// 特性列表
const features = [
  'AI 智能车牌识别',
  '实时车位监控',
  '自动计费结算',
  '数据可视化分析'
]

// 表单数据
const loginForm = reactive({
  username: '',
  password: ''
})

// 从本地存储读取记住的密码
onMounted(() => {
  const savedUsername = localStorage.getItem('parking_username')
  const savedPassword = localStorage.getItem('parking_password')
  if (savedUsername && savedPassword) {
    loginForm.username = savedUsername
    loginForm.password = atob(savedPassword)
    rememberMe.value = true
  }

  // 触发动画
  setTimeout(() => {
    showContainer.value = true
  }, 100)
  setTimeout(() => {
    showForm.value = true
  }, 300)
})

// 表单验证规则
const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度应在 3-20 个字符之间', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度应在 6-20 个字符之间', trigger: 'blur' }
  ]
}

// 处理登录
const handleLogin = async () => {
  if (!loginFormRef.value) return

  await loginFormRef.value.validate(async (valid) => {
    if (!valid) return

    loading.value = true
    try {
      await userStore.login(loginForm)

      // 处理记住密码
      if (rememberMe.value) {
        localStorage.setItem('parking_username', loginForm.username)
        localStorage.setItem('parking_password', btoa(loginForm.password))
      } else {
        localStorage.removeItem('parking_username')
        localStorage.removeItem('parking_password')
      }

      ElMessage.success('登录成功！欢迎回来')
      router.push('/')
    } catch (error) {
      ElMessage.error(error.message || '登录失败，请检查用户名和密码')
    } finally {
      loading.value = false
    }
  })
}

// 忘记密码
const forgotPassword = () => {
  router.push('/forgot-password')
}

// 其他登录方式
const otherLogin = (type) => {
  ElMessage.info(`${type === 'wechat' ? '微信' : '手机'}登录功能开发中...`)
}
</script>

<style scoped lang="scss">
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: relative;
  overflow: hidden;
  padding: 20px;
}

// 背景动画
.bg-animation {
  position: absolute;
  width: 100%;
  height: 100%;
  overflow: hidden;
  z-index: 0;
}

.bg-circle {
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  animation: float 20s infinite ease-in-out;
}

.circle-1 {
  width: 600px;
  height: 600px;
  top: -200px;
  left: -200px;
  animation-delay: 0s;
}

.circle-2 {
  width: 400px;
  height: 400px;
  bottom: -100px;
  right: -100px;
  animation-delay: -5s;
}

.circle-3 {
  width: 300px;
  height: 300px;
  top: 50%;
  left: 50%;
  animation-delay: -10s;
}

@keyframes float {
  0%, 100% {
    transform: translate(0, 0) scale(1);
  }
  33% {
    transform: translate(30px, -30px) scale(1.1);
  }
  66% {
    transform: translate(-20px, 20px) scale(0.9);
  }
}

// 登录容器 - 圆角卡片形式
.login-container {
  display: flex;
  width: 100%;
  max-width: 1000px;
  min-height: 560px;
  max-height: 85vh;
  background: #fff;
  border-radius: 20px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  overflow: hidden;
  z-index: 1;
  opacity: 0;
  transform: translateY(30px);
  transition: all 0.8s cubic-bezier(0.34, 1.56, 0.64, 1);

  &.fade-in {
    opacity: 1;
    transform: translateY(0);
  }
}

// 左侧品牌区域
.brand-section {
  flex: 1;
  background: linear-gradient(135deg, #1e3a8a 0%, #3730a3 50%, #1e1b4b 100%);
  padding: 48px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  color: #fff;
  position: relative;
  overflow: hidden;
  min-width: 400px;

  &::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 60%);
    animation: rotate 30s linear infinite;
  }
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.brand-content {
  position: relative;
  z-index: 1;
}

.logo-wrapper {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 32px;
}

.logo-icon {
  width: 72px;
  height: 72px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);

  .logo-img {
    width: 56px;
    height: 56px;
    object-fit: contain;
  }
}

.brand-title {
  font-size: 36px;
  font-weight: 700;
  letter-spacing: 2px;
}

.brand-text {
  margin-bottom: 32px;

  .greeting {
    font-size: 20px;
    font-weight: 300;
    margin-bottom: 8px;
    opacity: 0.9;
  }

  .welcome {
    font-size: 28px;
    font-weight: 600;
    margin-bottom: 12px;
  }

  .description {
    font-size: 14px;
    opacity: 0.8;
    line-height: 1.6;
  }
}

.features {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  opacity: 0.9;
}

.brand-image {
  position: relative;
  z-index: 1;
  margin-top: 24px;

  img {
    width: 100%;
    max-width: 320px;
    height: auto;
    max-height: 160px;
    object-fit: cover;
    border-radius: 12px;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
  }
}

// 右侧表单区域
.form-section {
  flex: 0 0 460px;
  padding: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
}

.form-wrapper {
  width: 100%;
  opacity: 0;
  transform: translateY(20px);
  transition: all 0.6s ease-out;

  &.slide-up {
    opacity: 1;
    transform: translateY(0);
  }
}

.form-title {
  font-size: 32px;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 8px;
}

.form-subtitle {
  font-size: 14px;
  color: #64748b;
  margin-bottom: 40px;
}

// 表单样式
.login-form {
  :deep(.el-form-item) {
    margin-bottom: 24px;
  }
}

.form-item-animated {
  transition: transform 0.3s ease;

  &.focused {
    transform: translateX(5px);
  }
}

.input-label {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  font-size: 14px;
  color: #374151;
  font-weight: 500;
}

.link-text {
  color: #2563eb;
  font-size: 13px;
  cursor: pointer;
  transition: color 0.3s;

  &:hover {
    color: #1d4ed8;
    text-decoration: underline;
  }
}

// 自定义输入框
:deep(.custom-input) {
  .el-input__wrapper {
    padding: 0 15px;
    height: 52px;
    border-radius: 12px;
    box-shadow: 0 0 0 1px #e0e0e0 inset;
    transition: all 0.3s ease;

    &:hover, &.is-focus {
      box-shadow: 0 0 0 2px #2563eb inset;
    }
  }

  .el-input__prefix {
    margin-right: 10px;
    color: #9ca3af;
  }

  .el-input__inner {
    font-size: 15px;

    &::placeholder {
      color: #aaa;
    }
  }
}

// 记住密码
.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

:deep(.remember-checkbox) {
  .el-checkbox__label {
    font-size: 13px;
    color: #64748b;
  }

  .el-checkbox__input.is-checked .el-checkbox__inner {
    background-color: #2563eb;
    border-color: #2563eb;
  }
}

// 登录按钮
.login-btn {
  width: 100%;
  height: 52px;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  border: none;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 20px rgba(37, 99, 235, 0.3);
  }

  &:active {
    transform: translateY(0);
  }

  .btn-text {
    letter-spacing: 2px;
  }

  .btn-icon {
    transition: transform 0.3s ease;
  }

  &:hover .btn-icon {
    transform: translateX(4px);
  }
}

// 其他登录方式
.other-login {
  margin-top: 40px;
}

.divider {
  position: relative;
  text-align: center;
  margin-bottom: 20px;

  &::before {
    content: '';
    position: absolute;
    top: 50%;
    left: 0;
    right: 0;
    height: 1px;
    background: linear-gradient(90deg, transparent, #ddd, transparent);
  }

  span {
    position: relative;
    background: #fff;
    padding: 0 16px;
    font-size: 13px;
    color: #94a3b8;
  }
}

.login-icons {
  display: flex;
  justify-content: center;
  gap: 20px;
}

.icon-item {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: #e8e8e8;
    transform: translateY(-3px);
  }
}

// 页脚
.login-footer {
  position: absolute;
  bottom: 20px;
  left: 0;
  right: 0;
  text-align: center;
  color: rgba(255, 255, 255, 0.6);
  font-size: 12px;
  z-index: 1;
}

// 响应式适配 - 大屏幕
@media (max-width: 1280px) {
  .login-container {
    max-width: 900px;
    min-height: 520px;
  }

  .brand-section {
    padding: 40px;
    min-width: 360px;
  }

  .form-section {
    flex: 0 0 400px;
    padding: 40px;
  }
}

// 平板尺寸
@media (max-width: 1024px) {
  .login-container {
    max-width: 800px;
    min-height: 480px;
  }

  .brand-section {
    padding: 32px;
    min-width: 320px;

    .logo-wrapper {
      margin-bottom: 24px;
    }

    .logo-icon {
      width: 56px;
      height: 56px;
    }

    .brand-title {
      font-size: 28px;
    }

    .brand-text {
      margin-bottom: 24px;

      .greeting {
        font-size: 18px;
      }

      .welcome {
        font-size: 24px;
      }

      .description {
        font-size: 13px;
      }
    }

    .brand-image {
      margin-top: 20px;

      img {
        max-width: 260px;
        max-height: 130px;
      }
    }
  }

  .form-section {
    flex: 0 0 360px;
    padding: 32px;
  }

  .form-title {
    font-size: 28px;
  }

  .form-subtitle {
    margin-bottom: 32px;
  }
}

// 小平板/大手机
@media (max-width: 768px) {
  .login-container {
    flex-direction: column;
    max-width: 400px;
    min-height: auto;
    max-height: none;
  }

  .brand-section {
    display: none;
  }

  .form-section {
    flex: 1;
    padding: 40px 32px;
  }

  .login-footer {
    position: relative;
    bottom: auto;
    margin-top: 20px;
    color: rgba(255, 255, 255, 0.8);
  }
}

// 手机尺寸
@media (max-width: 480px) {
  .login-page {
    padding: 0;
    background: #fff;
  }

  .login-container {
    border-radius: 0;
    min-height: 100vh;
    max-height: none;
    box-shadow: none;
  }

  .form-section {
    padding: 32px 24px;
  }

  .form-title {
    font-size: 26px;
  }

  .form-subtitle {
    font-size: 14px;
    margin-bottom: 28px;
  }

  .login-footer {
    color: #94a3b8;
    padding-bottom: 20px;
  }
}

// 小手机
@media (max-width: 360px) {
  .form-section {
    padding: 24px 20px;
  }

  :deep(.custom-input) {
    .el-input__wrapper {
      height: 48px;
    }
  }

  .login-btn {
    height: 48px;
  }
}
</style>

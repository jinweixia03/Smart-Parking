<template>
  <div class="register-page">
    <!-- 背景动画 -->
    <div class="bg-animation">
      <div class="bg-circle circle-1"></div>
      <div class="bg-circle circle-2"></div>
      <div class="bg-circle circle-3"></div>
    </div>

    <!-- 注册容器 - 圆角卡片形式 -->
    <div class="register-container" :class="{ 'fade-in': showContainer }">
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
            <p class="greeting">加入我们</p>
            <p class="welcome">创建您的账号</p>
            <p class="description">开启智能停车管理新体验</p>
          </div>
          <div class="features">
            <div class="feature-item" v-for="(item, index) in features" :key="index">
              <el-icon :size="18" color="#67e8f9"><Check /></el-icon>
              <span>{{ item }}</span>
            </div>
          </div>
        </div>
        <div class="brand-image">
          <img src="@/assets/parking.jpg" alt="parking" />
        </div>
      </div>

      <!-- 右侧注册表单 -->
      <div class="form-section">
        <div class="form-wrapper" :class="{ 'slide-up': showForm }">
          <h2 class="form-title">注册账号</h2>
          <p class="form-subtitle">请填写以下信息完成注册</p>

          <el-form
            ref="registerFormRef"
            :model="registerForm"
            :rules="registerRules"
            class="register-form"
            @keyup.enter="handleRegister"
          >
            <!-- 用户名 -->
            <el-form-item prop="username" class="form-item-animated" :class="{ 'focused': usernameFocused }">
              <div class="input-label">
                <span>用户名</span>
              </div>
              <el-input
                v-model="registerForm.username"
                placeholder="请输入用户名 (3-20个字符)"
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

            <!-- 密码 -->
            <el-form-item prop="password" class="form-item-animated" :class="{ 'focused': passwordFocused }">
              <div class="input-label">
                <span>密码</span>
              </div>
              <el-input
                v-model="registerForm.password"
                type="password"
                placeholder="请输入密码 (6-20个字符)"
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

            <!-- 确认密码 -->
            <el-form-item prop="confirmPassword" class="form-item-animated" :class="{ 'focused': confirmPasswordFocused }">
              <div class="input-label">
                <span>确认密码</span>
              </div>
              <el-input
                v-model="registerForm.confirmPassword"
                type="password"
                placeholder="请再次输入密码"
                size="large"
                class="custom-input"
                show-password
                @focus="confirmPasswordFocused = true"
                @blur="confirmPasswordFocused = false"
              >
                <template #prefix>
                  <el-icon :size="18"><Lock /></el-icon>
                </template>
              </el-input>
            </el-form-item>

            <!-- 手机号 -->
            <el-form-item prop="phone" class="form-item-animated" :class="{ 'focused': phoneFocused }">
              <div class="input-label">
                <span>手机号</span>
              </div>
              <el-input
                v-model="registerForm.phone"
                placeholder="请输入手机号"
                size="large"
                class="custom-input"
                @focus="phoneFocused = true"
                @blur="phoneFocused = false"
              >
                <template #prefix>
                  <el-icon :size="18"><Iphone /></el-icon>
                </template>
              </el-input>
            </el-form-item>

            <!-- 用户协议 -->
            <div class="form-options">
              <el-checkbox v-model="agreeTerms" class="terms-checkbox">
                我已阅读并同意
                <a @click.stop="showTerms">用户协议</a>
                和
                <a @click.stop="showPrivacy">隐私政策</a>
              </el-checkbox>
            </div>

            <!-- 注册按钮 -->
            <el-form-item>
              <el-button
                type="primary"
                size="large"
                :loading="loading"
                class="register-btn"
                :disabled="!agreeTerms"
                @click="handleRegister"
              >
                <span class="btn-text">注 册</span>
                <el-icon class="btn-icon" v-if="!loading"><ArrowRight /></el-icon>
              </el-button>
            </el-form-item>
          </el-form>

          <!-- 返回登录 -->
          <div class="back-to-login">
            <span>已有账号？</span>
            <a class="link-text" @click="goLogin">立即登录</a>
          </div>
        </div>
      </div>
    </div>

    <!-- 页脚 -->
    <div class="register-footer">
      <p>© 2024 智能停车场综合管理系统 (IPMS) | 版权所有</p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock, ArrowRight, Check, Iphone } from '@element-plus/icons-vue'
import { register } from '@/api/auth'

const router = useRouter()

// 响应式状态
const registerFormRef = ref(null)
const loading = ref(false)
const agreeTerms = ref(false)
const showContainer = ref(false)
const showForm = ref(false)
const usernameFocused = ref(false)
const passwordFocused = ref(false)
const confirmPasswordFocused = ref(false)
const phoneFocused = ref(false)

// 特性列表
const features = [
  'AI 智能车牌识别',
  '实时车位监控',
  '自动计费结算',
  '数据可视化分析'
]

// 表单数据
const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  phone: ''
})

// 自定义验证：确认密码
const validateConfirmPassword = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请再次输入密码'))
  } else if (value !== registerForm.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

// 自定义验证：手机号
const validatePhone = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请输入手机号'))
  } else if (!/^1[3-9]\d{9}$/.test(value)) {
    callback(new Error('手机号格式不正确'))
  } else {
    callback()
  }
}

// 表单验证规则
const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度应在 3-20 个字符之间', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9_]+$/, message: '用户名只能包含字母、数字和下划线', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度应在 6-20 个字符之间', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validateConfirmPassword, trigger: 'blur' }
  ],
  phone: [
    { required: true, validator: validatePhone, trigger: 'blur' }
  ]
}

// 触发动画
onMounted(() => {
  setTimeout(() => {
    showContainer.value = true
  }, 100)
  setTimeout(() => {
    showForm.value = true
  }, 300)
})

// 处理注册
const handleRegister = async () => {
  if (!registerFormRef.value) return

  await registerFormRef.value.validate(async (valid) => {
    if (!valid) return

    if (!agreeTerms.value) {
      ElMessage.warning('请阅读并同意用户协议和隐私政策')
      return
    }

    loading.value = true
    try {
      await register({
        username: registerForm.username,
        password: registerForm.password,
        phone: registerForm.phone
      })
      ElMessage.success('注册成功！请登录')
      router.push('/login')
    } catch (error) {
      ElMessage.error(error.message || '注册失败，请重试')
    } finally {
      loading.value = false
    }
  })
}

// 跳转登录
const goLogin = () => {
  router.push('/login')
}

// 显示用户协议
const showTerms = () => {
  ElMessage.info('用户协议功能开发中...')
}

// 显示隐私政策
const showPrivacy = () => {
  ElMessage.info('隐私政策功能开发中...')
}
</script>

<style scoped lang="scss">
.register-page {
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

// 注册容器 - 圆角卡片形式
.register-container {
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
  flex: 0 0 420px;
  padding: 40px 48px;
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
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 8px;
}

.form-subtitle {
  font-size: 14px;
  color: #64748b;
  margin-bottom: 24px;
}

// 表单样式
.register-form {
  :deep(.el-form-item) {
    margin-bottom: 16px;
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
  margin-bottom: 6px;
  font-size: 13px;
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
    height: 44px;
    border-radius: 10px;
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
    font-size: 14px;

    &::placeholder {
      color: #aaa;
    }
  }
}

// 用户协议
.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

:deep(.terms-checkbox) {
  .el-checkbox__label {
    font-size: 12px;
    color: #64748b;

    a {
      color: #2563eb;
      cursor: pointer;

      &:hover {
        text-decoration: underline;
      }
    }
  }

  .el-checkbox__input.is-checked .el-checkbox__inner {
    background-color: #2563eb;
    border-color: #2563eb;
  }
}

// 注册按钮
.register-btn {
  width: 100%;
  height: 44px;
  border-radius: 10px;
  font-size: 15px;
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

  &[disabled] {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
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

// 返回登录
.back-to-login {
  margin-top: 20px;
  text-align: center;
  font-size: 13px;
  color: #64748b;

  .link-text {
    margin-left: 5px;
    font-size: 13px;
  }
}

// 页脚
.register-footer {
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
  .register-container {
    max-width: 900px;
    min-height: 520px;
  }

  .brand-section {
    padding: 40px;
    min-width: 360px;
  }

  .form-section {
    flex: 0 0 400px;
    padding: 36px 40px;
  }
}

// 平板尺寸
@media (max-width: 1024px) {
  .register-container {
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
    font-size: 26px;
  }

  .form-subtitle {
    margin-bottom: 20px;
  }
}

// 小平板/大手机
@media (max-width: 768px) {
  .register-container {
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

  .register-footer {
    position: relative;
    bottom: auto;
    margin-top: 20px;
    color: rgba(255, 255, 255, 0.8);
  }
}

// 手机尺寸
@media (max-width: 480px) {
  .register-page {
    padding: 0;
    background: #fff;
  }

  .register-container {
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
    margin-bottom: 20px;
  }

  .register-footer {
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
      height: 42px;
    }
  }

  .register-btn {
    height: 42px;
  }
}
</style>

<template>
  <div class="forgot-page">
    <!-- 背景动画 -->
    <div class="bg-animation">
      <div class="bg-circle circle-1"></div>
      <div class="bg-circle circle-2"></div>
      <div class="bg-circle circle-3"></div>
    </div>

    <!-- 主容器 -->
    <div class="forgot-container" :class="{ 'fade-in': showContainer }">
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
            <p class="greeting">忘记密码?</p>
            <p class="welcome">不用担心</p>
            <p class="description">输入您的用户名和注册手机号，验证通过后即可重置密码</p>
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

      <!-- 右侧表单区域 -->
      <div class="form-section">
        <div class="form-wrapper" :class="{ 'slide-up': showForm }">
          <div class="form-header">
            <el-button
              class="back-btn"
              link
              @click="$router.push('/login')"
            >
              <el-icon><ArrowLeft /></el-icon>
              返回登录
            </el-button>
          </div>

          <h2 class="form-title">重置密码</h2>
          <p class="form-subtitle">请输入注册时使用的手机号</p>

          <el-form
            ref="formRef"
            :model="form"
            :rules="rules"
            class="forgot-form"
            @keyup.enter="handleSubmit"
          >
            <!-- 用户名输入框 -->
            <el-form-item prop="username" class="form-item-animated" :class="{ 'focused': usernameFocused }">
              <div class="input-label">
                <span>用户名</span>
              </div>
              <el-input
                v-model="form.username"
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

            <!-- 手机号输入框 -->
            <el-form-item prop="phone" class="form-item-animated" :class="{ 'focused': phoneFocused }">
              <div class="input-label">
                <span>注册手机号</span>
              </div>
              <el-input
                v-model="form.phone"
                placeholder="请输入注册手机号"
                size="large"
                class="custom-input"
                maxlength="11"
                @focus="phoneFocused = true"
                @blur="phoneFocused = false"
              >
                <template #prefix>
                  <el-icon :size="18"><Iphone /></el-icon>
                </template>
              </el-input>
            </el-form-item>

            <!-- 新密码输入框 -->
            <el-form-item prop="newPassword" class="form-item-animated" :class="{ 'focused': passwordFocused }">
              <div class="input-label">
                <span>新密码</span>
              </div>
              <el-input
                v-model="form.newPassword"
                type="password"
                placeholder="请输入新密码（6-20位）"
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

            <!-- 确认密码输入框 -->
            <el-form-item prop="confirmPassword" class="form-item-animated" :class="{ 'focused': confirmFocused }">
              <div class="input-label">
                <span>确认新密码</span>
              </div>
              <el-input
                v-model="form.confirmPassword"
                type="password"
                placeholder="请再次输入新密码"
                size="large"
                class="custom-input"
                show-password
                @focus="confirmFocused = true"
                @blur="confirmFocused = false"
              >
                <template #prefix>
                  <el-icon :size="18"><Lock /></el-icon>
                </template>
              </el-input>
            </el-form-item>

            <!-- 提示信息 -->
            <div class="tips">
              <el-icon :size="14" color="#f59e0b"><Warning /></el-icon>
              <span>重置成功后，请使用新密码登录</span>
            </div>

            <!-- 提交按钮 -->
            <el-form-item>
              <el-button
                type="primary"
                size="large"
                :loading="loading"
                class="submit-btn"
                @click="handleSubmit"
              >
                <span class="btn-text">重置密码</span>
                <el-icon class="btn-icon" v-if="!loading"><ArrowRight /></el-icon>
              </el-button>
            </el-form-item>
          </el-form>
        </div>
      </div>
    </div>

    <!-- 页脚 -->
    <div class="forgot-footer">
      <p>© 2024 智能停车场管理系统 | 版权所有</p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Iphone, Lock, ArrowRight, Check, ArrowLeft, Warning, User } from '@element-plus/icons-vue'
import { forgotPassword } from '@/api/auth'

const router = useRouter()

// 响应式状态
const formRef = ref(null)
const loading = ref(false)
const showContainer = ref(false)
const showForm = ref(false)
const usernameFocused = ref(false)
const phoneFocused = ref(false)
const passwordFocused = ref(false)
const confirmFocused = ref(false)

// 特性列表
const features = [
  '快速重置密码',
  '支持手机号验证',
  '安全可靠的流程',
  '即时生效'
]

// 表单数据
const form = reactive({
  username: '',
  phone: '',
  newPassword: '',
  confirmPassword: ''
})

// 表单验证规则
const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度应在 3-20 个字符之间', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度应在 6-20 个字符之间', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== form.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
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

// 处理提交
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    loading.value = true
    try {
      await forgotPassword({
        username: form.username,
        phone: form.phone,
        newPassword: form.newPassword
      })
      ElMessage.success('密码重置成功，请使用新密码登录')
      // 跳转到登录页
      setTimeout(() => {
        router.push('/login')
      }, 1500)
    } catch (error) {
      ElMessage.error(error.message || '密码重置失败，请检查手机号是否正确')
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped lang="scss">
.forgot-page {
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

// 主容器
.forgot-container {
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
  padding: 40px 60px 60px;
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

.form-header {
  margin-bottom: 24px;
}

.back-btn {
  color: #64748b;
  font-size: 14px;
  padding: 0;

  &:hover {
    color: #2563eb;
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
.forgot-form {
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

// 提示信息
.tips {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 24px;
  padding: 12px 16px;
  background: #fffbeb;
  border-radius: 8px;
  font-size: 13px;
  color: #92400e;
}

// 提交按钮
.submit-btn {
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

// 页脚
.forgot-footer {
  position: absolute;
  bottom: 20px;
  left: 0;
  right: 0;
  text-align: center;
  color: rgba(255, 255, 255, 0.6);
  font-size: 12px;
  z-index: 1;
}

// 响应式适配
@media (max-width: 1024px) {
  .forgot-container {
    max-width: 800px;
    min-height: 480px;
  }

  .brand-section {
    padding: 32px;
    min-width: 320px;
  }

  .form-section {
    flex: 0 0 400px;
    padding: 32px;
  }
}

@media (max-width: 768px) {
  .forgot-container {
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
}

@media (max-width: 480px) {
  .forgot-page {
    padding: 0;
    background: #fff;
  }

  .forgot-container {
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
}
</style>

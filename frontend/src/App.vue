<template>
  <router-view v-slot="{ Component }">
    <transition name="app" mode="out-in">
      <component :is="Component" />
    </transition>
  </router-view>
</template>

<script setup>
// 监听系统主题变化
const darkModeMediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
const handleThemeChange = (e) => {
  document.documentElement.setAttribute('data-theme', e.matches ? 'dark' : 'light')
}
darkModeMediaQuery.addEventListener('change', handleThemeChange)

// 初始化主题
handleThemeChange(darkModeMediaQuery)
</script>

<style lang="scss">
// ============================================
// 全局样式 - 冰川蓝主题
// ============================================

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

body {
  font-family: var(--font-sans);
  background: var(--bg-gradient-main);
  background-attachment: fixed;
  color: var(--text-primary);
  min-height: 100vh;
}

#app {
  height: 100vh;
  overflow: hidden;
}

// ============================================
// 全局过渡动画
// ============================================
.app-enter-active,
.app-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.app-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.app-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

// ============================================
// 滚动条样式 - 蓝色调
// ============================================
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: transparent;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: rgba(59, 130, 246, 0.25);
  border-radius: 4px;
  border: 2px solid transparent;
  background-clip: padding-box;

  &:hover {
    background: rgba(37, 99, 235, 0.4);
  }

  &:active {
    background: rgba(29, 78, 216, 0.5);
  }
}

* {
  scrollbar-width: thin;
  scrollbar-color: rgba(59, 130, 246, 0.25) transparent;
}

// ============================================
// 选中文本
// ============================================
::selection {
  background: rgba(37, 99, 235, 0.2);
  color: var(--primary-darker);
}

// ============================================
// 链接样式
// ============================================
a {
  color: var(--primary-color);
  text-decoration: none;
  transition: color var(--transition-fast);

  &:hover {
    color: var(--primary-dark);
  }
}

// ============================================
// 按钮基础
// ============================================
button {
  font-family: inherit;
}

// ============================================
// Toast 通知样式
// ============================================
.toast-container {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: var(--z-tooltip);
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.toast {
  min-width: 300px;
  padding: 16px 20px;
  background: var(--glass-bg-strong);
  backdrop-filter: blur(20px) saturate(180%);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--glass-border);
  transform: translateX(100%);
  opacity: 0;
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);

  &.show {
    transform: translateX(0);
    opacity: 1;
  }

  &-success {
    border-left: 4px solid var(--success-color);
  }

  &-error {
    border-left: 4px solid var(--danger-color);
  }

  &-warning {
    border-left: 4px solid var(--warning-color);
  }

  &-info {
    border-left: 4px solid var(--primary-color);
  }

  .toast-content {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .toast-message {
    font-size: 14px;
    font-weight: 500;
    color: var(--text-primary);
  }
}

// ============================================
// 页面通用样式
// ============================================
.page-container {
  animation: fadeIn 0.5s ease;
  padding: 24px;
  height: 100%;
  overflow-y: auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 28px;
  padding: 24px;
  background: var(--glass-bg-strong);
  backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-sm);

  .page-title {
    font-size: 28px;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 8px;
    background: var(--primary-gradient);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .page-subtitle {
    font-size: 15px;
    color: var(--text-tertiary);
  }
}

// ============================================
// 卡片通用样式
// ============================================
.card-base {
  background: var(--glass-bg-strong);
  backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-sm);
  transition: all var(--transition-base);

  &:hover {
    box-shadow: var(--shadow-md), var(--shadow-glow-soft);
    border-color: rgba(59, 130, 246, 0.3);
  }
}

.card-solid {
  background: var(--bg-card);
  border: 1px solid var(--border-light);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-sm);
  transition: all var(--transition-base);

  &:hover {
    box-shadow: var(--shadow-md);
  }
}

// ============================================
// Element Plus 样式覆盖
// ============================================
:root {
  // Element Plus 主题色 - 冰川蓝
  --el-color-primary: #2563eb;
  --el-color-primary-light-3: #3b82f6;
  --el-color-primary-light-5: #60a5fa;
  --el-color-primary-light-7: #93c5fd;
  --el-color-primary-light-8: #bfdbfe;
  --el-color-primary-light-9: #dbeafe;
  --el-color-primary-dark-2: #1d4ed8;

  --el-border-radius-base: 12px;
  --el-border-radius-small: 8px;
}

// 表格样式
:deep(.el-table) {
  border-radius: var(--radius-lg);
  overflow: hidden;
  background: transparent !important;

  th.el-table__cell {
    background: rgba(241, 245, 249, 0.9) !important;
    font-weight: 600;
    color: var(--text-primary);
    padding: 16px;
    border-bottom: 1px solid var(--border-light);
  }

  td.el-table__cell {
    padding: 14px 16px;
    color: var(--text-secondary);
  }

  .el-table__row {
    transition: background var(--transition-fast);

    &:hover {
      background: rgba(224, 242, 254, 0.5) !important;
    }
  }

  &::before {
    display: none;
  }
}

// 表单样式
:deep(.el-form-item__label) {
  font-weight: 500;
  color: var(--text-primary);
}

:deep(.el-input__wrapper) {
  background: var(--bg-card);
  border-radius: var(--radius-md);
  box-shadow: 0 0 0 1px var(--border-color) inset;
  transition: all var(--transition-fast);

  &:hover, &:focus-within {
    box-shadow: 0 0 0 1px var(--primary-light) inset, var(--shadow-glow-soft);
  }

  &.is-focus {
    box-shadow: 0 0 0 1px var(--primary-color) inset, var(--shadow-glow);
  }
}

// 按钮样式
:deep(.el-button) {
  border-radius: var(--radius-md);
  font-weight: 500;
  transition: all var(--transition-fast);
}

:deep(.el-button:not(:disabled):hover) {
  transform: translateY(-1px);
}

:deep(.el-button--primary) {
  background: var(--primary-gradient);
  border: none;
  box-shadow: var(--shadow-blue-sm);
}

:deep(.el-button--primary:hover) {
  background: linear-gradient(135deg, #1d4ed8 0%, #2563eb 50%, #0891b2 100%);
  box-shadow: var(--shadow-blue-md);
}

// 分页样式
:deep(.el-pagination) {
  .el-pagination__total,
  .el-pagination__jump {
    color: var(--text-muted);
  }

  .el-pager li {
    border-radius: var(--radius-sm);
    margin: 0 4px;
    transition: all var(--transition-fast);

    &.is-active {
      background: var(--primary-gradient);
      box-shadow: var(--shadow-blue-sm);
    }

    &:hover:not(.is-active) {
      background: var(--bg-hover);
      color: var(--primary-color);
    }
  }
}

// 标签样式
:deep(.el-tag) {
  border-radius: var(--radius-sm);
  font-weight: 500;
  padding: 4px 12px;
}

:deep(.el-tag--primary) {
  background: var(--primary-pale);
  border-color: var(--primary-soft);
  color: var(--primary-dark);
}

:deep(.el-tag--success) {
  background: var(--success-pale);
  border-color: var(--success-light);
  color: #047857;
}

:deep(.el-tag--warning) {
  background: var(--warning-pale);
  border-color: var(--warning-light);
  color: #b45309;
}

:deep(.el-tag--danger) {
  background: var(--danger-pale);
  border-color: var(--danger-light);
  color: #b91c1c;
}

// 对话框样式
:deep(.el-dialog) {
  background: rgba(255, 255, 255, 0.98) !important;
  border: 1px solid var(--border-light);
  border-radius: var(--radius-xl) !important;
  box-shadow: var(--shadow-xl), var(--shadow-glow-soft) !important;

  .el-dialog__header {
    padding: 20px 24px;
    margin: 0;
    border-bottom: 1px solid var(--border-lighter);

    .el-dialog__title {
      font-size: 18px;
      font-weight: 600;
      color: var(--text-primary);
    }
  }

  .el-dialog__body {
    padding: 24px;
    color: var(--text-secondary);
  }

  .el-dialog__footer {
    padding: 16px 24px 24px;
    border-top: 1px solid var(--border-lighter);
  }
}

// 下拉菜单样式
:deep(.el-dropdown-menu) {
  background: rgba(255, 255, 255, 0.98);
  border: 1px solid var(--border-light);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  padding: 8px;

  .el-dropdown-menu__item {
    border-radius: var(--radius-sm);
    padding: 10px 16px;
    margin: 2px 0;
    color: var(--text-secondary);

    &:hover {
      background: var(--bg-hover);
      color: var(--primary-color);
    }
  }
}

// 菜单样式
:deep(.el-menu) {
  background: transparent;
  border-right: none;

  .el-menu-item {
    color: var(--text-secondary);
    border-radius: var(--radius-md);
    margin: 4px 12px;

    &:hover {
      background: var(--bg-hover);
      color: var(--primary-color);
    }

    &.is-active {
      background: var(--primary-pale);
      color: var(--primary-color);
      font-weight: 500;
    }
  }

  .el-sub-menu__title {
    color: var(--text-secondary);
    border-radius: var(--radius-md);
    margin: 4px 12px;

    &:hover {
      background: var(--bg-hover);
      color: var(--primary-color);
    }
  }
}

// 卡片
:deep(.el-card) {
  background: var(--glass-bg-strong);
  backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-xl) !important;
  box-shadow: var(--shadow-sm) !important;

  .el-card__header {
    border-bottom: 1px solid var(--border-lighter);
    padding: 20px 24px;
    font-weight: 600;
    color: var(--text-primary);
  }

  .el-card__body {
    padding: 24px;
  }
}

// 消息提示
:deep(.el-message) {
  background: rgba(255, 255, 255, 0.98) !important;
  border: 1px solid var(--border-light);
  border-radius: var(--radius-lg) !important;
  box-shadow: var(--shadow-lg) !important;
}

:deep(.el-message--success) {
  border-left: 4px solid var(--success-color);
}

:deep(.el-message--error) {
  border-left: 4px solid var(--danger-color);
}

:deep(.el-message--warning) {
  border-left: 4px solid var(--warning-color);
}

:deep(.el-message--info) {
  border-left: 4px solid var(--primary-color);
}

// 提示框
:deep(.el-tooltip__popper) {
  background: var(--gray-800) !important;
  border-radius: var(--radius-md) !important;
  padding: 8px 12px !important;
}

// 日期选择器
:deep(.el-picker-panel) {
  background: rgba(255, 255, 255, 0.98) !important;
  border: 1px solid var(--border-light);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
}

// 开关
:deep(.el-switch) {
  .el-switch__core {
    border-radius: var(--radius-full);
  }

  &.is-checked .el-switch__core {
    background: var(--primary-color);
    border-color: var(--primary-color);
  }
}

// 滑块
:deep(.el-slider) {
  .el-slider__bar {
    background: var(--primary-gradient);
  }

  .el-slider__button {
    border-color: var(--primary-color);
    background: white;
  }
}

// 进度条
:deep(.el-progress) {
  .el-progress-bar__outer {
    background: var(--bg-secondary);
  }

  .el-progress-bar__inner {
    background: var(--primary-gradient);
  }
}

// 上传
:deep(.el-upload) {
  .el-upload-dragger {
    background: var(--bg-card);
    border: 2px dashed var(--border-color);
    border-radius: var(--radius-lg);

    &:hover {
      border-color: var(--primary-light);
      background: var(--bg-hover);
    }
  }
}

// 加载
:deep(.el-loading-mask) {
  background: rgba(241, 245, 249, 0.9);
  backdrop-filter: blur(4px);
}

// ============================================
// 工具类
// ============================================
.glass {
  background: var(--glass-bg-strong);
  backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid var(--glass-border);
}

.gradient-text {
  background: var(--primary-gradient);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.text-primary { color: var(--text-primary); }
.text-secondary { color: var(--text-secondary); }
.text-tertiary { color: var(--text-tertiary); }
.text-muted { color: var(--text-muted); }

.bg-primary { background: var(--bg-primary); }
.bg-secondary { background: var(--bg-secondary); }
.bg-card { background: var(--bg-card); }

.shadow-sm { box-shadow: var(--shadow-sm); }
.shadow-md { box-shadow: var(--shadow-md); }
.shadow-lg { box-shadow: var(--shadow-lg); }
.shadow-blue { box-shadow: var(--shadow-blue-sm); }
.shadow-glow { box-shadow: var(--shadow-glow); }
</style>

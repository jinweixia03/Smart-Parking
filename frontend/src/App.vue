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
// 全局样式
// ============================================

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  font-family: var(--font-sans);
  background: var(--bg-secondary);
  color: var(--text-primary);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#app {
  height: 100vh;
  overflow: hidden;
}

// 全局过渡
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

// 滚动条样式
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: var(--gray-100);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: var(--gray-300);
  border-radius: 4px;
  transition: background 0.3s ease;

  &:hover {
    background: var(--gray-400);
  }
}

// 选中文字样式
::selection {
  background: rgba(37, 99, 235, 0.2);
  color: var(--primary-dark);
}

// 链接样式
a {
  color: var(--primary-color);
  text-decoration: none;
  transition: color 0.3s ease;

  &:hover {
    color: var(--primary-dark);
  }
}

// 按钮基础样式
button {
  font-family: inherit;
}

// Element Plus 样式覆盖
:root {
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

// Toast 样式
.toast-container {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.toast {
  min-width: 300px;
  padding: 16px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  transform: translateX(100%);
  opacity: 0;
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);

  &.show {
    transform: translateX(0);
    opacity: 1;
  }

  &-success {
    border-left: 4px solid #10b981;
  }

  &-error {
    border-left: 4px solid #ef4444;
  }

  &-warning {
    border-left: 4px solid #f59e0b;
  }

  &-info {
    border-left: 4px solid #2563eb;
  }

  .toast-content {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .toast-message {
    font-size: 14px;
    font-weight: 500;
    color: #1e293b;
  }
}

// 页面通用样式
.page-container {
  animation: fadeIn 0.5s ease;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 28px;
  padding-bottom: 24px;
  border-bottom: 1px solid #e2e8f0;

  .page-title {
    font-size: 32px;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 8px;
    background: linear-gradient(135deg, #1e293b 0%, #475569 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .page-subtitle {
    font-size: 16px;
    color: #64748b;
  }
}

// 卡片通用样式
.card-base {
  background: white;
  border-radius: 20px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;

  &:hover {
    box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
  }
}

// 表格样式优化
:deep(.el-table) {
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);

  th.el-table__cell {
    background: #f8fafc !important;
    font-weight: 600;
    color: #374151;
    padding: 16px;
  }

  td.el-table__cell {
    padding: 16px;
  }

  .el-table__row {
    transition: background 0.3s ease;

    &:hover {
      background: #f8fafc !important;
    }
  }
}

// 表单样式优化
:deep(.el-form-item__label) {
  font-weight: 500;
  color: #374151;
}

:deep(.el-input__wrapper) {
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;

  &:hover, &:focus-within {
    box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);
  }
}

// 按钮样式优化
:deep(.el-button) {
  border-radius: 10px;
  font-weight: 500;
  transition: all 0.3s ease;

  &:not(:disabled):hover {
    transform: translateY(-1px);
  }

  &:not(:disabled):active {
    transform: translateY(0);
  }
}

:deep(.el-button--primary) {
  background: linear-gradient(135deg, #2563eb, #1d4ed8);
  border: none;

  &:hover {
    background: linear-gradient(135deg, #1d4ed8, #1e40af);
  }
}

// 分页样式优化
:deep(.el-pagination) {
  .el-pagination__total,
  .el-pagination__jump {
    color: #64748b;
  }

  .el-pager li {
    border-radius: 8px;
    margin: 0 4px;
    transition: all 0.3s ease;

    &.is-active {
      background: linear-gradient(135deg, #2563eb, #1d4ed8);
    }

    &:hover:not(.is-active) {
      background: #f1f5f9;
      color: #2563eb;
    }
  }
}

// 标签样式优化
:deep(.el-tag) {
  border-radius: 8px;
  font-weight: 500;
  padding: 4px 12px;
}

// 对话框样式优化
:deep(.el-dialog) {
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);

  .el-dialog__header {
    padding: 24px 24px 0;
    margin-bottom: 20px;

    .el-dialog__title {
      font-size: 20px;
      font-weight: 600;
      color: #1e293b;
    }
  }

  .el-dialog__body {
    padding: 0 24px 24px;
  }

  .el-dialog__footer {
    padding: 16px 24px 24px;
  }
}

// 下拉菜单样式优化
:deep(.el-dropdown-menu) {
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  padding: 8px;

  .el-dropdown-menu__item {
    border-radius: 8px;
    padding: 10px 16px;
    margin: 2px 0;

    &:hover {
      background: #f1f5f9;
      color: #2563eb;
    }
  }
}
</style>

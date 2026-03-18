<template>
  <div class="glacier-layout" :class="{ 'sidebar-collapsed': isCollapsed }">
    <!-- 侧边栏 - 冰川蓝风格 -->
    <aside class="sidebar">
      <div class="sidebar-bg"></div>

      <!-- Logo区域 -->
      <div class="sidebar-header">
        <div class="logo">
          <div class="logo-icon">
            <img src="@/assets/images/logo-white.svg" alt="Logo" />
          </div>
          <span class="logo-text">StarParking</span>
        </div>
      </div>

      <!-- 用户信息卡片 -->
      <div class="user-card">
        <div class="user-avatar">
          {{ userStore.username?.charAt(0).toUpperCase() }}
        </div>
        <div class="user-info">
          <div class="user-name">{{ userStore.username }}</div>
          <div class="user-role">
            <span class="role-badge" :class="userStore.isAdmin ? 'admin' : 'user'">
              {{ userRoleText }}
            </span>
          </div>
        </div>
      </div>

      <!-- 导航菜单 -->
      <nav class="sidebar-menu">
        <div class="menu-title">功能导航</div>
        <div class="menu-list">
          <router-link
            v-for="item in menuItems"
            :key="item.path"
            :to="item.path"
            class="menu-item"
            :class="{ active: $route.path === item.path }"
          >
            <div class="menu-icon-wrapper">
              <el-icon><component :is="item.icon" /></el-icon>
            </div>
            <span class="menu-text">{{ item.title }}</span>
            <div v-if="item.badge" class="menu-badge">{{ item.badge }}</div>
            <div v-if="$route.path === item.path" class="active-indicator"></div>
          </router-link>
        </div>
      </nav>

      <!-- 底部操作区 -->
      <div class="sidebar-footer">
        <button class="collapse-btn" @click="toggleSidebar">
          <el-icon><Fold v-if="!isCollapsed" /><Expand v-else /></el-icon>
          <span v-show="!isCollapsed">收起菜单</span>
        </button>
      </div>
    </aside>

    <!-- 主内容区 -->
    <main class="main-content">
      <!-- 顶部导航栏 -->
      <header class="top-header">
        <div class="header-left">
          <breadcrumb />
        </div>

        <div class="header-right">
          <!-- 搜索 -->
          <div class="search-bar" :class="{ expanded: searchExpanded }">
            <el-icon class="search-icon"><Search /></el-icon>
            <el-input
              v-show="searchExpanded"
              v-model="searchQuery"
              placeholder="搜索功能、数据..."
              clearable
            />
          </div>

          <!-- 快捷操作 -->
          <div class="quick-actions">
            <div class="action-icon" @click="toggleFullscreen">
              <el-icon><FullScreen /></el-icon>
            </div>
            <div class="action-icon" @click="toggleTheme">
              <el-icon><Sunny v-if="isDark" /><Moon v-else /></el-icon>
            </div>
            <el-badge :value="3" class="action-icon notification">
              <el-icon><Bell /></el-icon>
            </el-badge>
          </div>

          <!-- 用户菜单 -->
          <div class="user-menu" ref="userMenuRef">
            <div class="user-trigger" @click="toggleUserDropdown">
              <div class="user-avatar-small">
                {{ userStore.username?.charAt(0).toUpperCase() }}
              </div>
              <span class="user-name-text">{{ userStore.username }}</span>
              <el-icon class="dropdown-arrow" :class="{ 'is-open': showUserDropdown }"><ArrowDown /></el-icon>
            </div>
            <div class="user-dropdown" v-show="showUserDropdown">
              <div class="dropdown-item" @click="handleLogout">
                <el-icon><SwitchButton /></el-icon>
                <span>退出登录</span>
              </div>
            </div>
          </div>
        </div>
      </header>

      <!-- 页面标签栏 -->
      <div class="tabs-bar">
        <div class="tabs-list">
          <div
            v-for="tab in visitedViews"
            :key="tab.path"
            class="tab-item"
            :class="{ active: $route.path === tab.path }"
            @click="$router.push(tab.path)"
          >
            <el-icon v-if="tab.icon"><component :is="tab.icon" /></el-icon>
            <span>{{ tab.title }}</span>
            <el-icon class="close" @click.stop="closeTab(tab)"><Close /></el-icon>
          </div>
        </div>
      </div>

      <!-- 页面内容 -->
      <div class="page-container">
        <router-view v-slot="{ Component }">
          <transition name="page-fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'
import Breadcrumb from '@/components/common/Breadcrumb.vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const isCollapsed = ref(false)
const searchExpanded = ref(false)
const searchQuery = ref('')
const isDark = ref(false)
const visitedViews = ref([])
const showUserDropdown = ref(false)
const userMenuRef = ref(null)

// 切换用户下拉菜单
const toggleUserDropdown = () => {
  showUserDropdown.value = !showUserDropdown.value
}

// 点击外部关闭下拉菜单
const handleClickOutside = (event) => {
  if (userMenuRef.value && !userMenuRef.value.contains(event.target)) {
    showUserDropdown.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

// 根据用户类型显示不同菜单
const menuItems = computed(() => {
  if (userStore.isAdmin) {
    return [
      { path: '/dashboard', title: '数据大屏', icon: 'Odometer' },
      { path: '/records', title: '停车记录', icon: 'Document' },
      { path: '/spaces', title: '车位管理', icon: 'MapLocation' },
      { path: '/simulation', title: '仿真系统', icon: 'VideoCamera' },
      { path: '/settings', title: '系统设置', icon: 'Setting' }
    ]
  }
  return [
    { path: '/my-records', title: '我的停车记录', icon: 'Document' }
  ]
})

const userRoleText = computed(() => userStore.isAdmin ? '管理员' : '普通用户')

// 监听路由变化，添加到标签栏
watch(() => route.path, () => {
  const currentRoute = route.matched[route.matched.length - 1]
  if (currentRoute?.meta?.title) {
    const tab = {
      path: route.path,
      title: currentRoute.meta.title,
      icon: currentRoute.meta.icon
    }
    if (!visitedViews.value.find(v => v.path === tab.path)) {
      visitedViews.value.push(tab)
    }
  }
}, { immediate: true })

const toggleSidebar = () => {
  isCollapsed.value = !isCollapsed.value
  localStorage.setItem('sidebar-collapsed', isCollapsed.value)
}

const toggleFullscreen = () => {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen()
  } else {
    document.exitFullscreen()
  }
}

const toggleTheme = () => {
  isDark.value = !isDark.value
  document.documentElement.setAttribute('data-theme', isDark.value ? 'dark' : 'light')
}

const closeTab = (tab) => {
  const index = visitedViews.value.findIndex(v => v.path === tab.path)
  visitedViews.value.splice(index, 1)
  if (tab.path === route.path && visitedViews.value.length > 0) {
    router.push(visitedViews.value[Math.max(0, index - 1)].path)
  }
}

const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'settings':
      router.push('/settings')
      break
    case 'logout':
      handleLogout()
      break
  }
}

const handleLogout = () => {
  ElMessageBox.confirm('确定要退出登录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    userStore.logout()
    ElMessage.success('已退出登录')
    router.push('/login')
  })
}

// 恢复侧边栏状态
const savedCollapsed = localStorage.getItem('sidebar-collapsed')
if (savedCollapsed) {
  isCollapsed.value = savedCollapsed === 'true'
}
</script>

<style scoped lang="scss">
// ============================================
// 冰川蓝主题变量
// ============================================
$sidebar-width: 260px;
$sidebar-collapsed: 88px;
$transition-duration: 0.4s;

// 弹性动画曲线
$ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
$ease-out-back: cubic-bezier(0.34, 1.56, 0.64, 1);
$ease-in-out-smooth: cubic-bezier(0.4, 0, 0.2, 1);

// 冰川蓝主色
$glacier-primary: #2563eb;
$glacier-primary-light: #3b82f6;
$glacier-primary-soft: #60a5fa;
$glacier-primary-pale: #dbeafe;

// 背景色
$bg-warm: #f1f5f9;
$bg-card: rgba(255, 255, 255, 0.85);
$bg-hover: #e0f2fe;

// 文字色
$text-primary: #1e293b;
$text-secondary: #334155;
$text-tertiary: #475569;
$text-muted: #64748b;
$text-placeholder: #94a3b8;

// 边框
$border-light: rgba(59, 130, 246, 0.12);
$border-soft: rgba(59, 130, 246, 0.08);

// ============================================
// 布局容器
// ============================================
.glacier-layout {
  display: flex;
  height: 100vh;
  background: linear-gradient(135deg, #f0f7ff 0%, #e0f2fe 25%, #f1f5f9 50%, #e2e8f0 75%, #f0f7ff 100%);
  background-attachment: fixed;

  &.sidebar-collapsed {
    .sidebar {
      width: $sidebar-collapsed;

      // 隐藏所有文字元素
      .logo-text,
      .user-info,
      .menu-title,
      .menu-text,
      .menu-badge {
        opacity: 0;
        width: 0;
        height: 0;
        overflow: hidden;
      }

      // 头部居中
      .sidebar-header {
        padding: 20px 0;
        justify-content: center;

        .logo {
          justify-content: center;
        }
      }

      // 用户卡片仅显示头像
      .user-card {
        margin: 0 16px 16px;
        padding: 0;
        background: transparent;
        border: none;
        box-shadow: none;
        justify-content: center;

        .user-avatar {
          width: 48px;
          height: 48px;
          font-size: 18px;
          box-shadow: 0 4px 16px rgba(37, 99, 235, 0.25);
        }
      }

      // 导航菜单居中
      .sidebar-menu {
        padding: 0 16px;

        .menu-list {
          gap: 8px;

          .menu-item {
            padding: 0;
            height: 56px;
            justify-content: center;
            border-radius: 14px;

            .menu-icon-wrapper {
              width: 48px;
              height: 48px;
              border-radius: 12px;

              .el-icon {
                font-size: 22px;
              }
            }

            &.active {
              .menu-icon-wrapper {
                box-shadow: 0 6px 20px rgba(37, 99, 235, 0.4);
              }
            }
          }
        }
      }

      // 底部操作区 - 居中显示折叠按钮
      .sidebar-footer {
        padding: 16px;
        display: flex;
        justify-content: center;

        .collapse-btn {
          width: 48px;
          height: 48px;
          border-radius: 12px;
          background: rgba(37, 99, 235, 0.08);

          &:hover {
            background: rgba(37, 99, 235, 0.15);
          }

          .el-icon {
            transform: rotate(180deg);
          }
        }
      }
    }

    .main-content {
      margin-left: $sidebar-collapsed;
    }
  }
}

// ============================================
// 侧边栏
// ============================================
.sidebar {
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  width: $sidebar-width;
  background: rgba(255, 255, 255, 0.75);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border-right: 1px solid $border-light;
  display: flex;
  flex-direction: column;
  z-index: 1000;
  transition: width $transition-duration $ease-out-expo;
  box-shadow: 4px 0 24px rgba(37, 99, 235, 0.08);

  .sidebar-bg {
    position: absolute;
    inset: 0;
    background:
      radial-gradient(ellipse at 0% 0%, rgba(37, 99, 235, 0.06) 0%, transparent 50%),
      radial-gradient(ellipse at 100% 100%, rgba(6, 182, 212, 0.04) 0%, transparent 50%);
    pointer-events: none;
  }
}

// ============================================
// Logo区域
// ============================================
.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 20px 16px;
  position: relative;
  z-index: 1;
  transition: padding $transition-duration $ease-out-expo;

  .logo {
    display: flex;
    align-items: center;
    gap: 12px;
    transition: gap $transition-duration $ease-out-expo;

    .logo-icon {
      width: 42px;
      height: 42px;
      min-width: 42px;
      background: linear-gradient(135deg, #2563eb 0%, #3b82f6 50%, #06b6d4 100%);
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 20px rgba(37, 99, 235, 0.35);
      transition: all $transition-duration $ease-out-back;

      img {
        width: 26px;
        height: 26px;
        object-fit: contain;
        transition: all $transition-duration $ease-out-back;
      }

      &:hover {
        transform: scale(1.08) rotate(-3deg);
        box-shadow: 0 6px 24px rgba(37, 99, 235, 0.45);
      }
    }

    .logo-text {
      font-size: 20px;
      font-weight: 700;
      background: linear-gradient(135deg, #2563eb 0%, #06b6d4 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      white-space: nowrap;
      letter-spacing: 0.5px;
      opacity: 1;
      transform: translateX(0);
      transition: all $transition-duration $ease-out-expo;
    }
  }
}

// ============================================
// 用户卡片
// ============================================
.user-card {
  margin: 0 16px 16px;
  padding: 14px;
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid $border-soft;
  border-radius: 14px;
  display: flex;
  align-items: center;
  gap: 12px;
  position: relative;
  z-index: 1;
  transition: all $transition-duration $ease-out-expo;
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.06);
  overflow: hidden;

  &:hover {
    background: rgba(255, 255, 255, 0.9);
    border-color: $border-light;
    box-shadow: 0 6px 20px rgba(37, 99, 235, 0.12);
    transform: translateY(-2px);
  }

  .user-avatar {
    width: 42px;
    height: 42px;
    min-width: 42px;
    background: linear-gradient(135deg, #2563eb 0%, #06b6d4 100%);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: 600;
    font-size: 17px;
    box-shadow: 0 4px 16px rgba(37, 99, 235, 0.3);
    transition: all $transition-duration $ease-out-back;
  }

  .user-info {
    flex: 1;
    min-width: 0;
    opacity: 1;
    transform: translateX(0);
    transition: all $transition-duration $ease-out-expo;

    .user-name {
      font-size: 14px;
      font-weight: 600;
      color: $text-primary;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .user-role {
      margin-top: 4px;

      .role-badge {
        display: inline-flex;
        align-items: center;
        padding: 3px 10px;
        border-radius: 20px;
        font-size: 11px;
        font-weight: 500;

        &.admin {
          background: rgba(37, 99, 235, 0.12);
          color: $glacier-primary;
        }

        &.user {
          background: rgba(16, 185, 129, 0.12);
          color: #059669;
        }
      }
    }
  }
}

// ============================================
// 导航菜单
// ============================================
.sidebar-menu {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 0 12px;
  position: relative;
  z-index: 1;

  .menu-title {
    padding: 0 8px;
    margin-bottom: 10px;
    font-size: 11px;
    font-weight: 600;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    opacity: 1;
    transform: translateX(0);
    transition: all $transition-duration $ease-out-expo;
  }

  .menu-list {
    display: flex;
    flex-direction: column;
    gap: 4px;

    .menu-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 14px;
      border-radius: 12px;
      color: $text-muted;
      text-decoration: none;
      transition: all 0.25s $ease-in-out-smooth;
      position: relative;
      overflow: hidden;

      &::before {
        content: '';
        position: absolute;
        left: 0;
        top: 50%;
        transform: translateY(-50%) scaleY(0);
        width: 3px;
        height: 60%;
        background: linear-gradient(180deg, #2563eb, #06b6d4);
        border-radius: 0 3px 3px 0;
        transition: transform 0.3s $ease-out-back;
      }

      &:hover {
        background: rgba(37, 99, 235, 0.06);
        color: $glacier-primary;
        transform: translateX(4px);
      }

      &.active {
        background: rgba(37, 99, 235, 0.1);
        color: $glacier-primary;

        &::before {
          transform: translateY(-50%) scaleY(1);
        }

        .menu-icon-wrapper {
          background: linear-gradient(135deg, #2563eb 0%, #3b82f6 100%);
          color: white;
          box-shadow: 0 4px 16px rgba(37, 99, 235, 0.35);
        }
      }

      .menu-icon-wrapper {
        width: 36px;
        height: 36px;
        min-width: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 10px;
        background: rgba(37, 99, 235, 0.06);
        transition: all $transition-duration $ease-out-back;
        flex-shrink: 0;

        .el-icon {
          font-size: 18px;
          transition: transform 0.2s $ease-out-back;
        }
      }

      &:hover .menu-icon-wrapper {
        transform: scale(1.1);

        .el-icon {
          transform: rotate(-5deg);
        }
      }

      .menu-text {
        font-size: 14px;
        font-weight: 500;
        white-space: nowrap;
        flex: 1;
        opacity: 1;
        transform: translateX(0);
        transition: all $transition-duration $ease-out-expo;
      }

      .menu-badge {
        padding: 2px 8px;
        background: #ef4444;
        color: white;
        font-size: 11px;
        font-weight: 600;
        border-radius: 20px;
        opacity: 1;
        transform: scale(1);
        transition: all $transition-duration $ease-out-back;
      }

      .active-indicator {
        width: 6px;
        height: 6px;
        border-radius: 50%;
        background: $glacier-primary;
        box-shadow: 0 0 8px rgba(37, 99, 235, 0.5);
        opacity: 1;
        transform: scale(1);
        transition: all $transition-duration $ease-out-back;
      }
    }
  }
}

// ============================================
// 底部操作区 - 仅包含折叠按钮
// ============================================
.sidebar-footer {
  padding: 14px;
  position: relative;
  z-index: 1;
  border-top: 1px solid $border-soft;
  display: flex;
  justify-content: center;

  .collapse-btn {
    width: 100%;
    height: 44px;
    border: none;
    background: rgba(37, 99, 235, 0.08);
    border-radius: 12px;
    color: $text-muted;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    transition: all 0.25s $ease-out-back;

    &:hover {
      background: rgba(37, 99, 235, 0.15);
      color: $glacier-primary;
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);
    }

    .el-icon {
      font-size: 16px;
      transition: transform $transition-duration $ease-out-back;
    }

    span {
      font-size: 14px;
      font-weight: 500;
    }
  }
}

// ============================================
// 主内容区
// ============================================
.main-content {
  flex: 1;
  margin-left: $sidebar-width;
  display: flex;
  flex-direction: column;
  transition: margin-left $transition-duration $ease-out-expo;
}

// ============================================
// 顶部导航栏
// ============================================
.top-header {
  flex-shrink: 0;
  height: 68px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  background: rgba(255, 255, 255, 0.65);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border-bottom: 1px solid $border-soft;

  .header-left {
    display: flex;
    align-items: center;
    gap: 20px;
  }

  .header-right {
    display: flex;
    align-items: center;
    gap: 16px;

    .search-bar {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 10px 16px;
      background: rgba(37, 99, 235, 0.05);
      border: 1px solid $border-soft;
      border-radius: 12px;
      transition: all 0.25s $ease-in-out-smooth;

      &:hover, &.expanded {
        background: rgba(37, 99, 235, 0.08);
        border-color: $border-light;
        box-shadow: 0 4px 12px rgba(37, 99, 235, 0.1);
      }

      .search-icon {
        color: $text-muted;
        cursor: pointer;
        transition: transform 0.2s $ease-out-back;

        &:hover {
          transform: scale(1.1);
          color: $glacier-primary;
        }
      }

      :deep(.el-input__wrapper) {
        background: transparent;
        box-shadow: none;
        padding: 0;
        width: 200px;

        .el-input__inner {
          color: $text-primary;

          &::placeholder {
            color: $text-placeholder;
          }
        }
      }
    }

    .user-menu {
      position: relative;

      .user-trigger {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 6px 12px;
        border-radius: 10px;
        cursor: pointer;
        transition: all 0.25s ease;

        &:hover {
          background: rgba(37, 99, 235, 0.08);
        }

        .user-avatar-small {
          width: 32px;
          height: 32px;
          min-width: 32px;
          background: linear-gradient(135deg, #2563eb 0%, #06b6d4 100%);
          border-radius: 8px;
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          font-weight: 600;
          font-size: 14px;
        }

        .user-name-text {
          font-size: 14px;
          font-weight: 500;
          color: $text-primary;
          max-width: 100px;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }

        .dropdown-arrow {
          font-size: 12px;
          color: $text-muted;
          transition: transform 0.3s ease;

          &.is-open {
            transform: rotate(180deg);
          }
        }
      }

      .user-dropdown {
        position: absolute;
        top: calc(100% + 8px);
        right: 0;
        min-width: 140px;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border: 1px solid $border-light;
        border-radius: 12px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.12);
        padding: 6px;
        z-index: 1000;
        animation: dropdown-in 0.2s ease;

        .dropdown-item {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 10px 12px;
          border-radius: 8px;
          cursor: pointer;
          color: $text-secondary;
          font-size: 14px;
          transition: all 0.2s ease;

          &:hover {
            background: rgba(37, 99, 235, 0.08);
            color: #ef4444;
          }

          .el-icon {
            font-size: 16px;
          }
        }
      }
    }

    @keyframes dropdown-in {
      from {
        opacity: 0;
        transform: translateY(-8px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .quick-actions {
      display: flex;
      align-items: center;
      gap: 10px;

      .action-icon {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 10px;
        background: rgba(37, 99, 235, 0.05);
        border: 1px solid $border-soft;
        color: $text-muted;
        cursor: pointer;
        transition: all 0.25s $ease-out-back;

        &:hover {
          background: rgba(37, 99, 235, 0.1);
          border-color: $border-light;
          color: $glacier-primary;
          transform: translateY(-2px) scale(1.05);
          box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);
        }

        &.notification {
          :deep(.el-badge__content) {
            background: #ef4444;
            border: none;
            box-shadow: 0 2px 8px rgba(239, 68, 68, 0.4);
            animation: pulse-badge 2s infinite;
          }
        }
      }
    }
  }
}

// ============================================
// 页面标签栏
// ============================================
.tabs-bar {
  flex-shrink: 0;
  height: 44px;
  padding: 0 24px;
  background: rgba(255, 255, 255, 0.4);
  border-bottom: 1px solid $border-soft;
  display: flex;
  align-items: center;

  .tabs-list {
    display: flex;
    gap: 8px;

    .tab-item {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 8px 14px;
      background: rgba(255, 255, 255, 0.5);
      border: 1px solid $border-soft;
      border-radius: 10px;
      color: $text-muted;
      font-size: 13px;
      cursor: pointer;
      transition: all 0.2s $ease-out-back;

      &:hover {
        background: rgba(255, 255, 255, 0.8);
        border-color: $border-light;
        color: $glacier-primary;
        transform: translateY(-1px);
      }

      &.active {
        background: rgba(37, 99, 235, 0.1);
        border-color: rgba(37, 99, 235, 0.2);
        color: $glacier-primary;
        box-shadow: 0 2px 8px rgba(37, 99, 235, 0.1);
      }

      .close {
        font-size: 12px;
        opacity: 0;
        transform: scale(0.8);
        transition: all 0.2s $ease-out-back;

        &:hover {
          color: #ef4444;
          transform: scale(1.1);
        }
      }

      &:hover .close {
        opacity: 1;
        transform: scale(1);
      }
    }
  }
}

// ============================================
// 页面内容
// ============================================
.page-container {
  flex: 1;
  position: relative;
  overflow: hidden;
  background:
    radial-gradient(ellipse at 0% 0%, rgba(37, 99, 235, 0.03) 0%, transparent 50%),
    radial-gradient(ellipse at 100% 100%, rgba(6, 182, 212, 0.02) 0%, transparent 50%);

  // 默认内容区域带padding
  &:not(:has(> .space-manage-2-5d)) {
    padding: 20px 24px;
    overflow-y: auto;
  }

  // 3D车位管理页面全屏显示，无滚动
  &:has(> .space-manage-2-5d) {
    padding: 0;
    overflow: hidden;
  }
}

// ============================================
// 动画关键帧
// ============================================
@keyframes pulse-badge {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

// ============================================
// 页面过渡动画
// ============================================
.page-fade-enter-active,
.page-fade-leave-active {
  transition: all 0.3s $ease-in-out-smooth;
}

.page-fade-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.page-fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

// ============================================
// 滚动条样式
// ============================================
::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-track {
  background: transparent;
}

::-webkit-scrollbar-thumb {
  background: rgba(37, 99, 235, 0.2);
  border-radius: 3px;

  &:hover {
    background: rgba(37, 99, 235, 0.35);
  }
}

// ============================================
// 响应式
// ============================================
@media (max-width: 1024px) {
  .glacier-layout {
    .sidebar {
      transform: translateX(-100%);
      transition: transform $transition-duration $ease-out-expo, width $transition-duration $ease-out-expo;
    }

    &.sidebar-collapsed .sidebar {
      transform: translateX(0);
    }

    .main-content {
      margin-left: 0;
    }
  }
}
</style>

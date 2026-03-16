<template>
  <div class="layout-wrapper" :class="{ 'sidebar-collapsed': isCollapsed }">
    <!-- 侧边栏 -->
    <aside class="sidebar">
      <div class="sidebar-header">
        <div class="logo">
          <div class="logo-icon">
            <el-icon size="28"><Car /></el-icon>
          </div>
          <span v-show="!isCollapsed" class="logo-text">SmartPark</span>
        </div>
        <button class="collapse-btn" @click="toggleSidebar">
          <el-icon><Fold v-if="!isCollapsed" /><Expand v-else /></el-icon>
        </button>
      </div>

      <div class="sidebar-menu">
        <div class="menu-section">
          <div class="menu-title" v-show="!isCollapsed">主菜单</div>
          <nav class="menu-list">
            <router-link
              v-for="item in menuItems"
              :key="item.path"
              :to="item.path"
              class="menu-item"
              :class="{ active: $route.path === item.path }"
            >
              <div class="menu-icon">
                <el-icon size="20"><component :is="item.icon" /></el-icon>
              </div>
              <span v-show="!isCollapsed" class="menu-text">{{ item.title }}</span>
              <div v-show="!isCollapsed && item.badge" class="menu-badge">{{ item.badge }}</div>
            </router-link>
          </nav>
        </div>
      </div>

      <div class="sidebar-footer">
        <div class="user-card">
          <div class="user-avatar">
            {{ userStore.username?.charAt(0).toUpperCase() }}
          </div>
          <div v-show="!isCollapsed" class="user-info">
            <div class="user-name">{{ userStore.username }}</div>
            <div class="user-role">管理员</div>
          </div>
          <el-dropdown v-show="!isCollapsed" @command="handleCommand">
            <el-icon class="more-icon"><More /></el-icon>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon> 个人中心
                </el-dropdown-item>
                <el-dropdown-item command="settings">
                  <el-icon><Setting /></el-icon> 系统设置
                </el-dropdown-item>
                <el-dropdown-item divided command="logout">
                  <el-icon><SwitchButton /></el-icon> 退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </aside>

    <!-- 主内容区 -->
    <main class="main-content">
      <!-- 顶部导航 -->
      <header class="top-header">
        <div class="header-left">
          <breadcrumb class="custom-breadcrumb" />
        </div>

        <div class="header-right">
          <div class="header-actions">
            <!-- 搜索 -->
            <div class="search-box" :class="{ expanded: searchExpanded }">
              <el-icon class="search-icon" @click="searchExpanded = !searchExpanded"
                ><Search /></el-icon>
              <el-input
                v-show="searchExpanded"
                v-model="searchQuery"
                placeholder="搜索..."
                size="small"
                clearable
              />
            </div>

            <!-- 通知 -->
            <el-badge :value="3" class="action-btn">
              <el-icon size="20"><Bell /></el-icon>
            </el-badge>

            <!-- 全屏 -->
            <div class="action-btn" @click="toggleFullscreen">
              <el-icon size="20"><FullScreen /></el-icon>
            </div>

            <!-- 主题切换 -->
            <div class="action-btn" @click="toggleTheme">
              <el-icon size="20"><Sunny v-if="isDark" /><Moon v-else /></el-icon>
            </div>
          </div>
        </div>
      </header>

      <!-- 页面内容 -->
      <div class="page-container">
        <router-view v-slot="{ Component }">
          <transition name="page" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
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

const menuItems = [
  { path: '/dashboard', title: '数据大屏', icon: 'Odometer', badge: null },
  { path: '/parking', title: '停车管理', icon: 'OfficeBuilding', badge: null },
  { path: '/records', title: '停车记录', icon: 'Document', badge: null },
  { path: '/spaces', title: '车位管理', icon: 'MapLocation', badge: 12 },
  { path: '/users', title: '用户管理', icon: 'User', badge: null },
  { path: '/simulation', title: '仿真系统', icon: 'VideoCamera', badge: null },
  { path: '/settings', title: '系统设置', icon: 'Setting', badge: null }
]

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

const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'settings':
      router.push('/settings')
      break
    case 'logout':
      ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        userStore.logout()
        ElMessage.success('已退出登录')
        router.push('/login')
      })
      break
  }
}

// 恢复侧边栏状态
const savedCollapsed = localStorage.getItem('sidebar-collapsed')
if (savedCollapsed) {
  isCollapsed.value = savedCollapsed === 'true'
}
</script>

<style scoped lang="scss">
.layout-wrapper {
  display: flex;
  height: 100vh;
  background: #f1f5f9;

  &.sidebar-collapsed {
    .sidebar {
      width: 72px;

      .sidebar-header {
        justify-content: center;

        .collapse-btn {
          position: absolute;
          right: -12px;
          top: 50%;
          transform: translateY(-50%);
        }
      }
    }

    .main-content {
      margin-left: 72px;
    }
  }
}

// 侧边栏
.sidebar {
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  width: 260px;
  background: #ffffff;
  border-right: 1px solid #e2e8f0;
  display: flex;
  flex-direction: column;
  z-index: 100;
  transition: width 0.3s ease;

  .sidebar-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px;
    border-bottom: 1px solid #f1f5f9;
    position: relative;

    .logo {
      display: flex;
      align-items: center;
      gap: 12px;

      .logo-icon {
        width: 44px;
        height: 44px;
        background: linear-gradient(135deg, #2563eb, #1d4ed8);
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        flex-shrink: 0;
      }

      .logo-text {
        font-size: 22px;
        font-weight: 700;
        background: linear-gradient(135deg, #1e293b, #475569);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        white-space: nowrap;
      }
    }

    .collapse-btn {
      width: 28px;
      height: 28px;
      border: none;
      background: #f1f5f9;
      border-radius: 6px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #64748b;
      transition: all 0.3s ease;

      &:hover {
        background: #e2e8f0;
        color: #1e293b;
      }
    }
  }

  .sidebar-menu {
    flex: 1;
    overflow-y: auto;
    padding: 16px 12px;

    .menu-section {
      margin-bottom: 24px;

      .menu-title {
        padding: 0 12px;
        margin-bottom: 8px;
        font-size: 12px;
        font-weight: 600;
        color: #94a3b8;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }

      .menu-list {
        display: flex;
        flex-direction: column;
        gap: 4px;

        .menu-item {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 12px 16px;
          border-radius: 12px;
          color: #64748b;
          text-decoration: none;
          transition: all 0.3s ease;
          position: relative;
          overflow: hidden;

          &::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 3px;
            background: linear-gradient(180deg, #2563eb, #1d4ed8);
            transform: scaleY(0);
            transition: transform 0.3s ease;
          }

          &:hover {
            background: #f8fafc;
            color: #1e293b;
          }

          &.active {
            background: linear-gradient(135deg, rgba(37, 99, 235, 0.1), rgba(37, 99, 235, 0.05));
            color: #2563eb;

            &::before {
              transform: scaleY(1);
            }

            .menu-icon {
              background: linear-gradient(135deg, #2563eb, #1d4ed8);
              color: white;
            }
          }

          .menu-icon {
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
            background: #f1f5f9;
            transition: all 0.3s ease;
            flex-shrink: 0;
          }

          .menu-text {
            font-size: 15px;
            font-weight: 500;
            white-space: nowrap;
          }

          .menu-badge {
            margin-left: auto;
            padding: 2px 8px;
            background: #ef4444;
            color: white;
            font-size: 12px;
            font-weight: 600;
            border-radius: 20px;
          }
        }
      }
    }
  }

  .sidebar-footer {
    padding: 16px;
    border-top: 1px solid #f1f5f9;

    .user-card {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px;
      background: #f8fafc;
      border-radius: 12px;

      .user-avatar {
        width: 40px;
        height: 40px;
        background: linear-gradient(135deg, #2563eb, #1d4ed8);
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: 600;
        font-size: 16px;
        flex-shrink: 0;
      }

      .user-info {
        flex: 1;
        min-width: 0;

        .user-name {
          font-size: 14px;
          font-weight: 600;
          color: #1e293b;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .user-role {
          font-size: 12px;
          color: #94a3b8;
          margin-top: 2px;
        }
      }

      .more-icon {
        color: #94a3b8;
        cursor: pointer;
        padding: 4px;
        transition: color 0.3s ease;

        &:hover {
          color: #1e293b;
        }
      }
    }
  }
}

// 主内容区
.main-content {
  flex: 1;
  margin-left: 260px;
  display: flex;
  flex-direction: column;
  transition: margin-left 0.3s ease;

  .top-header {
    flex-shrink: 0;
    z-index: 50;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 24px;
    background: rgba(241, 245, 249, 0.9);
    backdrop-filter: blur(10px);
    border-bottom: 1px solid #e2e8f0;

    .header-left {
      .custom-breadcrumb {
        font-size: 14px;
      }
    }

    .header-right {
      .header-actions {
        display: flex;
        align-items: center;
        gap: 8px;

        .search-box {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 8px 12px;
          background: white;
          border-radius: 10px;
          border: 1px solid #e2e8f0;
          transition: all 0.3s ease;

          &:hover, &.expanded {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
          }

          .search-icon {
            color: #94a3b8;
            cursor: pointer;
          }

          :deep(.el-input__wrapper) {
            box-shadow: none;
            padding: 0;
          }
        }

        .action-btn {
          width: 40px;
          height: 40px;
          display: flex;
          align-items: center;
          justify-content: center;
          background: white;
          border-radius: 10px;
          border: 1px solid #e2e8f0;
          color: #64748b;
          cursor: pointer;
          transition: all 0.3s ease;

          &:hover {
            border-color: #2563eb;
            color: #2563eb;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);
          }
        }
      }
    }
  }

  .page-container {
    flex: 1;
    padding: 16px 24px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
}

// 页面过渡动画
.page-enter-active,
.page-leave-active {
  transition: all 0.3s ease;
}

.page-enter-from {
  opacity: 0;
  transform: translateY(20px);
}

.page-leave-to {
  opacity: 0;
  transform: translateY(-20px);
}
</style>
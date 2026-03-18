import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { public: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Register.vue'),
    meta: { public: true }
  },
  {
    path: '/forgot-password',
    name: 'ForgotPassword',
    component: () => import('@/views/ForgotPassword.vue'),
    meta: { public: true }
  },
  {
    path: '/',
    name: 'Layout',
    component: () => import('@/views/Layout.vue'),
    redirect: '/dashboard',
    children: [
      // 管理员路由
      {
        path: '/dashboard',
        name: 'Dashboard',
        component: () => import('@/views/admin/Dashboard.vue'),
        meta: { title: '数据大屏', icon: 'Odometer', adminOnly: true }
      },
      {
        path: '/records',
        name: 'Records',
        component: () => import('@/views/admin/RecordManage.vue'),
        meta: { title: '停车记录', icon: 'Document', adminOnly: true }
      },
      {
        path: '/spaces',
        name: 'Spaces',
        component: () => import('@/views/admin/SpaceManage.vue'),
        meta: { title: '车位管理', icon: 'MapLocation', adminOnly: true }
      },
      {
        path: '/simulation',
        name: 'Simulation',
        component: () => import('@/views/admin/Simulation.vue'),
        meta: { title: '仿真系统', icon: 'VideoCamera', adminOnly: true }
      },
      {
        path: '/settings',
        name: 'Settings',
        component: () => import('@/views/admin/Settings.vue'),
        meta: { title: '系统设置', icon: 'Setting', adminOnly: true }
      },
      // 普通用户路由
      {
        path: '/my-records',
        name: 'MyRecords',
        component: () => import('@/views/user/UserRecords.vue'),
        meta: { title: '我的停车记录', icon: 'Document', userOnly: true }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/views/NotFound.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()

  // 初始化用户状态（从localStorage读取）
  userStore.initUser()

  // 未登录检查
  if (!to.meta.public && !userStore.token) {
    next('/login')
    return
  }

  // 已登录但访问登录页，跳转到首页
  if (to.meta.public && userStore.token) {
    next(userStore.isAdmin ? '/dashboard' : '/my-records')
    return
  }

  // 权限检查 - 普通用户访问管理员页面时静默跳转
  if (to.meta.adminOnly && !userStore.isAdmin) {
    next('/my-records')
    return
  }

  if (to.meta.userOnly && userStore.isAdmin) {
    next('/dashboard')
    return
  }

  next()
})

export default router

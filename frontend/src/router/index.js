import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

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
    path: '/',
    name: 'Layout',
    component: () => import('@/views/Layout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: '/dashboard',
        name: 'Dashboard',
        component: () => import('@/views/admin/Dashboard.vue'),
        meta: { title: '数据大屏', icon: 'Odometer' }
      },
      {
        path: '/parking',
        name: 'Parking',
        component: () => import('@/views/admin/ParkingManage.vue'),
        meta: { title: '停车管理', icon: 'OfficeBuilding' }
      },
      {
        path: '/records',
        name: 'Records',
        component: () => import('@/views/admin/RecordManage.vue'),
        meta: { title: '停车记录', icon: 'Document' }
      },
      {
        path: '/spaces',
        name: 'Spaces',
        component: () => import('@/views/admin/SpaceManage.vue'),
        meta: { title: '车位管理', icon: 'MapLocation' }
      },
      {
        path: '/users',
        name: 'Users',
        component: () => import('@/views/admin/UserManage.vue'),
        meta: { title: '用户管理', icon: 'User' }
      },
      {
        path: '/simulation',
        name: 'Simulation',
        component: () => import('@/views/admin/Simulation.vue'),
        meta: { title: '仿真系统', icon: 'VideoCamera' }
      },
      {
        path: '/settings',
        name: 'Settings',
        component: () => import('@/views/admin/Settings.vue'),
        meta: { title: '系统设置', icon: 'Setting' }
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

  if (!to.meta.public && !userStore.token) {
    next('/login')
  } else {
    next()
  }
})

export default router

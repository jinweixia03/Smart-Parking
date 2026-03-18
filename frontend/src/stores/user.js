import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login, getUserInfo } from '@/api/auth'

export const useUserStore = defineStore('user', () => {
  // State
  const token = ref(localStorage.getItem('parking_token') || '')
  const user = ref(null)

  // Getters
  const isLoggedIn = computed(() => !!token.value)
  const username = computed(() => user.value?.username || '')
  const userId = computed(() => user.value?.userId || '')
  const avatar = computed(() => user.value?.avatar || '')

  /**
   * 用户类型: 1-管理员, 2-普通用户
   */
  const userType = computed(() => user.value?.userType || 2)

  /**
   * 是否为管理员
   */
  const isAdmin = computed(() => userType.value === 1)

  /**
   * 是否为普通用户
   */
  const isUser = computed(() => userType.value === 2)

  // Actions

  /**
   * 设置 token
   */
  const setToken = (newToken) => {
    token.value = newToken
    localStorage.setItem('parking_token', newToken)
  }

  /**
   * 设置用户信息
   */
  const setUser = (userData) => {
    user.value = userData
    localStorage.setItem('parking_user', JSON.stringify(userData))
  }

  /**
   * 清除用户信息
   */
  const clearUser = () => {
    token.value = ''
    user.value = null
    localStorage.removeItem('parking_token')
    localStorage.removeItem('parking_user')
  }

  /**
   * 登录
   */
  const loginAction = async (loginData) => {
    const res = await login(loginData)
    if (res.token) {
      setToken(res.token)
      setUser(res.user)
    }
    return res
  }

  /**
   * 获取用户信息
   */
  const fetchUserInfo = async () => {
    try {
      const res = await getUserInfo()
      setUser(res)
      return res
    } catch (error) {
      clearUser()
      throw error
    }
  }

  /**
   * 退出登录
   */
  const logout = () => {
    clearUser()
  }

  /**
   * 初始化用户状态
   */
  const initUser = () => {
    const savedToken = localStorage.getItem('parking_token')
    const savedUser = localStorage.getItem('parking_user')
    if (savedToken) {
      token.value = savedToken
    }
    if (savedUser) {
      try {
        user.value = JSON.parse(savedUser)
      } catch (e) {
        console.error('Failed to parse user data:', e)
      }
    }
  }

  return {
    // State
    token,
    user,
    // Getters
    isLoggedIn,
    username,
    userId,
    avatar,
    userType,
    isAdmin,
    isUser,
    // Actions
    setToken,
    setUser,
    clearUser,
    login: loginAction,
    fetchUserInfo,
    logout,
    initUser
  }
})

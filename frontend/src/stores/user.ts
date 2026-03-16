import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { login as loginApi, getUserInfo } from '@/api/auth'
import type { User, LoginForm } from '@/types/api'

export const useUserStore = defineStore('user', () => {
  // State
  const token = ref<string>(localStorage.getItem('token') || '')
  const userInfo = ref<User | null>(null)

  // Getters
  const isLoggedIn = computed(() => !!token.value)
  const username = computed(() => userInfo.value?.username || '')

  // Actions
  const login = async (loginForm: LoginForm) => {
    const res = await loginApi(loginForm)
    token.value = res.token
    userInfo.value = res.user
    localStorage.setItem('token', res.token)
    return res
  }

  const fetchUserInfo = async () => {
    const res = await getUserInfo()
    userInfo.value = res
    return res
  }

  const logout = () => {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem('token')
    window.location.href = '/login'
  }

  return {
    token,
    userInfo,
    isLoggedIn,
    username,
    login,
    fetchUserInfo,
    logout
  }
})

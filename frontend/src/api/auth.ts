import request from './request'
import type { LoginForm, LoginResponse, RegisterForm, User } from '@/types/api'

export const login = (data: LoginForm): Promise<LoginResponse> => {
  return request.post('/auth/login', data)
}

export const register = (data: RegisterForm): Promise<void> => {
  return request.post('/auth/register', data)
}

export const getUserInfo = (): Promise<User> => {
  return request.get('/user/info')
}

export const updateUserInfo = (data: Partial<User>): Promise<void> => {
  return request.put('/user/info', data)
}

export const changePassword = (data: { oldPassword: string; newPassword: string }): Promise<void> => {
  return request.put('/user/password', null, { params: data })
}

import request from './request'

/**
 * 用户注册
 * @param {Object} data - 注册信息
 * @param {string} data.username - 用户名
 * @param {string} data.password - 密码
 * @param {string} data.phone - 手机号
 * @param {number} [data.userType] - 用户类型: 1-管理员 2-普通用户，默认为2
 */
export const register = (data) => {
  return request.post('/auth/register', data)
}

/**
 * 用户登录
 * @param {Object} data - 登录信息
 * @param {string} data.username - 用户名
 * @param {string} data.password - 密码
 */
export const login = (data) => {
  return request.post('/auth/login', data)
}

/**
 * 获取验证码
 */
export const getCaptcha = () => {
  return request.get('/auth/captcha')
}

/**
 * 获取当前登录用户信息
 */
export const getUserInfo = () => {
  return request.get('/user/info')
}

/**
 * 更新用户信息
 * @param {Object} data - 用户信息
 */
export const updateUserInfo = (data) => {
  return request.put('/user/info', data)
}

/**
 * 修改密码
 * @param {Object} data - 密码信息
 * @param {string} data.oldPassword - 原密码
 * @param {string} data.newPassword - 新密码
 */
export const changePassword = (data) => {
  return request.put('/user/password', data)
}

/**
 * 退出登录
 */
export const logout = () => {
  return request.post('/auth/logout')
}

/**
 * 忘记密码 - 通过用户名和手机号重置密码
 * @param {Object} data - 重置信息
 * @param {string} data.username - 用户名
 * @param {string} data.phone - 手机号
 * @param {string} data.newPassword - 新密码
 */
export const forgotPassword = (data) => {
  return request.post('/auth/forgot-password', null, {
    params: {
      username: data.username,
      phone: data.phone,
      newPassword: data.newPassword
    }
  })
}

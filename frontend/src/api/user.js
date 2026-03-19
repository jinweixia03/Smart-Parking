import request from '@/api/request'

/**
 * 获取当前用户信息
 */
export const getCurrentUser = () => {
  return request.get('/user/info')
}

/**
 * 更新当前用户信息
 * @param {Object} data - 用户信息
 */
export const updateUserInfo = (data) => {
  return request.put('/user/info', data)
}

/**
 * 修改当前用户密码
 * @param {Object} params - 密码参数
 * @param {string} params.oldPassword - 原密码
 * @param {string} params.newPassword - 新密码
 */
export const changePassword = (params) => {
  return request.put('/user/password', null, { params })
}

/**
 * 分页查询用户（管理员）
 * @param {Object} params - 查询参数
 * @param {number} params.page - 页码
 * @param {number} params.size - 每页条数
 * @param {string} params.keyword - 关键词
 * @param {number} params.userType - 用户类型
 */
export const pageUsers = (params) => {
  return request.get('/user/page', { params })
}

/**
 * 获取用户列表（管理员）
 */
export const listUsers = () => {
  return request.get('/user/list')
}

/**
 * 获取用户详情（管理员）
 * @param {number} userId - 用户ID
 */
export const getUserById = (userId) => {
  return request.get(`/user/${userId}`)
}

/**
 * 更新用户信息（管理员）
 * @param {number} userId - 用户ID
 * @param {Object} data - 用户信息
 */
export const updateUser = (userId, data) => {
  return request.put(`/user/${userId}`, data)
}

/**
 * 重置密码（管理员）
 * @param {number} userId - 用户ID
 * @param {string} newPassword - 新密码
 */
export const resetPassword = (userId, newPassword) => {
  return request.put(`/user/${userId}/reset-password`, null, {
    params: { newPassword }
  })
}

/**
 * 切换用户状态（管理员）
 * @param {number} userId - 用户ID
 */
export const toggleUserStatus = (userId) => {
  return request.put(`/user/${userId}/toggle-status`)
}

/**
 * 删除用户（管理员）
 * @param {number} userId - 用户ID
 */
export const deleteUser = (userId) => {
  return request.delete(`/user/${userId}`)
}

/**
 * 统计用户数量（管理员）
 */
export const countUsers = () => {
  return request.get('/user/count')
}

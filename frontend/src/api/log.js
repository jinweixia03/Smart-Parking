import request from '@/api/request'

/**
 * 分页查询操作日志（管理员）
 * @param {Object} params - 查询参数
 * @param {number} params.page - 页码
 * @param {number} params.size - 每页条数
 * @param {string} params.module - 模块
 * @param {number} params.status - 状态
 */
export const pageLogs = (params) => {
  return request.get('/log/page', { params })
}

/**
 * 清理日志（管理员）
 * @param {number} days - 清理多少天前的日志，默认30天
 */
export const cleanLogs = (days = 30) => {
  return request.delete('/log/clean', { params: { days } })
}

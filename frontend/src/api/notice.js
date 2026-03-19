import request from '@/api/request'

/**
 * 获取公告列表（公开）
 */
export const getNotices = () => {
  return request.get('/notice/list')
}

/**
 * 获取置顶公告（公开）
 */
export const getTopNotices = () => {
  return request.get('/notice/top')
}

/**
 * 获取公告详情
 * @param {number} noticeId - 公告ID
 */
export const getNoticeById = (noticeId) => {
  return request.get(`/notice/${noticeId}`)
}

/**
 * 分页查询公告（管理员）
 * @param {Object} params - 查询参数
 * @param {number} params.page - 页码
 * @param {number} params.size - 每页条数
 * @param {string} params.keyword - 关键词
 * @param {number} params.status - 状态
 */
export const pageNotices = (params) => {
  return request.get('/notice/page', { params })
}

/**
 * 新增公告（管理员）
 * @param {Object} data - 公告数据
 * @param {string} data.title - 标题
 * @param {string} data.content - 内容
 * @param {number} data.noticeType - 类型
 * @param {number} data.isTop - 是否置顶
 */
export const createNotice = (data) => {
  return request.post('/notice', data)
}

/**
 * 更新公告（管理员）
 * @param {number} noticeId - 公告ID
 * @param {Object} data - 公告数据
 */
export const updateNotice = (noticeId, data) => {
  return request.put(`/notice/${noticeId}`, data)
}

/**
 * 删除公告（管理员）
 * @param {number} noticeId - 公告ID
 */
export const deleteNotice = (noticeId) => {
  return request.delete(`/notice/${noticeId}`)
}

/**
 * 切换公告状态（管理员）
 * @param {number} noticeId - 公告ID
 */
export const toggleNoticeStatus = (noticeId) => {
  return request.put(`/notice/${noticeId}/toggle-status`)
}

/**
 * 切换公告置顶（管理员）
 * @param {number} noticeId - 公告ID
 */
export const toggleNoticeTop = (noticeId) => {
  return request.put(`/notice/${noticeId}/toggle-top`)
}

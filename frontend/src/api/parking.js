import request from '@/api/request'

export const getRealTimeData = () => {
  return request.get('/parking/realtime')
}

export const getTodayStats = () => {
  return request.get('/parking/stats/today')
}

export const getChartData = (type, params) => {
  return request.get('/parking/chart', { params: { type, ...params } })
}

/**
 * 车辆入场（支持图片上传）
 * @param {string} plateNumber - 车牌号
 * @param {File} image - 入场图片（可选）
 */
export const entry = (plateNumber, image = null) => {
  const formData = new FormData()
  formData.append('plateNumber', plateNumber)
  if (image) {
    formData.append('image', image)
  }
  return request.post('/parking/entry', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

/**
 * 上传入场图片到指定记录
 * @param {number} recordId - 记录ID
 * @param {File} image - 图片文件
 */
export const uploadEntryImage = (recordId, image) => {
  const formData = new FormData()
  formData.append('image', image)
  return request.post(`/parking/${recordId}/entry-image`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

/**
 * 车辆出场（支持图片上传）
 * @param {string} plateNumber - 车牌号
 * @param {File} image - 出场图片（可选）
 */
export const exit = (plateNumber, image = null) => {
  const formData = new FormData()
  formData.append('plateNumber', plateNumber)
  if (image) {
    formData.append('image', image)
  }
  return request.post('/parking/exit', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

/**
 * 上传出场图片到指定记录
 * @param {number} recordId - 记录ID
 * @param {File} image - 图片文件
 */
export const uploadExitImage = (recordId, image) => {
  const formData = new FormData()
  formData.append('image', image)
  return request.post(`/parking/${recordId}/exit-image`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export const pay = (recordId) => {
  return request.post(`/parking/pay/${recordId}`)
}

export const getRecords = (params) => {
  return request.get('/parking/records', { params })
}

export const getCurrentParking = (plateNumber) => {
  return request.get(`/parking/current/${plateNumber}`)
}

export const getAreas = () => {
  return request.get('/parking/areas')
}

export const getSpaces = (areaId) => {
  return request.get('/parking/spaces', { params: { areaId } })
}

/**
 * 根据车牌号查询停车记录（普通用户）
 * @param {string} plateNumber - 车牌号
 */
export const getRecordsByPlate = (plateNumber) => {
  return request.get(`/parking/records/by-plate/${plateNumber}`)
}

/**
 * 获取车辆详情（包括识别图片和最近停车记录）
 * @param {string} plateNumber - 车牌号
 */
export const getVehicleDetail = (plateNumber) => {
  return request.get(`/parking/vehicle/detail/${plateNumber}`)
}

/**
 * 支付停车费用
 * @param {number} recordId - 记录ID
 */
export const payRecord = (recordId) => {
  return request.post(`/parking/pay/${recordId}`)
}

/**
 * 创建支付订单（模拟微信/支付宝下单）
 */
export const createPayOrder = (recordId, payMethod) => {
  return request.post('/parking/pay/create-order', null, {
    params: { recordId, payMethod }
  })
}

/**
 * 查询支付订单状态
 */
export const queryPayOrder = (orderId) => {
  return request.get(`/parking/pay/query-order/${orderId}`)
}

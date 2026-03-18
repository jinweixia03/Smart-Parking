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

export const entry = (plateNumber) => {
  return request.post('/parking/entry', null, { params: { plateNumber } })
}

export const exit = (plateNumber) => {
  return request.post('/parking/exit', null, { params: { plateNumber } })
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

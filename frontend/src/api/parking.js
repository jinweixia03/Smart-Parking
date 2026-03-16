import request from './request'

export const getRealTimeData = () => {
  return request.get('/parking/realtime')
}

export const getTodayStats = () => {
  return request.get('/parking/stats/today')
}

export const getChartData = (type, params) => {
  return request.get('/parking/chart', { params: { type, ...params } })
}

export const entry = (plateNumber, gate = 'A1') => {
  return request.post('/parking/entry', null, { params: { plateNumber, gate } })
}

export const exit = (plateNumber, gate = 'A1') => {
  return request.post('/parking/exit', null, { params: { plateNumber, gate } })
}

export const pay = (recordId, payMethod = '微信支付') => {
  return request.post(`/parking/pay/${recordId}`, null, { params: { payMethod } })
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

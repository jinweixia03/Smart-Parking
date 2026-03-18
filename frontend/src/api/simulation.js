import request from '@/api/request'

export const startSimulation = (data) => {
  return request.post('/simulation/start', data)
}

export const generatePlates = (count = 10) => {
  return request.get('/simulation/plates', { params: { count } })
}

export const getSimulationStats = () => {
  return request.get('/simulation/stats')
}

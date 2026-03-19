import request from '@/api/request'

/**
 * 检测车牌位置
 * @param {File} image - 图片文件
 */
export const detectPlate = (image) => {
  const formData = new FormData()
  formData.append('image', image)
  return request.post('/algorithm/detect', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

/**
 * 识别车牌号码
 * @param {File} image - 图片文件
 */
export const recognizePlate = (image) => {
  const formData = new FormData()
  formData.append('image', image)
  return request.post('/algorithm/recognize', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
    timeout: 120000  // 模型推理可能较慢，给2分钟
  })
}

/**
 * 入场识别（检测+识别）
 * @param {File} image - 入场图片
 */
export const entryRecognize = (image) => {
  const formData = new FormData()
  formData.append('image', image)
  return request.post('/algorithm/entry', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

/**
 * 出场识别（检测+识别）
 * @param {File} image - 出场图片
 * @param {string} plateNumber - 预期车牌号（可选）
 */
export const exitRecognize = (image, plateNumber = null) => {
  const formData = new FormData()
  formData.append('image', image)
  if (plateNumber) {
    formData.append('plateNumber', plateNumber)
  }
  return request.post('/algorithm/exit', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

/**
 * 获取算法模型信息
 */
export const getModelInfo = () => {
  return request.get('/algorithm/model-info')
}

/**
 * 算法服务健康检查
 */
export const checkHealth = () => {
  return request.get('/algorithm/health')
}

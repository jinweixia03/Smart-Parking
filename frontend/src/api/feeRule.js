import request from '@/api/request'

/**
 * 获取所有收费规则（管理员）
 */
export const listFeeRules = () => {
  return request.get('/fee-rule/list')
}

/**
 * 获取默认收费规则
 */
export const getDefaultFeeRule = () => {
  return request.get('/fee-rule/default')
}

/**
 * 获取收费规则详情（管理员）
 * @param {number} ruleId - 规则ID
 */
export const getFeeRuleById = (ruleId) => {
  return request.get(`/fee-rule/${ruleId}`)
}

/**
 * 新增收费规则（管理员）
 * @param {Object} data - 规则数据
 * @param {string} data.ruleName - 规则名称
 * @param {number} data.freeMinutes - 免费时长(分钟)
 * @param {number} data.firstHourFee - 首小时费用
 * @param {number} data.extraHourFee - 超出费用(元/时)
 * @param {number} data.dailyMaxFee - 24小时封顶
 */
export const createFeeRule = (data) => {
  return request.post('/fee-rule', data)
}

/**
 * 更新收费规则（管理员）
 * @param {number} ruleId - 规则ID
 * @param {Object} data - 规则数据
 */
export const updateFeeRule = (ruleId, data) => {
  return request.put(`/fee-rule/${ruleId}`, data)
}

/**
 * 删除收费规则（管理员）
 * @param {number} ruleId - 规则ID
 */
export const deleteFeeRule = (ruleId) => {
  return request.delete(`/fee-rule/${ruleId}`)
}

/**
 * 设置默认规则（管理员）
 * @param {number} ruleId - 规则ID
 */
export const setDefaultFeeRule = (ruleId) => {
  return request.put(`/fee-rule/${ruleId}/set-default`)
}

/**
 * 测试费用计算（管理员）
 * @param {number} ruleId - 规则ID
 * @param {number} minutes - 停车分钟数
 */
export const calculateFee = (ruleId, minutes) => {
  return request.get('/fee-rule/calculate', {
    params: { ruleId, minutes }
  })
}

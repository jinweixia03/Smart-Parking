package com.parking.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.parking.entity.FeeRule;

import java.math.BigDecimal;

/**
 * 收费规则Service接口
 */
public interface FeeRuleService extends IService<FeeRule> {

    /**
     * 获取默认收费规则
     */
    FeeRule getDefaultRule();

    /**
     * 计算停车费用
     */
    BigDecimal calculateFee(Long ruleId, long parkingMinutes);

    /**
     * 设置默认规则
     */
    void setDefaultRule(Long ruleId);
}

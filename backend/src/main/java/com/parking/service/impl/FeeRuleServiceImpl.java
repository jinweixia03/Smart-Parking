package com.parking.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.parking.entity.FeeRule;
import com.parking.mapper.FeeRuleMapper;
import com.parking.service.FeeRuleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * 收费规则Service实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class FeeRuleServiceImpl extends ServiceImpl<FeeRuleMapper, FeeRule> implements FeeRuleService {

    @Override
    public FeeRule getDefaultRule() {
        LambdaQueryWrapper<FeeRule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(FeeRule::getIsDefault, 1)
               .eq(FeeRule::getStatus, 1)
               .last("LIMIT 1");
        FeeRule rule = baseMapper.selectOne(wrapper);

        // 如果没有默认规则，返回第一条启用的规则
        if (rule == null) {
            wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(FeeRule::getStatus, 1)
                   .last("LIMIT 1");
            rule = baseMapper.selectOne(wrapper);
        }

        // 如果还没有，创建一个默认规则
        if (rule == null) {
            rule = createDefaultRule();
        }

        return rule;
    }

    @Override
    public BigDecimal calculateFee(Long ruleId, long parkingMinutes) {
        FeeRule rule;
        if (ruleId != null) {
            rule = getById(ruleId);
        } else {
            rule = getDefaultRule();
        }

        if (rule == null) {
            return BigDecimal.ZERO;
        }

        // 免费时长内
        if (parkingMinutes <= rule.getFreeMinutes()) {
            return BigDecimal.ZERO;
        }

        // 减去免费时长
        long chargeMinutes = parkingMinutes - rule.getFreeMinutes();

        // 计算费用
        BigDecimal fee;
        if (chargeMinutes <= 60) {
            // 首小时费用
            fee = rule.getFirstHourFee();
        } else {
            // 首小时 + 超出部分
            fee = rule.getFirstHourFee();
            long extraHours = (chargeMinutes - 60 + 59) / 60; // 向上取整
            BigDecimal extraFee = rule.getExtraHourFee().multiply(BigDecimal.valueOf(extraHours));
            fee = fee.add(extraFee);
        }

        // 24小时封顶
        if (fee.compareTo(rule.getDailyMaxFee()) > 0) {
            fee = rule.getDailyMaxFee();
        }

        return fee.setScale(2, RoundingMode.HALF_UP);
    }

    @Override
    public void setDefaultRule(Long ruleId) {
        // 取消所有默认规则
        LambdaQueryWrapper<FeeRule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(FeeRule::getIsDefault, 1);
        FeeRule oldDefault = new FeeRule();
        oldDefault.setIsDefault(0);
        baseMapper.update(oldDefault, wrapper);

        // 设置新的默认规则
        FeeRule newDefault = new FeeRule();
        newDefault.setRuleId(ruleId);
        newDefault.setIsDefault(1);
        baseMapper.updateById(newDefault);

        log.info("设置默认收费规则: ruleId={}", ruleId);
    }

    /**
     * 创建默认收费规则
     */
    private FeeRule createDefaultRule() {
        FeeRule rule = new FeeRule();
        rule.setRuleName("默认规则");
        rule.setFreeMinutes(15);
        rule.setFirstHourFee(new BigDecimal("5.00"));
        rule.setExtraHourFee(new BigDecimal("3.00"));
        rule.setDailyMaxFee(new BigDecimal("50.00"));
        rule.setIsDefault(1);
        rule.setStatus(1);

        baseMapper.insert(rule);
        log.info("创建默认收费规则");
        return rule;
    }
}

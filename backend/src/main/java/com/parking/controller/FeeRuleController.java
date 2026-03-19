package com.parking.controller;

import com.parking.entity.FeeRule;
import com.parking.entity.SysUser;
import com.parking.service.FeeRuleService;
import com.parking.service.SysUserService;
import com.parking.vo.Result;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

/**
 * 收费规则Controller
 */
@Slf4j
@RestController
@RequestMapping("/fee-rule")
@RequiredArgsConstructor
@CrossOrigin
public class FeeRuleController {

    private final FeeRuleService feeRuleService;
    private final SysUserService userService;

    /**
     * 获取所有收费规则（管理员）
     */
    @GetMapping("/list")
    public Result<List<FeeRule>> list(HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }
        List<FeeRule> list = feeRuleService.list();
        return Result.success(list);
    }

    /**
     * 获取默认收费规则
     */
    @GetMapping("/default")
    public Result<FeeRule> getDefault() {
        FeeRule rule = feeRuleService.getDefaultRule();
        return Result.success(rule);
    }

    /**
     * 获取收费规则详情
     */
    @GetMapping("/{ruleId}")
    public Result<FeeRule> getById(@PathVariable Long ruleId, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }
        FeeRule rule = feeRuleService.getById(ruleId);
        return Result.success(rule);
    }

    /**
     * 新增收费规则（管理员）
     */
    @PostMapping
    public Result<Void> save(@RequestBody FeeRule rule, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以操作");
        }

        if (!StringUtils.hasText(rule.getRuleName())) {
            return Result.error("规则名称不能为空");
        }

        // 设置默认值
        if (rule.getFreeMinutes() == null) {
            rule.setFreeMinutes(15);
        }
        if (rule.getFirstHourFee() == null) {
            rule.setFirstHourFee(new BigDecimal("5.00"));
        }
        if (rule.getExtraHourFee() == null) {
            rule.setExtraHourFee(new BigDecimal("3.00"));
        }
        if (rule.getDailyMaxFee() == null) {
            rule.setDailyMaxFee(new BigDecimal("50.00"));
        }
        if (rule.getStatus() == null) {
            rule.setStatus(1);
        }
        if (rule.getIsDefault() == null) {
            rule.setIsDefault(0);
        }

        feeRuleService.save(rule);
        log.info("新增收费规则: ruleId={}, name={}", rule.getRuleId(), rule.getRuleName());
        return Result.success();
    }

    /**
     * 更新收费规则（管理员）
     */
    @PutMapping("/{ruleId}")
    public Result<Void> update(@PathVariable Long ruleId,
                               @RequestBody FeeRule rule,
                               HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以操作");
        }

        FeeRule existing = feeRuleService.getById(ruleId);
        if (existing == null) {
            return Result.error("规则不存在");
        }

        rule.setRuleId(ruleId);
        feeRuleService.updateById(rule);
        log.info("更新收费规则: ruleId={}", ruleId);
        return Result.success();
    }

    /**
     * 删除收费规则（管理员）
     */
    @DeleteMapping("/{ruleId}")
    public Result<Void> delete(@PathVariable Long ruleId, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以操作");
        }

        FeeRule existing = feeRuleService.getById(ruleId);
        if (existing == null) {
            return Result.error("规则不存在");
        }

        // 不能删除默认规则
        if (existing.getIsDefault() != null && existing.getIsDefault() == 1) {
            return Result.error("不能删除默认规则");
        }

        feeRuleService.removeById(ruleId);
        log.info("删除收费规则: ruleId={}", ruleId);
        return Result.success();
    }

    /**
     * 设置默认规则（管理员）
     */
    @PutMapping("/{ruleId}/set-default")
    public Result<Void> setDefault(@PathVariable Long ruleId, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以操作");
        }

        FeeRule existing = feeRuleService.getById(ruleId);
        if (existing == null) {
            return Result.error("规则不存在");
        }

        feeRuleService.setDefaultRule(ruleId);
        return Result.success();
    }

    /**
     * 测试费用计算（管理员）
     */
    @GetMapping("/calculate")
    public Result<BigDecimal> calculate(
            @RequestParam Long ruleId,
            @RequestParam long minutes,
            HttpServletRequest request) {

        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }

        BigDecimal fee = feeRuleService.calculateFee(ruleId, minutes);
        return Result.success(fee);
    }

    /**
     * 检查当前用户是否为管理员
     */
    private boolean isAdmin(HttpServletRequest request) {
        Object userIdObj = request.getAttribute("userId");
        if (userIdObj == null) {
            return false;
        }
        try {
            Long userId = Long.valueOf(userIdObj.toString());
            SysUser user = userService.getById(userId);
            return user != null && user.getUserType() != null && user.getUserType() == 1;
        } catch (Exception e) {
            return false;
        }
    }
}

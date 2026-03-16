package com.parking.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 收费规则实体类
 */
@Data
@TableName("fee_rule")
public class FeeRule implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "rule_id", type = IdType.AUTO)
    private Long ruleId;

    private String ruleName;

    private Integer freeMinutes;

    private BigDecimal firstHourFee;

    private BigDecimal extraHourFee;

    private BigDecimal dailyMaxFee;

    private Integer isDefault;

    private Integer status;
}

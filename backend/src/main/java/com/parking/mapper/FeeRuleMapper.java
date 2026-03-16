package com.parking.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.parking.entity.FeeRule;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 收费规则Mapper
 */
@Mapper
public interface FeeRuleMapper extends BaseMapper<FeeRule> {

    @Select("SELECT * FROM fee_rule WHERE is_default = 1 AND status = 1 LIMIT 1")
    FeeRule selectDefault();

    @Select("SELECT * FROM fee_rule WHERE status = 1")
    List<FeeRule> selectAllActive();
}

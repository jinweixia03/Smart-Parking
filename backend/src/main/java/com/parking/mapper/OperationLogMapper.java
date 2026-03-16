package com.parking.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.parking.entity.OperationLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 操作日志Mapper
 */
@Mapper
public interface OperationLogMapper extends BaseMapper<OperationLog> {

    @Select("SELECT * FROM operation_log ORDER BY create_time DESC LIMIT #{limit}")
    List<OperationLog> selectLatest(int limit);
}

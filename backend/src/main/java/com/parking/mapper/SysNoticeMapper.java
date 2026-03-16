package com.parking.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.parking.entity.SysNotice;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 公告Mapper
 */
@Mapper
public interface SysNoticeMapper extends BaseMapper<SysNotice> {

    @Select("SELECT * FROM sys_notice WHERE status = 1 ORDER BY is_top DESC, create_time DESC LIMIT #{limit}")
    List<SysNotice> selectLatest(int limit);

    @Select("SELECT * FROM sys_notice WHERE status = 1 ORDER BY is_top DESC, create_time DESC")
    List<SysNotice> selectAllActive();
}

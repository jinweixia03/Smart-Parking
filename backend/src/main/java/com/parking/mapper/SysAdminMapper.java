package com.parking.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.parking.entity.SysAdmin;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

/**
 * 管理员Mapper
 */
@Mapper
public interface SysAdminMapper extends BaseMapper<SysAdmin> {

    @Select("SELECT * FROM sys_admin WHERE username = #{username} AND status = 1")
    SysAdmin selectByUsername(String username);

    @Update("UPDATE sys_admin SET last_login_time = NOW() WHERE admin_id = #{adminId}")
    void updateLoginTime(@Param("adminId") Long adminId);
}

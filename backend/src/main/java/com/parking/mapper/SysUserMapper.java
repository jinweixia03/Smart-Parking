package com.parking.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.parking.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

/**
 * 用户Mapper
 */
@Mapper
public interface SysUserMapper extends BaseMapper<SysUser> {

    @Select("SELECT * FROM sys_user WHERE username = #{username} AND status = 1")
    SysUser selectByUsername(String username);

    @Select("SELECT * FROM sys_user WHERE phone = #{phone} AND status = 1")
    SysUser selectByPhone(String phone);

    @Update("UPDATE sys_user SET last_login_time = NOW(), last_login_ip = #{ip} WHERE user_id = #{userId}")
    void updateLoginInfo(@Param("userId") Long userId, @Param("ip") String ip);
}

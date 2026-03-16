package com.parking.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.parking.entity.SysUser;
import com.parking.vo.LoginVO;
import com.parking.vo.RegisterVO;
import com.parking.vo.UserVO;

import java.util.Map;

/**
 * 用户Service接口
 */
public interface SysUserService extends IService<SysUser> {

    /**
     * 用户注册
     */
    SysUser register(RegisterVO registerVO);

    /**
     * 用户登录
     */
    Map<String, Object> login(LoginVO loginVO, String ip);

    /**
     * 获取用户信息
     */
    UserVO getUserInfo(Long userId);

    /**
     * 更新用户信息
     */
    void updateUserInfo(Long userId, UserVO userVO);

    /**
     * 修改密码
     */
    void changePassword(Long userId, String oldPassword, String newPassword);

    /**
     * 分页查询用户
     */
    Page<SysUser> pageUsers(Page<SysUser> page, String keyword, Integer status);
}

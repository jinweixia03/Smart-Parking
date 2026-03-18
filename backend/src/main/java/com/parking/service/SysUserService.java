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
     * @param userType 用户类型: 1-管理员 2-普通用户
     */
    Page<SysUser> pageUsers(Page<SysUser> page, String keyword, Integer status, Integer userType);

    /**
     * 根据用户名和手机号重置密码
     * @param username 用户名
     * @param phone 手机号
     * @param newPassword 新密码
     * @return 是否重置成功
     */
    boolean resetPasswordByPhone(String username, String phone, String newPassword);
}

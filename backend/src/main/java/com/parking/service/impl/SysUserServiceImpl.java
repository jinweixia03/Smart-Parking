package com.parking.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.parking.entity.SysUser;
import com.parking.mapper.SysUserMapper;
import com.parking.service.SysUserService;
import com.parking.utils.JwtUtil;
import com.parking.vo.LoginVO;
import com.parking.vo.RegisterVO;
import com.parking.vo.UserVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * 用户Service实现
 */
@Service
@RequiredArgsConstructor
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements SysUserService {

    private final SysUserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final BCryptPasswordEncoder passwordEncoder;

    @jakarta.annotation.PostConstruct
    public void init() {
        // 强制更新默认用户密码
        SysUser admin = userMapper.selectByUsername("admin");
        if (admin != null) {
            String newPwd = passwordEncoder.encode("admin123");
            System.out.println("[INIT] Updating admin password to: " + newPwd);
            admin.setPassword(newPwd);
            userMapper.updateById(admin);
        }
        SysUser operator = userMapper.selectByUsername("operator");
        if (operator != null) {
            String newPwd = passwordEncoder.encode("admin123");
            System.out.println("[INIT] Updating operator password to: " + newPwd);
            operator.setPassword(newPwd);
            userMapper.updateById(operator);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SysUser register(RegisterVO registerVO) {
        // 检查用户名
        if (userMapper.selectByUsername(registerVO.getUsername()) != null) {
            throw new RuntimeException("用户名已存在");
        }
        // 检查手机号
        if (StringUtils.hasText(registerVO.getPhone()) && userMapper.selectByPhone(registerVO.getPhone()) != null) {
            throw new RuntimeException("手机号已被注册");
        }

        SysUser user = new SysUser();
        user.setUsername(registerVO.getUsername());
        user.setPassword(passwordEncoder.encode(registerVO.getPassword()));
        user.setPhone(registerVO.getPhone());
        // 设置用户类型，默认为普通用户(2)
        Integer userType = registerVO.getUserType();
        user.setUserType(userType != null ? userType : 2);
        user.setStatus(1);

        userMapper.insert(user);
        return user;
    }

    @Override
    public Map<String, Object> login(LoginVO loginVO, String ip) {
        SysUser user = userMapper.selectByUsername(loginVO.getUsername());
        if (user == null || !passwordEncoder.matches(loginVO.getPassword(), user.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }
        if (user.getStatus() != 1) {
            throw new RuntimeException("账号已被禁用");
        }

        // 更新登录信息（暂时禁用，数据库缺少字段）
        // userMapper.updateLoginInfo(user.getUserId(), ip);

        // 生成Token - 根据用户类型设置角色
        String role = user.getUserType() != null && user.getUserType() == 1 ? "ADMIN" : "USER";
        String token = jwtUtil.generateToken(user.getUserId(), user.getUsername(), role);

        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("user", convertToUserVO(user));

        return result;
    }

    @Override
    public UserVO getUserInfo(Long userId) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        return convertToUserVO(user);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateUserInfo(Long userId, UserVO userVO) {
        SysUser user = new SysUser();
        user.setUserId(userId);
        user.setPhone(userVO.getPhone());
        // user_type 通常不允许用户自己修改，需要管理员权限

        userMapper.updateById(user);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        SysUser user = userMapper.selectById(userId);
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new RuntimeException("原密码错误");
        }

        SysUser updateUser = new SysUser();
        updateUser.setUserId(userId);
        updateUser.setPassword(passwordEncoder.encode(newPassword));

        userMapper.updateById(updateUser);
    }

    @Override
    public Page<SysUser> pageUsers(Page<SysUser> page, String keyword, Integer status, Integer userType) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.like(SysUser::getUsername, keyword)
                    .or()
                    .like(SysUser::getPhone, keyword);
        }
        if (status != null) {
            wrapper.eq(SysUser::getStatus, status);
        }
        if (userType != null) {
            wrapper.eq(SysUser::getUserType, userType);
        }
        wrapper.orderByDesc(SysUser::getCreateTime);

        return userMapper.selectPage(page, wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean resetPasswordByPhone(String username, String phone, String newPassword) {
        if (!StringUtils.hasText(username)) {
            throw new RuntimeException("用户名不能为空");
        }
        if (!StringUtils.hasText(phone)) {
            throw new RuntimeException("手机号不能为空");
        }
        if (!StringUtils.hasText(newPassword)) {
            throw new RuntimeException("新密码不能为空");
        }
        if (newPassword.length() < 6 || newPassword.length() > 20) {
            throw new RuntimeException("密码长度应在 6-20 个字符之间");
        }

        // 根据用户名查询用户
        SysUser user = userMapper.selectByUsername(username);
        if (user == null) {
            throw new RuntimeException("用户名不存在");
        }

        // 验证手机号是否匹配
        if (!phone.equals(user.getPhone())) {
            throw new RuntimeException("用户名与手机号不匹配");
        }

        // 更新密码
        SysUser updateUser = new SysUser();
        updateUser.setUserId(user.getUserId());
        updateUser.setPassword(passwordEncoder.encode(newPassword));

        int result = userMapper.updateById(updateUser);
        return result > 0;
    }

    private UserVO convertToUserVO(SysUser user) {
        UserVO vo = new UserVO();
        BeanUtils.copyProperties(user, vo);
        vo.setUserId(user.getUserId());
        return vo;
    }
}

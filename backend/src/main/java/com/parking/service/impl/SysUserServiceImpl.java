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
        user.setRealName(registerVO.getRealName());
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

        // 生成Token
        String token = jwtUtil.generateToken(user.getUserId(), user.getUsername(), "USER");

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
        user.setRealName(userVO.getRealName());
        user.setEmail(userVO.getEmail());
        user.setAvatar(userVO.getAvatar());

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
    public Page<SysUser> pageUsers(Page<SysUser> page, String keyword, Integer status) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.like(SysUser::getUsername, keyword)
                    .or()
                    .like(SysUser::getPhone, keyword)
                    .or()
                    .like(SysUser::getRealName, keyword);
        }
        if (status != null) {
            wrapper.eq(SysUser::getStatus, status);
        }
        wrapper.orderByDesc(SysUser::getCreateTime);

        return userMapper.selectPage(page, wrapper);
    }

    private UserVO convertToUserVO(SysUser user) {
        UserVO vo = new UserVO();
        BeanUtils.copyProperties(user, vo);
        vo.setUserId(user.getUserId());
        return vo;
    }
}

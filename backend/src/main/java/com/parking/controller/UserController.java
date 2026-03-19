package com.parking.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.parking.entity.SysUser;
import com.parking.service.SysUserService;
import com.parking.utils.JwtUtil;
import com.parking.vo.Result;
import com.parking.vo.UserVO;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户Controller
 * - 普通用户：获取/修改自己的信息
 * - 管理员：管理所有用户
 */
@Slf4j
@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
@CrossOrigin
public class UserController {

    private final SysUserService userService;
    private final JwtUtil jwtUtil;

    // ==================== 当前用户接口 ====================

    /**
     * 获取当前登录用户信息
     */
    @GetMapping("/info")
    public Result<?\u003e getUserInfo(HttpServletRequest request) {
        Long userId = getCurrentUserId(request);
        UserVO userVO = userService.getUserInfo(userId);
        return Result.success(userVO);
    }

    /**
     * 更新当前用户信息
     */
    @PutMapping("/info")
    public Result<?\u003e updateUserInfo(@RequestBody UserVO userVO, HttpServletRequest request) {
        Long userId = getCurrentUserId(request);
        userService.updateUserInfo(userId, userVO);
        return Result.success("更新成功");
    }

    /**
     * 修改当前用户密码
     */
    @PutMapping("/password")
    public Result<?\u003e changePassword(@RequestParam String oldPassword,
                                    @RequestParam String newPassword,
                                    HttpServletRequest request) {
        Long userId = getCurrentUserId(request);
        userService.changePassword(userId, oldPassword, newPassword);
        return Result.success("密码修改成功");
    }

    // ==================== 管理员接口 ====================

    /**
     * 分页查询用户（仅管理员）
     */
    @GetMapping("/page")
    public Result<Page<SysUser>\u003e page(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer userType,
            HttpServletRequest request) {

        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }

        LambdaQueryWrapper<SysUser\u003e wrapper = new LambdaQueryWrapper\u003c\u003e();

        // 关键词搜索（用户名/手机号）
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -\u003e w.like(SysUser::getUsername, keyword)
                    .or()
                    .like(SysUser::getPhone, keyword));
        }

        // 用户类型筛选
        if (userType != null) {
            wrapper.eq(SysUser::getUserType, userType);
        }

        // 按创建时间倒序
        wrapper.orderByDesc(SysUser::getCreateTime);

        Page<SysUser\u003e result = userService.page(new Page\u003c\u003e(page, size), wrapper);

        // 清除密码
        result.getRecords().forEach(user -\u003e user.setPassword(null));

        return Result.success(result);
    }

    /**
     * 获取所有用户列表（仅管理员）
     */
    @GetMapping("/list")
    public Result<List<SysUser\u003e\u003e list(HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }

        List<SysUser\u003e list = userService.list();
        // 清除密码
        list.forEach(user -\u003e user.setPassword(null));

        return Result.success(list);
    }

    /**
     * 获取用户详情（仅管理员）
     */
    @GetMapping("/{userId}")
    public Result<SysUser\u003e getById(@PathVariable Long userId, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }

        SysUser user = userService.getById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }

        // 清除密码
        user.setPassword(null);
        return Result.success(user);
    }

    /**
     * 更新用户信息（管理员可以更新任何用户，普通用户只能更新自己）
     */
    @PutMapping("/{userId}")
    public Result<Void\u003e update(@PathVariable Long userId,
                               @RequestBody SysUser user,
                               HttpServletRequest request) {

        Long currentUserId = getCurrentUserId(request);
        boolean isAdmin = isAdmin(request);

        // 普通用户只能修改自己的信息
        if (!isAdmin \u0026\u0026 !currentUserId.equals(userId)) {
            return Result.error(403, "无权修改其他用户信息");
        }

        SysUser existing = userService.getById(userId);
        if (existing == null) {
            return Result.error("用户不存在");
        }

        // 普通用户不能修改用户类型和状态
        if (!isAdmin) {
            user.setUserType(null);
            user.setStatus(null);
        }

        // 不能修改用户名
        user.setUsername(null);
        // 密码单独处理
        user.setPassword(null);

        user.setUserId(userId);
        userService.updateById(user);
        log.info("更新用户信息: userId={}", userId);
        return Result.success();
    }

    /**
     * 重置密码（仅管理员）
     */
    @PutMapping("/{userId}/reset-password")
    public Result<Void\u003e resetPassword(@PathVariable Long userId,
                                      @RequestParam String newPassword,
                                      HttpServletRequest request) {

        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以重置密码");
        }

        SysUser user = userService.getById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }

        if (!StringUtils.hasText(newPassword)) {
            return Result.error("新密码不能为空");
        }

        // 直接设置新密码
        user.setPassword(newPassword); // 服务层会加密
        userService.updateById(user);

        log.info("管理员重置密码: userId={}", userId);
        return Result.success();
    }

    /**
     * 禁用/启用用户（仅管理员）
     */
    @PutMapping("/{userId}/toggle-status")
    public Result<Void\u003e toggleStatus(@PathVariable Long userId, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以操作");
        }

        SysUser user = userService.getById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }

        // 不能禁用自己
        Long currentUserId = getCurrentUserId(request);
        if (userId.equals(currentUserId)) {
            return Result.error("不能禁用当前登录用户");
        }

        // 切换状态：0-禁用，1-启用
        user.setStatus(user.getStatus() != null \u0026\u0026 user.getStatus() == 1 ? 0 : 1);
        userService.updateById(user);

        log.info("切换用户状态: userId={}, status={}", userId, user.getStatus());
        return Result.success();
    }

    /**
     * 删除用户（仅管理员）
     */
    @DeleteMapping("/{userId}")
    public Result<Void\u003e delete(@PathVariable Long userId, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以删除用户");
        }

        SysUser user = userService.getById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }

        // 不能删除自己
        Long currentUserId = getCurrentUserId(request);
        if (userId.equals(currentUserId)) {
            return Result.error("不能删除当前登录用户");
        }

        userService.removeById(userId);
        log.info("删除用户: userId={}", userId);
        return Result.success();
    }

    /**
     * 统计用户数量（仅管理员）
     */
    @GetMapping("/count")
    public Result<Long\u003e count(HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }

        long count = userService.count();
        return Result.success(count);
    }

    // ==================== 私有方法 ====================

    private Long getCurrentUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null \u0026\u0026 token.startsWith("Bearer ")) {
            token = token.substring(7);
            return jwtUtil.getUserIdFromToken(token);
        }
        throw new RuntimeException("未登录");
    }

    /**
     * 检查当前用户是否为管理员
     */
    private boolean isAdmin(HttpServletRequest request) {
        Long userId = getCurrentUserId(request);
        SysUser user = userService.getById(userId);
        return user != null \u0026\u0026 user.getUserType() != null \u0026\u0026 user.getUserType() == 1;
    }
}

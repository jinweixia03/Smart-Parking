package com.parking.controller;

import com.parking.service.SysUserService;
import com.parking.utils.JwtUtil;
import com.parking.vo.Result;
import com.parking.vo.UserVO;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 用户Controller
 */
@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
@CrossOrigin
public class UserController {

    private final SysUserService userService;
    private final JwtUtil jwtUtil;

    /**
     * 获取用户信息
     */
    @GetMapping("/info")
    public Result<?> getUserInfo(HttpServletRequest request) {
        Long userId = getCurrentUserId(request);
        UserVO userVO = userService.getUserInfo(userId);
        return Result.success(userVO);
    }

    /**
     * 更新用户信息
     */
    @PutMapping("/info")
    public Result<?> updateUserInfo(@RequestBody UserVO userVO, HttpServletRequest request) {
        Long userId = getCurrentUserId(request);
        userService.updateUserInfo(userId, userVO);
        return Result.success("更新成功");
    }

    /**
     * 修改密码
     */
    @PutMapping("/password")
    public Result<?> changePassword(@RequestParam String oldPassword,
                                    @RequestParam String newPassword,
                                    HttpServletRequest request) {
        Long userId = getCurrentUserId(request);
        userService.changePassword(userId, oldPassword, newPassword);
        return Result.success("密码修改成功");
    }

    private Long getCurrentUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            return jwtUtil.getUserIdFromToken(token);
        }
        throw new RuntimeException("未登录");
    }
}

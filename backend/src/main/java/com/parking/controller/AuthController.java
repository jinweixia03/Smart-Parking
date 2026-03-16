package com.parking.controller;

import com.parking.service.SysUserService;
import com.parking.vo.LoginVO;
import com.parking.vo.RegisterVO;
import com.parking.vo.Result;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 认证Controller
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@CrossOrigin
public class AuthController {

    private final SysUserService userService;

    /**
     * 用户注册
     */
    @PostMapping("/register")
    public Result<?> register(@RequestBody @Valid RegisterVO registerVO) {
        userService.register(registerVO);
        return Result.success("注册成功");
    }

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<?> login(@RequestBody @Valid LoginVO loginVO, HttpServletRequest request) {
        String ip = getClientIp(request);
        Map<String, Object> result = userService.login(loginVO, ip);
        return Result.success(result);
    }

    /**
     * 获取验证码
     */
    @GetMapping("/captcha")
    public Result<?> getCaptcha() {
        // 简化版，实际应生成图形验证码
        return Result.success();
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
}

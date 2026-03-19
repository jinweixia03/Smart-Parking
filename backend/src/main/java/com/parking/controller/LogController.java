package com.parking.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.parking.entity.OperationLog;
import com.parking.entity.SysUser;
import com.parking.service.OperationLogService;
import com.parking.service.SysUserService;
import com.parking.vo.Result;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

/**
 * 操作日志Controller
 */
@Slf4j
@RestController
@RequestMapping("/log")
@RequiredArgsConstructor
@CrossOrigin
public class LogController {

    private final OperationLogService logService;
    private final SysUserService userService;

    /**
     * 分页查询操作日志（仅管理员）
     */
    @GetMapping("/page")
    public Result<Page<OperationLog>> page(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) Integer status,
            HttpServletRequest request) {

        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }

        Page<OperationLog> result = logService.pageLogs(
                new Page<>(page, size), module, status);
        return Result.success(result);
    }

    /**
     * 清理日志（仅管理员）
     */
    @DeleteMapping("/clean")
    public Result<Void> cleanLogs(
            @RequestParam(defaultValue = "30") Integer days,
            HttpServletRequest request) {

        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }

        LocalDateTime before = LocalDateTime.now().minusDays(days);
        logService.cleanLogsBefore(before);
        return Result.success();
    }

    /**
     * 检查当前用户是否为管理员
     */
    private boolean isAdmin(HttpServletRequest request) {
        Object userIdObj = request.getAttribute("userId");
        if (userIdObj == null) {
            return false;
        }
        try {
            Long userId = Long.valueOf(userIdObj.toString());
            SysUser user = userService.getById(userId);
            return user != null && user.getUserType() != null && user.getUserType() == 1;
        } catch (Exception e) {
            return false;
        }
    }
}

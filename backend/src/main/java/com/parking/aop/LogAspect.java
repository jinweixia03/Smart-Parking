package com.parking.aop;

import com.parking.entity.SysUser;
import com.parking.service.OperationLogService;
import com.parking.service.SysUserService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * 操作日志AOP拦截器
 */
@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class LogAspect {

    private final OperationLogService logService;
    private final SysUserService userService;

    /**
     * 定义切点：所有Controller方法
     */
    @Pointcut("execution(* com.parking.controller..*.*(..))")
    public void controllerPointcut() {}

    /**
     * 环绕通知：记录操作日志
     */
    @Around("controllerPointcut()")
    public Object around(ProceedingJoinPoint point) throws Throwable {
        // 获取请求信息
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null) {
            return point.proceed();
        }

        HttpServletRequest request = attributes.getRequest();
        String requestMethod = request.getMethod();
        String requestUrl = request.getRequestURI();

        // 获取用户信息
        Long userId = null;
        String username = "anonymous";
        Integer userType = 0;

        Object userIdObj = request.getAttribute("userId");
        if (userIdObj != null) {
            try {
                userId = Long.valueOf(userIdObj.toString());
                SysUser sysUser = userService.getById(userId);
                if (sysUser != null) {
                    username = sysUser.getUsername();
                    userType = sysUser.getUserType();
                }
            } catch (Exception e) {
                log.debug("获取用户信息失败: {}", e.getMessage());
            }
        }

        // 解析模块和操作
        String module = resolveModule(requestUrl);
        String operation = resolveOperation(requestMethod, requestUrl);

        // 记录开始时间
        long startTime = System.currentTimeMillis();

        // 执行目标方法
        Object result;
        int status = 1; // 默认成功
        try {
            result = point.proceed();
            return result;
        } catch (Exception e) {
            status = 0; // 失败
            throw e;
        } finally {
            long cost = System.currentTimeMillis() - startTime;

            // 只记录重要操作的日志
            if (shouldLog(requestMethod, requestUrl)) {
                try {
                    logService.logOperation(
                            userType,
                            userId,
                            username,
                            module,
                            operation,
                            requestMethod,
                            requestUrl,
                            status
                    );
                } catch (Exception e) {
                    log.error("保存操作日志失败: {}", e.getMessage());
                }
            }
        }
    }

    /**
     * 判断是否需要记录日志（operation_log表不存在，暂时禁用）
     */
    private boolean shouldLog(String method, String url) {
        return false;
    }

    /**
     * 解析模块名称
     */
    private String resolveModule(String url) {
        if (url.contains("/parking")) return "停车管理";
        if (url.contains("/auth")) return "认证管理";
        if (url.contains("/notice")) return "公告管理";
        if (url.contains("/user")) return "用户管理";
        if (url.contains("/log")) return "日志管理";
        if (url.contains("/simulation")) return "仿真管理";
        if (url.contains("/file")) return "文件管理";
        return "其他";
    }

    /**
     * 解析操作名称
     */
    private String resolveOperation(String method, String url) {
        switch (method) {
            case "POST":
                return "新增";
            case "PUT":
            case "PATCH":
                return "修改";
            case "DELETE":
                return "删除";
            default:
                return "操作";
        }
    }
}

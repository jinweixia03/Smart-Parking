package com.parking.aop;

import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * 操作日志AOP拦截器（仅记录到日志，不保存到数据库）
 */
@Slf4j
@Aspect
@Component
public class LogAspect {

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

        // 获取用户ID
        Long userId = null;
        Object userIdObj = request.getAttribute("userId");
        if (userIdObj != null) {
            try {
                userId = Long.valueOf(userIdObj.toString());
            } catch (Exception e) {
                log.debug("获取用户ID失败: {}", e.getMessage());
            }
        }

        // 记录开始时间
        long startTime = System.currentTimeMillis();

        // 执行目标方法
        Object result;
        try {
            result = point.proceed();
            return result;
        } catch (Exception e) {
            throw e;
        } finally {
            long cost = System.currentTimeMillis() - startTime;
            // 只记录耗时较长的请求
            if (cost > 100) {
                log.info("[API] {} {} userId={} cost={}ms", requestMethod, requestUrl, userId, cost);
            }
        }
    }
}

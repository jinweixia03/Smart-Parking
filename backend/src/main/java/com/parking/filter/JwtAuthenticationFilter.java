package com.parking.filter;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.parking.utils.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

/**
 * JWT 认证过滤器
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        // 放行 OPTIONS 预检请求
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            // 从请求中获取 JWT Token
            String jwt = getJwtFromRequest(request);

            // 验证 Token
            if (StringUtils.hasText(jwt)) {
                DecodedJWT decodedJWT = jwtUtil.verifyToken(jwt);

                Long userId = Long.valueOf(decodedJWT.getSubject());
                String username = jwtUtil.getUsernameFromToken(jwt);
                String role = jwtUtil.getRoleFromToken(jwt);

                // 创建认证信息
                List<SimpleGrantedAuthority> authorities = Collections.singletonList(
                    new SimpleGrantedAuthority("ROLE_" + role)
                );

                UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(
                        username,
                        null,
                        authorities
                    );

                authentication.setDetails(userId);
                SecurityContextHolder.getContext().setAuthentication(authentication);

                // 将用户ID添加到请求属性，供后续使用
                request.setAttribute("userId", userId);
                log.debug("Authenticated user: {}, role: {}", username, role);
            } else {
                log.debug("No JWT token found in request: {}", request.getRequestURI());
            }
        } catch (Exception e) {
            log.error("JWT Authentication failed: {}", e.getMessage());
            // Token 验证失败，清除上下文，继续执行，让后续的过滤器处理未认证的情况
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request, response);
    }

    /**
     * 从请求头中获取 JWT Token
     */
    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}

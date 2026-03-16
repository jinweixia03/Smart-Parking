package com.parking.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 用户信息VO
 */
@Data
public class UserVO {

    private Long userId;

    private String username;

    private String phone;

    private String email;

    private String realName;

    private String avatar;

    private Integer status;

    private BigDecimal totalAmount;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastLoginTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}

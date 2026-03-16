package com.parking.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 管理员实体类
 */
@Data
@TableName("sys_admin")
public class SysAdmin implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "admin_id", type = IdType.AUTO)
    private Long adminId;

    private String username;

    @JsonIgnore
    private String password;

    private String realName;

    private String role;

    private Integer status;

    private LocalDateTime createTime;
}

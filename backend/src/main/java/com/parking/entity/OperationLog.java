package com.parking.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 操作日志实体类
 */
@Data
@TableName("operation_log")
public class OperationLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "log_id", type = IdType.AUTO)
    private Long logId;

    private Integer operatorType;

    private Long operatorId;

    private String operatorName;

    private String module;

    private String operation;

    private String requestMethod;

    private String requestUrl;

    private Integer status;

    private LocalDateTime createTime;
}

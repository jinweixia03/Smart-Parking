package com.parking.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 车辆实体类
 */
@Data
@TableName("vehicle")
public class Vehicle implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "vehicle_id", type = IdType.AUTO)
    private Long vehicleId;

    private Long userId;

    private String plateNumber;

    private String plateColor;

    private String vehicleType;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    // 非数据库字段
    private String username;
}

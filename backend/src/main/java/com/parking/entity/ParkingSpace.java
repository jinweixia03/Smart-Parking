package com.parking.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 停车位实体类
 */
@Data
@TableName("parking_space")
public class ParkingSpace implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "space_id", type = IdType.AUTO)
    private Long spaceId;

    private Integer floor;

    private String spaceCode;

    private Integer status;

    private String currentPlate;

    // 非数据库字段（关联 parking_area 表）
    @TableField(exist = false)
    private String areaName;
    @TableField(exist = false)
    private String areaCode;
    @TableField(exist = false)
    private String areaType;
}

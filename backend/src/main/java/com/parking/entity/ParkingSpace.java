package com.parking.entity;

import com.baomidou.mybatisplus.annotation.IdType;
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

    private Long areaId;

    private Integer floor;

    private String spaceCode;

    private String spaceType;

    private Integer status;

    private String currentPlate;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime entryTime;

    // 非数据库字段
    private String areaName;
    private String areaCode;
}

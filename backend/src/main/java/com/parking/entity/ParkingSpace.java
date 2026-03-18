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

    private Integer floor;

    private String spaceCode;

    private Integer status;

    private String currentPlate;

    // 非数据库字段
    // entryTime 从 parking_record 表中查询获得
    private String areaName;
    private String areaCode;
    private String areaType;  // 关联区域的类型
}

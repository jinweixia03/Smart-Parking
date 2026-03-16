package com.parking.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;

/**
 * 停车区域实体类
 */
@Data
@TableName("parking_area")
public class ParkingArea implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "area_id", type = IdType.AUTO)
    private Long areaId;

    private String areaCode;

    private String areaName;

    private Integer totalSpaces;

    private Integer availableSpaces;

    private Integer status;
}

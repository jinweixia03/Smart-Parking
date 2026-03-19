package com.parking.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 停车记录实体类
 */
@Data
@TableName("parking_record")
public class ParkingRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "record_id", type = IdType.AUTO)
    private Long recordId;

    private String plateNumber;

    private Long spaceId;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime entryTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime exitTime;

    private BigDecimal feeAmount;

    private Integer payStatus;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime payTime;

    /**
     * 入场图片URL
     * 记录车辆入场时拍摄的图片
     */
    @TableField(exist = false)
    private String entryImage;

    /**
     * 出场图片URL
     * 记录车辆出场时拍摄的图片
     */
    @TableField(exist = false)
    private String exitImage;

    // 非数据库字段
    // parkingMinutes 通过 entryTime 和 exitTime 计算获得
    // status 通过 payStatus 推断：0=停车中，1或2=已完成
    @TableField(exist = false)
    private String spaceCode;
}

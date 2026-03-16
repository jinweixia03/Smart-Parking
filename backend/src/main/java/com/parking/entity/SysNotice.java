package com.parking.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 系统公告实体类
 */
@Data
@TableName("sys_notice")
public class SysNotice implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "notice_id", type = IdType.AUTO)
    private Long noticeId;

    private String title;

    private String content;

    private Integer noticeType;

    private Integer isTop;

    private Integer status;

    private LocalDateTime createTime;
}

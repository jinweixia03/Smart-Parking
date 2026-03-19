package com.parking.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.parking.entity.SysNotice;

import java.util.List;

/**
 * 系统公告Service接口
 */
public interface SysNoticeService extends IService<SysNotice> {

    /**
     * 分页查询公告
     */
    Page<SysNotice> pageNotices(Page<SysNotice> page, String keyword, Integer status);

    /**
     * 获取有效的公告列表
     */
    List<SysNotice> listActiveNotices();

    /**
     * 获取置顶公告
     */
    List<SysNotice> listTopNotices();

    /**
     * 发布/取消发布公告
     */
    void toggleStatus(Long noticeId);

    /**
     * 置顶/取消置顶
     */
    void toggleTop(Long noticeId);
}

package com.parking.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.parking.entity.SysNotice;
import com.parking.mapper.SysNoticeMapper;
import com.parking.service.SysNoticeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 系统公告Service实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysNoticeServiceImpl extends ServiceImpl<SysNoticeMapper, SysNotice> implements SysNoticeService {

    @Override
    public Page<SysNotice> pageNotices(Page<SysNotice> page, String keyword, Integer status) {
        LambdaQueryWrapper<SysNotice> wrapper = new LambdaQueryWrapper<>();

        // 关键词搜索
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(SysNotice::getTitle, keyword)
                    .or()
                    .like(SysNotice::getContent, keyword));
        }

        // 状态筛选
        if (status != null) {
            wrapper.eq(SysNotice::getStatus, status);
        }

        // 按置顶和时间排序
        wrapper.orderByDesc(SysNotice::getIsTop)
               .orderByDesc(SysNotice::getCreateTime);

        return baseMapper.selectPage(page, wrapper);
    }

    @Override
    public List<SysNotice> listActiveNotices() {
        LambdaQueryWrapper<SysNotice> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysNotice::getStatus, 1)
               .orderByDesc(SysNotice::getIsTop)
               .orderByDesc(SysNotice::getCreateTime);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<SysNotice> listTopNotices() {
        LambdaQueryWrapper<SysNotice> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysNotice::getStatus, 1)
               .eq(SysNotice::getIsTop, 1)
               .orderByDesc(SysNotice::getCreateTime);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public void toggleStatus(Long noticeId) {
        SysNotice notice = getById(noticeId);
        if (notice == null) {
            throw new RuntimeException("公告不存在");
        }
        // 切换状态：0->1, 1->0
        notice.setStatus(notice.getStatus() == 1 ? 0 : 1);
        updateById(notice);
        log.info("切换公告状态: noticeId={}, status={}", noticeId, notice.getStatus());
    }

    @Override
    public void toggleTop(Long noticeId) {
        SysNotice notice = getById(noticeId);
        if (notice == null) {
            throw new RuntimeException("公告不存在");
        }
        // 切换置顶：0->1, 1->0
        notice.setIsTop(notice.getIsTop() == 1 ? 0 : 1);
        updateById(notice);
        log.info("切换公告置顶: noticeId={}, isTop={}", noticeId, notice.getIsTop());
    }
}

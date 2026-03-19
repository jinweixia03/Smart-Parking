package com.parking.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.parking.entity.SysNotice;
import com.parking.entity.SysUser;
import com.parking.service.SysNoticeService;
import com.parking.service.SysUserService;
import com.parking.vo.Result;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 系统公告Controller
 */
@Slf4j
@RestController
@RequestMapping("/notice")
@RequiredArgsConstructor
@CrossOrigin
public class NoticeController {

    private final SysNoticeService noticeService;
    private final SysUserService userService;

    /**
     * 分页查询公告（管理员）
     */
    @GetMapping("/page")
    public Result<Page<SysNotice>> page(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status,
            HttpServletRequest request) {

        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }

        Page<SysNotice> result = noticeService.pageNotices(
                new Page<>(page, size), keyword, status);
        return Result.success(result);
    }

    /**
     * 获取公告详情
     */
    @GetMapping("/{noticeId}")
    public Result<SysNotice> getById(@PathVariable Long noticeId) {
        SysNotice notice = noticeService.getById(noticeId);
        return Result.success(notice);
    }

    /**
     * 获取有效的公告列表（公开接口）
     */
    @GetMapping("/list")
    public Result<List<SysNotice>> listActive() {
        List<SysNotice> list = noticeService.listActiveNotices();
        return Result.success(list);
    }

    /**
     * 获取置顶公告（公开接口）
     */
    @GetMapping("/top")
    public Result<List<SysNotice>> listTop() {
        List<SysNotice> list = noticeService.listTopNotices();
        return Result.success(list);
    }

    /**
     * 新增公告（管理员）
     */
    @PostMapping
    public Result<Void> save(@RequestBody SysNotice notice, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以发布公告");
        }

        if (!StringUtils.hasText(notice.getTitle())) {
            return Result.error("公告标题不能为空");
        }
        if (!StringUtils.hasText(notice.getContent())) {
            return Result.error("公告内容不能为空");
        }

        // 设置默认值
        notice.setStatus(1); // 默认发布
        notice.setIsTop(notice.getIsTop() != null ? notice.getIsTop() : 0);

        noticeService.save(notice);
        log.info("新增公告: noticeId={}, title={}", notice.getNoticeId(), notice.getTitle());
        return Result.success();
    }

    /**
     * 更新公告（管理员）
     */
    @PutMapping("/{noticeId}")
    public Result<Void> update(@PathVariable Long noticeId,
                                @RequestBody SysNotice notice,
                                HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以更新公告");
        }

        SysNotice existing = noticeService.getById(noticeId);
        if (existing == null) {
            return Result.error("公告不存在");
        }

        notice.setNoticeId(noticeId);
        noticeService.updateById(notice);
        log.info("更新公告: noticeId={}", noticeId);
        return Result.success();
    }

    /**
     * 删除公告（管理员）
     */
    @DeleteMapping("/{noticeId}")
    public Result<Void> delete(@PathVariable Long noticeId, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以删除公告");
        }

        SysNotice existing = noticeService.getById(noticeId);
        if (existing == null) {
            return Result.error("公告不存在");
        }

        noticeService.removeById(noticeId);
        log.info("删除公告: noticeId={}", noticeId);
        return Result.success();
    }

    /**
     * 发布/取消发布公告（管理员）
     */
    @PutMapping("/{noticeId}/toggle-status")
    public Result<Void> toggleStatus(@PathVariable Long noticeId, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以操作公告");
        }

        noticeService.toggleStatus(noticeId);
        return Result.success();
    }

    /**
     * 置顶/取消置顶（管理员）
     */
    @PutMapping("/{noticeId}/toggle-top")
    public Result<Void> toggleTop(@PathVariable Long noticeId, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以操作公告");
        }

        noticeService.toggleTop(noticeId);
        return Result.success();
    }

    /**
     * 检查当前用户是否为管理员
     */
    private boolean isAdmin(HttpServletRequest request) {
        Object userIdObj = request.getAttribute("userId");
        if (userIdObj == null) {
            return false;
        }
        try {
            Long userId = Long.valueOf(userIdObj.toString());
            SysUser user = userService.getById(userId);
            return user != null && user.getUserType() != null && user.getUserType() == 1;
        } catch (Exception e) {
            return false;
        }
    }
}

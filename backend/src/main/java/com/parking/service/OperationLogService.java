package com.parking.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.parking.entity.OperationLog;

import java.util.List;

/**
 * 操作日志Service接口
 */
public interface OperationLogService extends IService<OperationLog> {

    /**
     * 分页查询日志
     */
    Page<OperationLog> pageLogs(Page<OperationLog> page, String module, Integer status);

    /**
     * 记录操作日志
     */
    void logOperation(Integer operatorType, Long operatorId, String operatorName,
                     String module, String operation, String requestMethod,
                     String requestUrl, Integer status);

    /**
     * 清理指定日期前的日志
     */
    void cleanLogsBefore(java.time.LocalDateTime date);
}

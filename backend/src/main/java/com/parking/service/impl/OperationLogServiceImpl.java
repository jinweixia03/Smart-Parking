package com.parking.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.parking.entity.OperationLog;
import com.parking.mapper.OperationLogMapper;
import com.parking.service.OperationLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 操作日志Service实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OperationLogServiceImpl extends ServiceImpl<OperationLogMapper, OperationLog> implements OperationLogService {

    @Override
    public Page<OperationLog> pageLogs(Page<OperationLog> page, String module, Integer status) {
        LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<>();

        // 模块筛选
        if (module != null && !module.isEmpty()) {
            wrapper.eq(OperationLog::getModule, module);
        }

        // 状态筛选
        if (status != null) {
            wrapper.eq(OperationLog::getStatus, status);
        }

        // 按时间倒序
        wrapper.orderByDesc(OperationLog::getCreateTime);

        return baseMapper.selectPage(page, wrapper);
    }

    @Override
    public void logOperation(Integer operatorType, Long operatorId, String operatorName,
                           String module, String operation, String requestMethod,
                           String requestUrl, Integer status) {
        try {
            OperationLog operationLog = new OperationLog();
            operationLog.setOperatorType(operatorType);
            operationLog.setOperatorId(operatorId);
            operationLog.setOperatorName(operatorName);
            operationLog.setModule(module);
            operationLog.setOperation(operation);
            operationLog.setRequestMethod(requestMethod);
            operationLog.setRequestUrl(requestUrl);
            operationLog.setStatus(status);
            operationLog.setCreateTime(LocalDateTime.now());

            baseMapper.insert(operationLog);
        } catch (Exception e) {
            log.error("记录操作日志失败: {}", e.getMessage());
        }
    }

    @Override
    public void cleanLogsBefore(LocalDateTime date) {
        LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.lt(OperationLog::getCreateTime, date);
        baseMapper.delete(wrapper);
        log.info("清理{}之前的操作日志", date);
    }
}

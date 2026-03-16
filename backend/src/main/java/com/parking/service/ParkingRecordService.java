package com.parking.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.parking.entity.ParkingRecord;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 停车记录Service接口
 */
public interface ParkingRecordService extends IService<ParkingRecord> {

    /**
     * 车辆入场
     */
    ParkingRecord entry(String plateNumber, String imagePath, String gate);

    /**
     * 车辆出场
     */
    Map<String, Object> exit(String plateNumber, String imagePath, String gate);

    /**
     * 支付停车费
     */
    void pay(Long recordId, String payMethod);

    /**
     * 获取当前停车记录
     */
    ParkingRecord getCurrentParking(String plateNumber);

    /**
     * 计算停车费用
     */
    BigDecimal calculateFee(Long recordId);

    /**
     * 分页查询停车记录
     */
    Page<ParkingRecord> pageRecords(Page<ParkingRecord> page, String plateNumber, Integer status, Integer payStatus);

    /**
     * 获取用户停车记录
     */
    List<ParkingRecord> getUserRecords(Long userId);

    /**
     * 获取今日统计
     */
    Map<String, Object> getTodayStats();

    /**
     * 获取实时停车数据
     */
    Map<String, Object> getRealTimeData();

    /**
     * 获取图表数据
     */
    Map<String, Object> getChartData(String type, String startDate, String endDate);
}

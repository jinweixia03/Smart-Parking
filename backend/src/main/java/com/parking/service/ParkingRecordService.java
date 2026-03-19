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
    ParkingRecord entry(String plateNumber);

    /**
     * 车辆出场
     */
    Map<String, Object> exit(String plateNumber);

    /**
     * 支付停车费
     */
    void pay(Long recordId);

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
    Page<ParkingRecord> pageRecords(Page<ParkingRecord> page, String plateNumber, Integer status, Integer payStatus, String startDate, String endDate);

    /**
     * 根据车牌号查询停车记录
     */
    List<ParkingRecord> getRecordsByPlateNumber(String plateNumber);

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

    /**
     * 获取车辆详情（当前停车信息 + 近5次停车记录）
     */
    Map<String, Object> getVehicleDetail(String plateNumber);
}

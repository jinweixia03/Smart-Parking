package com.parking.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.parking.entity.ParkingSpace;

import java.util.List;

/**
 * 停车位Service接口
 */
public interface ParkingSpaceService extends IService<ParkingSpace> {

    /**
     * 获取所有可用车位（status=0）
     */
    List<ParkingSpace> listAllAvailable();

    /**
     * 获取所有车位（包含区域信息）
     */
    List<ParkingSpace> listAllWithArea();
}

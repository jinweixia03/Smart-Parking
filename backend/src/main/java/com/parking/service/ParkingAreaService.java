package com.parking.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.parking.entity.ParkingArea;

import java.util.List;

/**
 * 停车区域Service接口
 */
public interface ParkingAreaService extends IService<ParkingArea> {

    /**
     * 获取所有启用区域
     */
    List<ParkingArea> listActive();
}

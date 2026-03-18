package com.parking.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.parking.entity.ParkingSpace;
import com.parking.mapper.ParkingSpaceMapper;
import com.parking.service.ParkingSpaceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 停车位Service实现
 */
@Service
@RequiredArgsConstructor
public class ParkingSpaceServiceImpl extends ServiceImpl<ParkingSpaceMapper, ParkingSpace> implements ParkingSpaceService {

    private final ParkingSpaceMapper spaceMapper;

    @Override
    public List<ParkingSpace> listAllAvailable() {
        return spaceMapper.selectAllAvailable();
    }

    @Override
    public List<ParkingSpace> listAllWithArea() {
        return spaceMapper.selectAllWithArea();
    }
}

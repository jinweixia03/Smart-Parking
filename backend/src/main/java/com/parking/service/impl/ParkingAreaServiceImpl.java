package com.parking.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.parking.entity.ParkingArea;
import com.parking.mapper.ParkingAreaMapper;
import com.parking.mapper.ParkingSpaceMapper;
import com.parking.service.ParkingAreaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * 停车区域Service实现
 */
@Service
@RequiredArgsConstructor
public class ParkingAreaServiceImpl extends ServiceImpl<ParkingAreaMapper, ParkingArea> implements ParkingAreaService {

    private final ParkingAreaMapper areaMapper;
    private final ParkingSpaceMapper spaceMapper;

    @Override
    public List<ParkingArea> listActive() {
        return areaMapper.selectAllActive();
    }
}

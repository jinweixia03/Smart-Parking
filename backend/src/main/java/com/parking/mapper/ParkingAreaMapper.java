package com.parking.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.parking.entity.ParkingArea;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 停车区域Mapper
 */
@Mapper
public interface ParkingAreaMapper extends BaseMapper<ParkingArea> {

    @Select("SELECT * FROM parking_area WHERE status = 1 ORDER BY area_code")
    List<ParkingArea> selectAllActive();

    @Select("SELECT * FROM parking_area WHERE area_code = #{areaCode} LIMIT 1")
    ParkingArea selectByAreaCode(String areaCode);
}

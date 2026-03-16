package com.parking.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.parking.entity.ParkingSpace;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

/**
 * 停车位Mapper
 */
@Mapper
public interface ParkingSpaceMapper extends BaseMapper<ParkingSpace> {

    @Select("SELECT s.*, a.area_name, a.area_code FROM parking_space s " +
            "LEFT JOIN parking_area a ON s.area_id = a.area_id " +
            "WHERE s.status = 0")
    List<ParkingSpace> selectAllAvailable();

    @Select("SELECT s.*, a.area_name, a.area_code FROM parking_space s " +
            "LEFT JOIN parking_area a ON s.area_id = a.area_id " +
            "WHERE s.area_id = #{areaId}")
    List<ParkingSpace> selectByAreaId(Long areaId);

    @Select("SELECT s.*, a.area_name, a.area_code FROM parking_space s " +
            "LEFT JOIN parking_area a ON s.area_id = a.area_id " +
            "WHERE s.current_plate = #{plateNumber} AND s.status = 1 LIMIT 1")
    ParkingSpace selectByCurrentPlate(String plateNumber);

    @Select("SELECT COUNT(*) FROM parking_space WHERE status = #{status}")
    int countByStatus(Integer status);
}

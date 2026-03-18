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

    @Select("SELECT * FROM parking_space WHERE status = 0")
    List<ParkingSpace> selectAllAvailable();

    /**
     * 查询所有车位并关联区域信息
     */
    @Select("SELECT s.*, a.area_code, a.area_name, a.area_type FROM parking_space s " +
            "LEFT JOIN parking_area a ON s.space_code LIKE CONCAT(a.area_code, '%') " +
            "ORDER BY s.floor, s.space_id")
    List<ParkingSpace> selectAllWithArea();

    @Select("SELECT * FROM parking_space WHERE current_plate = #{plateNumber} AND status = 1 LIMIT 1")
    ParkingSpace selectByCurrentPlate(String plateNumber);

    @Select("SELECT COUNT(*) FROM parking_space WHERE status = #{status}")
    int countByStatus(Integer status);
}

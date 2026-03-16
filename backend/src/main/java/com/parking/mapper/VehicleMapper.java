package com.parking.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.parking.entity.Vehicle;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 车辆Mapper
 */
@Mapper
public interface VehicleMapper extends BaseMapper<Vehicle> {

    @Select("SELECT v.*, u.username FROM vehicle v " +
            "LEFT JOIN sys_user u ON v.user_id = u.user_id " +
            "WHERE v.user_id = #{userId}")
    List<Vehicle> selectByUserId(Long userId);

    @Select("SELECT v.*, u.username FROM vehicle v " +
            "LEFT JOIN sys_user u ON v.user_id = u.user_id " +
            "WHERE v.plate_number = #{plateNumber} LIMIT 1")
    Vehicle selectByPlateNumber(String plateNumber);
}

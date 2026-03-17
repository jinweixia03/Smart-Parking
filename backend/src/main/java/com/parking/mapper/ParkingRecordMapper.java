package com.parking.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.parking.entity.ParkingRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 停车记录Mapper
 */
@Mapper
public interface ParkingRecordMapper extends BaseMapper<ParkingRecord> {

    @Select("SELECT * FROM parking_record WHERE plate_number = #{plateNumber} AND status = 0 ORDER BY entry_time DESC LIMIT 1")
    ParkingRecord selectActiveByPlate(String plateNumber);

    @Select("SELECT * FROM parking_record WHERE plate_number = #{plateNumber} ORDER BY entry_time DESC")
    List<ParkingRecord> selectByPlateNumber(String plateNumber);

    Page<ParkingRecord> selectPageWithDetail(Page<ParkingRecord> page,
                                              @Param("plateNumber") String plateNumber,
                                              @Param("status") Integer status,
                                              @Param("payStatus") Integer payStatus);

    @Update("UPDATE parking_record SET exit_time = NOW(), exit_gate = #{gate}, " +
            "parking_minutes = #{minutes}, fee_amount = #{fee}, payable_amount = #{payable}, " +
            "status = 1 WHERE record_id = #{recordId}")
    void completeExit(@Param("recordId") Long recordId, @Param("gate") String gate,
                      @Param("minutes") Integer minutes, @Param("fee") BigDecimal fee,
                      @Param("payable") BigDecimal payable);

    @Update("UPDATE parking_record SET pay_status = 1, pay_time = NOW(), paid_amount = #{amount} " +
            "WHERE record_id = #{recordId}")
    void updatePayment(@Param("recordId") Long recordId, @Param("amount") BigDecimal amount);

    @Select("SELECT COUNT(*) FROM parking_record WHERE DATE(entry_time) = CURDATE()")
    int countTodayEntry();

    @Select("SELECT COUNT(*) FROM parking_record WHERE DATE(exit_time) = CURDATE() AND status = 1")
    int countTodayExit();

    @Select("SELECT COALESCE(SUM(paid_amount), 0) FROM parking_record WHERE DATE(pay_time) = CURDATE() AND pay_status = 1")
    BigDecimal sumTodayRevenue();

    @Select("SELECT COUNT(*) FROM parking_record WHERE status = 0")
    int countActiveParking();

    List<Map<String, Object>> selectHourlyStats(@Param("date") String date);

    List<Map<String, Object>> selectDailyStats(@Param("startDate") String startDate, @Param("endDate") String endDate);

    List<Map<String, Object>> selectAreaStats();

    /**
     * 查询指定车牌的最近N条停车记录
     * @param plateNumber 车牌号
     * @param limit 返回记录数
     * @return 停车记录列表
     */
    @Select("SELECT * FROM parking_record WHERE plate_number = #{plateNumber} ORDER BY entry_time DESC LIMIT #{limit}")
    List<ParkingRecord> selectRecentByPlate(@Param("plateNumber") String plateNumber, @Param("limit") int limit);
}

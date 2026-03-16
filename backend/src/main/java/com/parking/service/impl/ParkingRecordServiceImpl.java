package com.parking.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.parking.entity.FeeRule;
import com.parking.entity.ParkingRecord;
import com.parking.entity.ParkingSpace;
import com.parking.entity.Vehicle;
import com.parking.mapper.FeeRuleMapper;
import com.parking.mapper.ParkingRecordMapper;
import com.parking.mapper.ParkingSpaceMapper;
import com.parking.mapper.VehicleMapper;
import com.parking.service.ParkingRecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 停车记录Service实现
 */
@Service
@RequiredArgsConstructor
public class ParkingRecordServiceImpl extends ServiceImpl<ParkingRecordMapper, ParkingRecord> implements ParkingRecordService {

    private final ParkingRecordMapper recordMapper;
    private final ParkingSpaceMapper spaceMapper;
    private final VehicleMapper vehicleMapper;
    private final FeeRuleMapper feeRuleMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ParkingRecord entry(String plateNumber, String imagePath, String gate) {
        // 检查是否已有未完成的记录
        ParkingRecord existing = recordMapper.selectActiveByPlate(plateNumber);
        if (existing != null) {
            throw new RuntimeException("该车辆已在停车场内");
        }

        // 创建新记录
        ParkingRecord record = new ParkingRecord();
        record.setPlateNumber(plateNumber);
        record.setEntryImage(imagePath);
        record.setEntryTime(LocalDateTime.now());
        record.setEntryGate(gate);
        record.setStatus(0);
        record.setPayStatus(0);

        // 关联用户和车辆
        Vehicle vehicle = vehicleMapper.selectByPlateNumber(plateNumber);
        if (vehicle != null) {
            record.setUserId(vehicle.getUserId());
            record.setVehicleId(vehicle.getVehicleId());
        }

        // 分配车位
        ParkingSpace space = allocateSpace();
        if (space != null) {
            record.setSpaceId(space.getSpaceId());
            space.setStatus(1);
            space.setCurrentPlate(plateNumber);
            space.setEntryTime(LocalDateTime.now());
            spaceMapper.updateById(space);
        }

        recordMapper.insert(record);
        updateRealTimeStats();

        return record;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> exit(String plateNumber, String imagePath, String gate) {
        ParkingRecord record = recordMapper.selectActiveByPlate(plateNumber);
        if (record == null) {
            throw new RuntimeException("未找到该车辆的入场记录");
        }

        LocalDateTime exitTime = LocalDateTime.now();
        long minutes = Duration.between(record.getEntryTime(), exitTime).toMinutes();

        // 计算费用
        BigDecimal fee = doCalculateFee((int) minutes);

        // 更新记录
        record.setExitTime(exitTime);
        record.setExitImage(imagePath);
        record.setExitGate(gate);
        record.setParkingMinutes((int) minutes);
        record.setFeeAmount(fee);
        record.setPayableAmount(fee);
        record.setStatus(1);

        // 免费时段
        FeeRule rule = feeRuleMapper.selectDefault();
        if (minutes <= rule.getFreeMinutes() || fee.compareTo(BigDecimal.ZERO) == 0) {
            record.setPayStatus(2); // 免费
            record.setPayTime(exitTime);
            record.setPaidAmount(BigDecimal.ZERO);
        }

        recordMapper.updateById(record);

        // 释放车位
        if (record.getSpaceId() != null) {
            ParkingSpace space = spaceMapper.selectById(record.getSpaceId());
            if (space != null) {
                space.setStatus(0);
                space.setCurrentPlate(null);
                space.setEntryTime(null);
                spaceMapper.updateById(space);
            }
        }

        updateRealTimeStats();

        Map<String, Object> result = new HashMap<>();
        result.put("record", record);
        result.put("minutes", minutes);
        result.put("fee", fee);
        result.put("needPay", record.getPayStatus() == 0);

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void pay(Long recordId, String payMethod) {
        ParkingRecord record = recordMapper.selectById(recordId);
        if (record == null) {
            throw new RuntimeException("记录不存在");
        }
        if (record.getPayStatus() == 1 || record.getPayStatus() == 2) {
            throw new RuntimeException("该记录已支付");
        }

        record.setPayStatus(1);
        record.setPayTime(LocalDateTime.now());
        record.setPaidAmount(record.getPayableAmount());
        record.setPayMethod(payMethod);

        recordMapper.updateById(record);
    }

    @Override
    public ParkingRecord getCurrentParking(String plateNumber) {
        return recordMapper.selectActiveByPlate(plateNumber);
    }

    @Override
    public BigDecimal calculateFee(Long recordId) {
        ParkingRecord record = recordMapper.selectById(recordId);
        if (record == null || record.getEntryTime() == null) {
            return BigDecimal.ZERO;
        }
        long minutes = Duration.between(record.getEntryTime(), LocalDateTime.now()).toMinutes();
        return doCalculateFee((int) minutes);
    }

    private BigDecimal doCalculateFee(int minutes) {
        FeeRule rule = feeRuleMapper.selectDefault();
        if (rule == null) {
            return BigDecimal.ZERO;
        }

        // 免费时长
        if (minutes <= rule.getFreeMinutes()) {
            return BigDecimal.ZERO;
        }

        // 计算小时数，不足1小时按1小时算
        int hours = (int) Math.ceil(minutes / 60.0);

        BigDecimal fee;
        if (hours <= 1) {
            fee = rule.getFirstHourFee();
        } else {
            fee = rule.getFirstHourFee()
                    .add(rule.getExtraHourFee().multiply(BigDecimal.valueOf(hours - 1)));
        }

        // 24小时封顶
        int days = hours / 24;
        int remainingHours = hours % 24;

        if (days > 0) {
            BigDecimal dailyFee = rule.getDailyMaxFee().multiply(BigDecimal.valueOf(days));
            BigDecimal remainingFee = remainingHours <= 1
                    ? rule.getFirstHourFee()
                    : rule.getFirstHourFee().add(rule.getExtraHourFee().multiply(BigDecimal.valueOf(remainingHours - 1)));
            fee = dailyFee.add(remainingFee.min(rule.getDailyMaxFee()));
        } else {
            fee = fee.min(rule.getDailyMaxFee());
        }

        return fee.setScale(2, RoundingMode.HALF_UP);
    }

    private ParkingSpace allocateSpace() {
        List<ParkingSpace> availableSpaces = spaceMapper.selectAllAvailable();
        if (availableSpaces.isEmpty()) {
            return null;
        }
        int index = (int) (Math.random() * availableSpaces.size());
        return availableSpaces.get(index);
    }

    private void updateRealTimeStats() {
        // Real-time stats updated in database directly, no Redis needed
    }

    @Override
    public Page<ParkingRecord> pageRecords(Page<ParkingRecord> page, String plateNumber, Integer status, Integer payStatus) {
        return recordMapper.selectPageWithDetail(page, plateNumber, status, payStatus);
    }

    @Override
    public List<ParkingRecord> getUserRecords(Long userId) {
        return recordMapper.selectByUserId(userId);
    }

    @Override
    public Map<String, Object> getTodayStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("entryCount", recordMapper.countTodayEntry());
        stats.put("exitCount", recordMapper.countTodayExit());
        stats.put("revenue", recordMapper.sumTodayRevenue());
        stats.put("activeCount", recordMapper.countActiveParking());
        return stats;
    }

    @Override
    public Map<String, Object> getRealTimeData() {
        Map<String, Object> data = new HashMap<>();
        data.put("activeCount", recordMapper.countActiveParking());
        data.put("todayEntry", recordMapper.countTodayEntry());
        data.put("todayExit", recordMapper.countTodayExit());
        data.put("todayRevenue", recordMapper.sumTodayRevenue());

        long totalSpaces = spaceMapper.selectCount(null);
        long availableSpaces = spaceMapper.countByStatus(0);
        data.put("totalSpaces", totalSpaces);
        data.put("availableSpaces", availableSpaces);
        data.put("occupancyRate", totalSpaces > 0 ? (totalSpaces - availableSpaces) * 100 / totalSpaces : 0);

        return data;
    }

    @Override
    public Map<String, Object> getChartData(String type, String startDate, String endDate) {
        Map<String, Object> result = new HashMap<>();

        if ("hourly".equals(type)) {
            result.put("data", recordMapper.selectHourlyStats(startDate));
        } else if ("daily".equals(type)) {
            result.put("data", recordMapper.selectDailyStats(startDate, endDate));
        } else if ("area".equals(type)) {
            result.put("data", recordMapper.selectAreaStats());
        }

        return result;
    }
}

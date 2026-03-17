package com.parking.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.parking.entity.FeeRule;
import com.parking.entity.ParkingRecord;
import com.parking.entity.ParkingSpace;
import com.parking.mapper.FeeRuleMapper;
import com.parking.mapper.ParkingRecordMapper;
import com.parking.mapper.ParkingSpaceMapper;
import com.parking.service.ParkingRecordService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 停车记录Service实现
 *
 * <p>核心业务流程说明：</p>
 *
 * <pre>
 * ╔══════════════════════════════════════════════════════════════════════════╗
 * ║                        车辆入场流程 (entry)                                ║
 * ╠══════════════════════════════════════════════════════════════════════════╣
 * ║                                                                          ║
 * ║   前端Controller    ParkingRecordService    ParkingSpaceMapper           ║
 * ║        |                   |                       |                     ║
 * ║        | ──入场请求(plate)──> |                       |                     ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──1.检查车辆是否已在场────>|                     ║
 * ║        |                   |<──返回在场记录/空────────|                     ║
 * ║        |                   | [如在场: 抛异常"车辆已在场"]                     ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──2.查询车辆绑定用户信息──>|                     ║
 * ║        |                   |<──返回Vehicle对象───────|                     ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──3.分配可用停车位───────>|                     ║
 * ║        |                   |<──返回ParkingSpace─────|                     ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──4.占用停车位状态───────>|                     ║
 * ║        |                   |<──更新成功─────────────|                     ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──5.创建停车记录─────────>|                     ║
 * ║        |                   |<──插入成功─────────────|                     ║
 * ║        |                   |                       |                     ║
 * ║        |<──返回ParkingRecord──|                       |                     ║
 * ║        |                   |                       |                     ║
 * ╚══════════════════════════════════════════════════════════════════════════╝
 *
 * ╔══════════════════════════════════════════════════════════════════════════╗
 * ║                        车辆出场流程 (exit)                                 ║
 * ╠══════════════════════════════════════════════════════════════════════════╣
 * ║                                                                          ║
 * ║   前端Controller    ParkingRecordService    FeeRuleMapper                ║
 * ║        |                   |                       |                     ║
 * ║        | ──出场请求(plate)──> |                       |                     ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──1.查询在场记录────────>|                     ║
 * ║        |                   |<──返回ParkingRecord────|                     ║
 * ║        |                   | [如不在场: 抛异常"未找到入场记录"]              ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──2.计算停车时长────────>│                     ║
 * ║        |                   |<──────────────────────│                     ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──3.查询收费规则────────>|                     ║
 * ║        |                   |<──返回FeeRule──────────|                     ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──4.计算停车费用────────>│                     ║
 * ║        |                   |  (含免费时长/24小时封顶逻辑)                    ║
 * ║        |                   |<──返回BigDecimal───────│                     ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──5.更新出场记录───────>│                     ║
 * ║        |                   |  (出场时间/费用/状态等)                        ║
 * ║        |                   |<──────────────────────│                     ║
 * ║        |                   |                       |                     ║
 * ║        |                   |──6.释放停车位─────────>│                     ║
 * ║        |                   |<──────────────────────│                     ║
 * ║        |                   |                       |                     ║
 * ║        |<──返回结果Map──────|                       |                     ║
 * ║        |   {record, minutes, fee, needPay}                               ║
 * ║        |                   |                       |                     ║
 * ╚══════════════════════════════════════════════════════════════════════════╝
 *
 * ╔══════════════════════════════════════════════════════════════════════════╗
 * ║                        支付流程 (pay)                                      ║
 * ╠══════════════════════════════════════════════════════════════════════════╣
 * ║                                                                          ║
 * ║   前端Controller    ParkingRecordService                                 ║
 * ║        |                   |                                             ║
 * ║        | ─支付请求(recordId)─> |                                          ║
 * ║        |                   |──1.查询记录是否存在────────────────────────>║
 * ║        |                   | [不存在: 抛异常"记录不存在"]                    ║
 * ║        |                   |                                             ║
 * ║        |                   |──2.检查支付状态───────────────────────────>║
 * ║        |                   | [已支付: 抛异常"记录已支付"]                    ║
 * ║        |                   |                                             ║
 * ║        |                   |──3.更新支付状态───────────────────────────>║
 * ║        |                   |   (payStatus=1, payTime, paidAmount)         ║
 * ║        |<──"支付成功"──────|                                              ║
 * ║                                                                          ║
 * ╚══════════════════════════════════════════════════════════════════════════╝
 * </pre>
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ParkingRecordServiceImpl extends ServiceImpl<ParkingRecordMapper, ParkingRecord> implements ParkingRecordService {

    /**
     * 停车记录状态：0-停车中
     */
    private static final int STATUS_PARKING = 0;
    /**
     * 停车记录状态：1-已完成
     */
    private static final int STATUS_COMPLETED = 1;

    /**
     * 支付状态：0-未支付
     */
    private static final int PAY_STATUS_UNPAID = 0;
    /**
     * 支付状态：1-已支付
     */
    private static final int PAY_STATUS_PAID = 1;
    /**
     * 支付状态：2-免费
     */
    private static final int PAY_STATUS_FREE = 2;

    /**
     * 车位状态：0-空闲
     */
    private static final int SPACE_STATUS_FREE = 0;
    /**
     * 车位状态：1-占用
     */
    private static final int SPACE_STATUS_OCCUPIED = 1;

    /**
     * 每小时分钟数
     */
    private static final int MINUTES_PER_HOUR = 60;
    /**
     * 每天小时数
     */
    private static final int HOURS_PER_DAY = 24;

    private final ParkingRecordMapper recordMapper;
    private final ParkingSpaceMapper spaceMapper;
    private final FeeRuleMapper feeRuleMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ParkingRecord entry(String plateNumber, String gate) {
        log.info("车辆入场: plateNumber={}, gate={}", plateNumber, gate);

        // 校验车牌号
        if (!StringUtils.hasText(plateNumber)) {
            throw new IllegalArgumentException("车牌号不能为空");
        }

        // 1. 检查是否已有未完成的记录
        ParkingRecord existing = recordMapper.selectActiveByPlate(plateNumber);
        if (existing != null) {
            log.warn("车辆已在停车场内: plateNumber={}, entryTime={}", plateNumber, existing.getEntryTime());
            throw new RuntimeException("该车辆已在停车场内");
        }

        // 2. 创建新记录
        ParkingRecord record = buildEntryRecord(plateNumber, gate);

        // 3. 分配车位
        ParkingSpace space = allocateSpace();
        if (space != null) {
            occupySpace(space, plateNumber, record);
        } else {
            log.warn("停车场已满，车辆{}无车位分配", plateNumber);
        }

        // 5. 保存记录
        recordMapper.insert(record);
        log.info("车辆入场成功: recordId={}, plateNumber={}, spaceId={}",
                record.getRecordId(), plateNumber, record.getSpaceId());

        return record;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> exit(String plateNumber, String gate) {
        log.info("车辆出场: plateNumber={}, gate={}", plateNumber, gate);

        if (!StringUtils.hasText(plateNumber)) {
            throw new IllegalArgumentException("车牌号不能为空");
        }

        // 1. 查询在场记录
        ParkingRecord record = recordMapper.selectActiveByPlate(plateNumber);
        if (record == null) {
            log.warn("未找到车辆入场记录: plateNumber={}", plateNumber);
            throw new RuntimeException("未找到该车辆的入场记录");
        }

        // 2. 计算停车时长和费用
        LocalDateTime exitTime = LocalDateTime.now();
        long minutes = calculateParkingMinutes(record.getEntryTime(), exitTime);
        BigDecimal fee = doCalculateFee((int) minutes);

        // 3. 更新出场记录
        boolean isFree = fee.compareTo(BigDecimal.ZERO) == 0;
        updateRecordForExit(record, exitTime, gate, (int) minutes, fee, isFree);
        recordMapper.updateById(record);

        // 4. 释放车位
        if (record.getSpaceId() != null) {
            releaseSpace(record.getSpaceId());
        }

        log.info("车辆出场成功: recordId={}, plateNumber={}, minutes={}, fee={}, isFree={}",
                record.getRecordId(), plateNumber, minutes, fee, isFree);

        // 5. 返回结果
        return buildExitResult(record, minutes, fee);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void pay(Long recordId, String payMethod) {
        log.info("停车支付: recordId={}, payMethod={}", recordId, payMethod);

        if (recordId == null) {
            throw new IllegalArgumentException("记录ID不能为空");
        }

        ParkingRecord record = recordMapper.selectById(recordId);
        if (record == null) {
            throw new RuntimeException("记录不存在");
        }

        // 检查支付状态
        if (record.getPayStatus() == PAY_STATUS_PAID || record.getPayStatus() == PAY_STATUS_FREE) {
            throw new RuntimeException("该记录已支付");
        }

        // 更新支付信息
        record.setPayStatus(PAY_STATUS_PAID);
        record.setPayTime(LocalDateTime.now());
        record.setPaidAmount(record.getPayableAmount());
        record.setPayMethod(payMethod);

        recordMapper.updateById(record);
        log.info("支付成功: recordId={}, amount={}", recordId, record.getPaidAmount());
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
        long minutes = calculateParkingMinutes(record.getEntryTime(), LocalDateTime.now());
        return doCalculateFee((int) minutes);
    }

    @Override
    public Page<ParkingRecord> pageRecords(Page<ParkingRecord> page, String plateNumber, Integer status, Integer payStatus) {
        return recordMapper.selectPageWithDetail(page, plateNumber, status, payStatus);
    }

    @Override
    public List<ParkingRecord> getRecordsByPlateNumber(String plateNumber) {
        return recordMapper.selectByPlateNumber(plateNumber);
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
        long availableSpaces = spaceMapper.countByStatus(SPACE_STATUS_FREE);
        data.put("totalSpaces", totalSpaces);
        data.put("availableSpaces", availableSpaces);
        data.put("occupancyRate", calculateOccupancyRate(totalSpaces, availableSpaces));

        return data;
    }

    @Override
    public Map<String, Object> getChartData(String type, String startDate, String endDate) {
        Map<String, Object> result = new HashMap<>();

        switch (type) {
            case "hourly":
                result.put("data", recordMapper.selectHourlyStats(startDate));
                break;
            case "daily":
                result.put("data", recordMapper.selectDailyStats(startDate, endDate));
                break;
            case "area":
                result.put("data", recordMapper.selectAreaStats());
                break;
            default:
                log.warn("未知的图表类型: {}", type);
                break;
        }

        return result;
    }

    @Override
    public Map<String, Object> getVehicleDetail(String plateNumber) {
        log.info("获取车辆详情: plateNumber={}", plateNumber);

        Map<String, Object> result = new HashMap<>();

        // 1. 获取当前停车信息（如果有）
        ParkingRecord currentRecord = recordMapper.selectActiveByPlate(plateNumber);
        if (currentRecord != null) {
            result.put("vehicleInfo", currentRecord);
        } else {
            // 如果没有当前停车，获取最近一次停车记录
            List<ParkingRecord> records = recordMapper.selectRecentByPlate(plateNumber, 1);
            if (!records.isEmpty()) {
                result.put("vehicleInfo", records.get(0));
            } else {
                // 没有任何记录，创建一个基本信息
                ParkingRecord emptyRecord = new ParkingRecord();
                emptyRecord.setPlateNumber(plateNumber);
                result.put("vehicleInfo", emptyRecord);
            }
        }

        // 2. 获取近5次停车记录
        List<ParkingRecord> recentRecords = recordMapper.selectRecentByPlate(plateNumber, 5);
        result.put("recentRecords", recentRecords);

        return result;
    }

    // ==================== 私有方法 ====================

    /**
     * 构建入场记录
     */
    private ParkingRecord buildEntryRecord(String plateNumber, String gate) {
        ParkingRecord record = new ParkingRecord();
        record.setPlateNumber(plateNumber);
        record.setEntryTime(LocalDateTime.now());
        record.setEntryGate(gate);
        record.setStatus(STATUS_PARKING);
        record.setPayStatus(PAY_STATUS_UNPAID);
        return record;
    }

    /**
     * 分配车位
     */
    private ParkingSpace allocateSpace() {
        List<ParkingSpace> availableSpaces = spaceMapper.selectAllAvailable();
        if (availableSpaces.isEmpty()) {
            return null;
        }
        // 随机分配一个车位（可优化为根据车位类型、距离等策略分配）
        int index = (int) (Math.random() * availableSpaces.size());
        return availableSpaces.get(index);
    }

    /**
     * 占用车位
     */
    private void occupySpace(ParkingSpace space, String plateNumber, ParkingRecord record) {
        record.setSpaceId(space.getSpaceId());
        space.setStatus(SPACE_STATUS_OCCUPIED);
        space.setCurrentPlate(plateNumber);
        space.setEntryTime(LocalDateTime.now());
        spaceMapper.updateById(space);
        log.debug("分配车位: spaceId={}, spaceCode={}", space.getSpaceId(), space.getSpaceCode());
    }

    /**
     * 释放车位
     */
    private void releaseSpace(Long spaceId) {
        ParkingSpace space = spaceMapper.selectById(spaceId);
        if (space != null) {
            space.setStatus(SPACE_STATUS_FREE);
            space.setCurrentPlate(null);
            space.setEntryTime(null);
            spaceMapper.updateById(space);
            log.debug("释放车位: spaceId={}", spaceId);
        }
    }

    /**
     * 计算停车分钟数
     */
    private long calculateParkingMinutes(LocalDateTime entryTime, LocalDateTime exitTime) {
        return Duration.between(entryTime, exitTime).toMinutes();
    }

    /**
     * 计算费用
     */
    private BigDecimal doCalculateFee(int minutes) {
        FeeRule rule = feeRuleMapper.selectDefault();
        if (rule == null) {
            log.warn("未配置收费规则，返回0元");
            return BigDecimal.ZERO;
        }

        // 免费时长
        if (minutes <= rule.getFreeMinutes()) {
            return BigDecimal.ZERO;
        }

        // 计算小时数，不足1小时按1小时算
        int hours = (int) Math.ceil(minutes / (double) MINUTES_PER_HOUR);

        BigDecimal fee = calculateHourlyFee(rule, hours);

        // 应用24小时封顶规则
        fee = applyDailyCap(rule, hours, fee);

        return fee.setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * 按小时计算费用
     */
    private BigDecimal calculateHourlyFee(FeeRule rule, int hours) {
        if (hours <= 1) {
            return rule.getFirstHourFee();
        }
        return rule.getFirstHourFee()
                .add(rule.getExtraHourFee().multiply(BigDecimal.valueOf(hours - 1)));
    }

    /**
     * 应用24小时封顶规则
     */
    private BigDecimal applyDailyCap(FeeRule rule, int hours, BigDecimal fee) {
        int days = hours / HOURS_PER_DAY;
        int remainingHours = hours % HOURS_PER_DAY;

        if (days > 0) {
            BigDecimal dailyFee = rule.getDailyMaxFee().multiply(BigDecimal.valueOf(days));
            BigDecimal remainingFee = calculateHourlyFee(rule, remainingHours);
            // 剩余时间也受封顶限制
            remainingFee = remainingFee.min(rule.getDailyMaxFee());
            return dailyFee.add(remainingFee);
        }

        return fee.min(rule.getDailyMaxFee());
    }

    /**
     * 更新记录为出场状态
     */
    private void updateRecordForExit(ParkingRecord record, LocalDateTime exitTime,
                                     String gate, int minutes, BigDecimal fee, boolean isFree) {
        record.setExitTime(exitTime);
        record.setExitGate(gate);
        record.setParkingMinutes(minutes);
        record.setFeeAmount(fee);
        record.setPayableAmount(fee);
        record.setStatus(STATUS_COMPLETED);

        if (isFree) {
            record.setPayStatus(PAY_STATUS_FREE);
            record.setPayTime(exitTime);
            record.setPaidAmount(BigDecimal.ZERO);
        }
    }

    /**
     * 构建出场结果
     */
    private Map<String, Object> buildExitResult(ParkingRecord record, long minutes, BigDecimal fee) {
        Map<String, Object> result = new HashMap<>();
        result.put("record", record);
        result.put("minutes", minutes);
        result.put("fee", fee);
        result.put("needPay", record.getPayStatus() == PAY_STATUS_UNPAID);
        return result;
    }

    /**
     * 计算占用率
     */
    private long calculateOccupancyRate(long totalSpaces, long availableSpaces) {
        if (totalSpaces <= 0) {
            return 0;
        }
        return (totalSpaces - availableSpaces) * 100 / totalSpaces;
    }
}

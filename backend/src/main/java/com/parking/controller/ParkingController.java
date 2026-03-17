package com.parking.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.parking.entity.ParkingArea;
import com.parking.entity.ParkingRecord;
import com.parking.entity.ParkingSpace;
import com.parking.entity.SysUser;
import com.parking.service.ParkingAreaService;
import com.parking.service.ParkingRecordService;
import com.parking.service.ParkingSpaceService;
import com.parking.service.SysUserService;
import com.parking.vo.Result;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 停车场Controller
 *
 * <p>提供停车场核心业务接口：</p>
 * <ul>
 *   <li>车辆入场/出场管理（仅管理员）</li>
 *   <li>停车费用计算与支付（普通用户）</li>
 *   <li>实时数据统计（仅管理员）</li>
 *   <li>停车记录查询</li>
 * </ul>
 *
 * <p>API路径前缀: /api/parking</p>
 */
@Slf4j
@RestController
@RequestMapping("/parking")
@RequiredArgsConstructor
@CrossOrigin
public class ParkingController {

    private final ParkingRecordService recordService;
    private final ParkingAreaService areaService;
    private final ParkingSpaceService spaceService;
    private final SysUserService userService;

    /**
     * 获取停车场实时数据（仅管理员）
     *
     * @return 实时数据：当前停车数、今日入场/出场数、今日收入、总车位、空闲车位、占用率
     */
    @GetMapping("/realtime")
    public Result<Map<String, Object>> getRealTimeData(HttpServletRequest request) {
        // 检查是否为管理员
        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }
        Map<String, Object> data = recordService.getRealTimeData();
        return Result.success(data);
    }

    /**
     * 获取今日统计数据（仅管理员）
     *
     * @return 今日统计：入场数、出场数、收入、当前停车数
     */
    @GetMapping("/stats/today")
    public Result<Map<String, Object>> getTodayStats(HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }
        Map<String, Object> stats = recordService.getTodayStats();
        return Result.success(stats);
    }

    /**
     * 获取图表统计数据（仅管理员）
     *
     * @param type      统计类型：hourly-分时统计, daily-日统计, area-区域统计
     * @param startDate 开始日期 (yyyy-MM-dd)
     * @param endDate   结束日期 (yyyy-MM-dd)
     * @return 图表数据
     */
    @GetMapping("/chart")
    public Result<Map<String, Object>> getChartData(
            @RequestParam String type,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }
        Map<String, Object> data = recordService.getChartData(type, startDate, endDate);
        return Result.success(data);
    }

    /**
     * 车辆入场（仅管理员）
     *
     * @param plateNumber 车牌号 (必填)
     * @param gate        入口闸机编号，默认A1 (可选)
     * @return 创建的停车记录
     * @apiNote 如果车辆已在停车场内，返回错误
     */
    @PostMapping("/entry")
    public Result<ParkingRecord> entry(
            @RequestParam String plateNumber,
            @RequestParam(required = false, defaultValue = "A1") String gate,
            HttpServletRequest request) {

        // 检查是否为管理员
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以操作车辆入场");
        }

        log.info("车辆入场请求: plateNumber={}, gate={}", plateNumber, gate);

        if (!StringUtils.hasText(plateNumber)) {
            return Result.error("车牌号不能为空");
        }

        try {
            ParkingRecord record = recordService.entry(plateNumber, gate);
            return Result.success("入场成功", record);
        } catch (IllegalArgumentException e) {
            log.warn("入场参数错误: {}", e.getMessage());
            return Result.error(e.getMessage());
        } catch (RuntimeException e) {
            log.warn("入场失败: {}", e.getMessage());
            return Result.error(e.getMessage());
        }
    }

    /**
     * 车辆出场（仅管理员）
     *
     * @param plateNumber 车牌号 (必填)
     * @param gate        出口闸机编号，默认A1 (可选)
     * @return 出场结果：记录、停车时长、费用、是否需要支付
     * @apiNote 如果未找到入场记录，返回错误
     */
    @PostMapping("/exit")
    public Result<Map<String, Object>> exit(
            @RequestParam String plateNumber,
            @RequestParam(required = false, defaultValue = "A1") String gate,
            HttpServletRequest request) {

        // 检查是否为管理员
        if (!isAdmin(request)) {
            return Result.error(403, "只有管理员可以操作车辆出场");
        }

        log.info("车辆出场请求: plateNumber={}, gate={}", plateNumber, gate);

        if (!StringUtils.hasText(plateNumber)) {
            return Result.error("车牌号不能为空");
        }

        try {
            Map<String, Object> result = recordService.exit(plateNumber, gate);
            return Result.success("出场成功", result);
        } catch (IllegalArgumentException e) {
            log.warn("出场参数错误: {}", e.getMessage());
            return Result.error(e.getMessage());
        } catch (RuntimeException e) {
            log.warn("出场失败: {}", e.getMessage());
            return Result.error(e.getMessage());
        }
    }

    /**
     * 支付停车费用（仅普通用户）
     *
     * @param recordId  停车记录ID (必填)
     * @param payMethod 支付方式，默认"微信支付" (可选)
     * @return 支付结果
     * @apiNote 记录已支付或免费时返回错误；管理员不能支付
     */
    @PostMapping("/pay/{recordId}")
    public Result<Void> pay(
            @PathVariable Long recordId,
            @RequestParam(required = false, defaultValue = "微信支付") String payMethod,
            HttpServletRequest request) {

        log.info("支付请求: recordId={}, payMethod={}", recordId, payMethod);

        // 检查是否为管理员 - 管理员不能支付
        if (isAdmin(request)) {
            return Result.error(403, "管理员不能进行支付操作");
        }

        if (recordId == null) {
            return Result.error("记录ID不能为空");
        }

        try {
            recordService.pay(recordId, payMethod);
            Result<Void> result = Result.success();
            result.setMessage("支付成功");
            return result;
        } catch (IllegalArgumentException e) {
            log.warn("支付参数错误: {}", e.getMessage());
            return Result.error(e.getMessage());
        } catch (RuntimeException e) {
            log.warn("支付失败: {}", e.getMessage());
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取车辆当前停车状态
     *
     * @param plateNumber 车牌号
     * @return 当前停车记录，未在停车场返回null
     */
    @GetMapping("/current/{plateNumber}")
    public Result<ParkingRecord> getCurrentParking(@PathVariable String plateNumber) {
        if (!StringUtils.hasText(plateNumber)) {
            return Result.error("车牌号不能为空");
        }

        ParkingRecord record = recordService.getCurrentParking(plateNumber);
        return Result.success(record);
    }

    /**
     * 分页查询停车记录（管理员查看全部，普通用户查看自己的）
     *
     * @param page       页码，默认1
     * @param size       每页条数，默认10
     * @param plateNumber 车牌号模糊查询 (可选)
     * @param status     停车状态：0-停车中, 1-已完成 (可选)
     * @param payStatus  支付状态：0-未支付, 1-已支付, 2-免费 (可选)
     * @return 分页记录列表
     */
    @GetMapping("/records")
    public Result<Page<ParkingRecord>> pageRecords(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String plateNumber,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Integer payStatus,
            HttpServletRequest request) {

        // 参数校验
        if (page < 1) {
            page = 1;
        }
        if (size < 1 || size > 100) {
            size = 10;
        }

        // 如果不是管理员，只能查看与指定车牌相关的记录
        // 普通用户必须通过车牌号查询
        if (!isAdmin(request)) {
            if (!StringUtils.hasText(plateNumber)) {
                return Result.error("请提供车牌号进行查询");
            }
        }

        Page<ParkingRecord> result = recordService.pageRecords(
                new Page<>(page, size), plateNumber, status, payStatus);
        return Result.success(result);
    }

    /**
     * 查询指定车牌的所有停车记录（用于普通用户查询自己的记录）
     *
     * @param plateNumber 车牌号
     * @return 停车记录列表
     */
    @GetMapping("/records/by-plate/{plateNumber}")
    public Result<List<ParkingRecord>> getRecordsByPlateNumber(
            @PathVariable String plateNumber,
            HttpServletRequest request) {

        if (!StringUtils.hasText(plateNumber)) {
            return Result.error("车牌号不能为空");
        }

        log.info("查询车牌记录: plateNumber={}, isAdmin={}", plateNumber, isAdmin(request));

        // 获取该车牌的所有记录
        List<ParkingRecord> records = recordService.getRecordsByPlateNumber(plateNumber);
        return Result.success(records);
    }

    /**
     * 获取车辆详情（当前停车信息 + 近5次停车记录）
     *
     * @param plateNumber 车牌号
     * @return 车辆信息、当前停车状态、近5次停车记录
     */
    @GetMapping("/vehicle/detail/{plateNumber}")
    public Result<Map<String, Object>> getVehicleDetail(
            @PathVariable String plateNumber,
            HttpServletRequest request) {

        if (!StringUtils.hasText(plateNumber)) {
            return Result.error("车牌号不能为空");
        }

        log.info("查询车辆详情: plateNumber={}", plateNumber);

        Map<String, Object> detail = recordService.getVehicleDetail(plateNumber);
        return Result.success(detail);
    }

    /**
     * 获取所有停车区域（仅管理员）
     *
     * @return 区域列表
     */
    @GetMapping("/areas")
    public Result<List<ParkingArea>> getAreas(HttpServletRequest request) {
        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }
        List<ParkingArea> areas = areaService.listActive();
        return Result.success(areas);
    }

    /**
     * 获取车位列表（仅管理员）
     *
     * @param areaId 区域ID (可选，不传返回所有空闲车位)
     * @return 车位列表
     */
    @GetMapping("/spaces")
    public Result<List<ParkingSpace>> getSpaces(
            @RequestParam(required = false) Long areaId,
            HttpServletRequest request) {

        if (!isAdmin(request)) {
            return Result.error(403, "无权访问");
        }

        List<ParkingSpace> spaces;
        if (areaId != null) {
            spaces = spaceService.listByAreaId(areaId);
        } else {
            spaces = spaceService.listAllAvailable();
        }
        return Result.success(spaces);
    }

    // ==================== 私有方法 ====================

    /**
     * 检查当前用户是否为管理员
     */
    private boolean isAdmin(HttpServletRequest request) {
        // 从请求属性中获取用户ID（由JWT过滤器设置）
        Object userIdObj = request.getAttribute("userId");
        log.debug("Checking admin permission, userId from request: {}", userIdObj);

        if (userIdObj == null) {
            log.warn("No userId found in request attributes - user not authenticated");
            return false;
        }

        try {
            Long userId = Long.valueOf(userIdObj.toString());
            log.debug("Checking admin status for userId: {}", userId);

            SysUser user = userService.getById(userId);
            if (user == null) {
                log.warn("User not found in database for userId: {}", userId);
                return false;
            }

            Integer userType = user.getUserType();
            log.debug("User found: {}, userType: {}", user.getUsername(), userType);

            // userType: 1-管理员, 2-普通用户
            boolean isAdmin = userType != null && userType == 1;
            log.debug("Is admin: {}", isAdmin);
            return isAdmin;
        } catch (NumberFormatException e) {
            log.error("Invalid userId format: {}", userIdObj, e);
            return false;
        } catch (Exception e) {
            log.error("Error checking admin status", e);
            return false;
        }
    }
}

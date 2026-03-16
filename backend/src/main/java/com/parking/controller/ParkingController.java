package com.parking.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.parking.entity.ParkingArea;
import com.parking.entity.ParkingRecord;
import com.parking.entity.ParkingSpace;
import com.parking.service.ParkingAreaService;
import com.parking.service.ParkingRecordService;
import com.parking.service.ParkingSpaceService;
import com.parking.vo.Result;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 停车场Controller
 */
@RestController
@RequestMapping("/parking")
@RequiredArgsConstructor
@CrossOrigin
public class ParkingController {

    private final ParkingRecordService recordService;
    private final ParkingAreaService areaService;
    private final ParkingSpaceService spaceService;

    /**
     * 获取实时数据
     */
    @GetMapping("/realtime")
    public Result<?> getRealTimeData() {
        Map<String, Object> data = recordService.getRealTimeData();
        return Result.success(data);
    }

    /**
     * 获取今日统计
     */
    @GetMapping("/stats/today")
    public Result<?> getTodayStats() {
        Map<String, Object> stats = recordService.getTodayStats();
        return Result.success(stats);
    }

    /**
     * 获取图表数据
     */
    @GetMapping("/chart")
    public Result<?> getChartData(@RequestParam String type,
                                   @RequestParam(required = false) String startDate,
                                   @RequestParam(required = false) String endDate) {
        Map<String, Object> data = recordService.getChartData(type, startDate, endDate);
        return Result.success(data);
    }

    /**
     * 车辆入场
     */
    @PostMapping("/entry")
    public Result<?> entry(@RequestParam String plateNumber,
                           @RequestParam(required = false) String imagePath,
                           @RequestParam(required = false, defaultValue = "A1") String gate) {
        ParkingRecord record = recordService.entry(plateNumber, imagePath, gate);
        return Result.success("入场成功", record);
    }

    /**
     * 车辆出场
     */
    @PostMapping("/exit")
    public Result<?> exit(@RequestParam String plateNumber,
                          @RequestParam(required = false) String imagePath,
                          @RequestParam(required = false, defaultValue = "A1") String gate) {
        Map<String, Object> result = recordService.exit(plateNumber, imagePath, gate);
        return Result.success("出场成功", result);
    }

    /**
     * 支付
     */
    @PostMapping("/pay/{recordId}")
    public Result<?> pay(@PathVariable Long recordId,
                         @RequestParam(required = false, defaultValue = "微信支付") String payMethod) {
        recordService.pay(recordId, payMethod);
        return Result.success("支付成功");
    }

    /**
     * 获取当前停车记录
     */
    @GetMapping("/current/{plateNumber}")
    public Result<?> getCurrentParking(@PathVariable String plateNumber) {
        ParkingRecord record = recordService.getCurrentParking(plateNumber);
        return Result.success(record);
    }

    /**
     * 分页查询停车记录
     */
    @GetMapping("/records")
    public Result<?> pageRecords(@RequestParam(defaultValue = "1") Integer page,
                                  @RequestParam(defaultValue = "10") Integer size,
                                  @RequestParam(required = false) String plateNumber,
                                  @RequestParam(required = false) Integer status,
                                  @RequestParam(required = false) Integer payStatus) {
        Page<ParkingRecord> result = recordService.pageRecords(
                new Page<>(page, size), plateNumber, status, payStatus);
        return Result.success(result);
    }

    /**
     * 获取所有区域
     */
    @GetMapping("/areas")
    public Result<?> getAreas() {
        List<ParkingArea> areas = areaService.listActive();
        return Result.success(areas);
    }

    /**
     * 获取区域车位
     */
    @GetMapping("/spaces")
    public Result<?> getSpaces(@RequestParam(required = false) Long areaId) {
        List<ParkingSpace> spaces;
        if (areaId != null) {
            spaces = spaceService.listByAreaId(areaId);
        } else {
            spaces = spaceService.listAllAvailable();
        }
        return Result.success(spaces);
    }
}

package com.parking.controller;

import com.parking.service.ParkingRecordService;
import com.parking.vo.Result;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 仿真模拟Controller
 */
@RestController
@RequestMapping("/simulation")
@RequiredArgsConstructor
@CrossOrigin
public class SimulationController {

    private final ParkingRecordService recordService;

    // 模拟车牌库
    private static final String[] PROVINCES = {"京", "沪", "津", "渝", "冀", "豫", "云", "辽", "黑", "湘", "皖", "鲁", "新", "苏", "浙", "赣", "鄂", "桂", "甘", "晋", "蒙", "陕", "吉", "闽", "贵", "粤", "青", "藏", "川", "宁", "琼"};
    private static final String[] LETTERS = {"A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
    private static final String[] NUMBERS = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};

    /**
     * 开始仿真
     */
    @PostMapping("/start")
    public Result<?> startSimulation(@RequestBody SimulationRequest request) {
        List<Map<String, Object>> results = new ArrayList<>();
        Random random = new Random();

        for (int i = 0; i < request.getCount(); i++) {
            Map<String, Object> result = new HashMap<>();
            String plateNumber = generatePlateNumber();
            result.put("plateNumber", plateNumber);
            result.put("success", true);
            result.put("confidence", 85 + random.nextInt(15));
            result.put("processTime", 30 + random.nextInt(40));

            try {
                if ("entry".equals(request.getEventType())) {
                    // 仿真入场
                    recordService.entry(plateNumber);
                    result.put("eventType", "entry");
                    result.put("message", "入场成功");
                } else {
                    // 仿真出场
                    Map<String, Object> exitResult = recordService.exit(plateNumber);
                    result.put("eventType", "exit");
                    result.put("fee", exitResult.get("fee"));
                    result.put("message", "出场成功");
                }
            } catch (Exception e) {
                result.put("success", false);
                result.put("message", e.getMessage());
            }

            results.add(result);

            // 模拟处理延迟
            if (request.getDelay() != null && request.getDelay() > 0) {
                try {
                    Thread.sleep(request.getDelay());
                } catch (InterruptedException ignored) {
                }
            }
        }

        return Result.success(results);
    }

    /**
     * 批量生成车牌
     */
    @GetMapping("/plates")
    public Result<?> generatePlates(@RequestParam(defaultValue = "10") int count) {
        List<String> plates = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            plates.add(generatePlateNumber());
        }
        return Result.success(plates);
    }

    /**
     * 获取仿真统计
     */
    @GetMapping("/stats")
    public Result<?> getSimulationStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalSimulations", 0);
        stats.put("successRate", 94.5);
        stats.put("avgTime", 45);
        stats.put("accuracy", 96.8);
        return Result.success(stats);
    }

    /**
     * 生成随机车牌号
     */
    private String generatePlateNumber() {
        Random random = new Random();
        StringBuilder sb = new StringBuilder();

        // 省份
        sb.append(PROVINCES[random.nextInt(PROVINCES.length)]);
        // 城市代码
        sb.append(LETTERS[random.nextInt(LETTERS.length)]);
        // 分隔符
        sb.append("·");
        // 5位号码
        for (int i = 0; i < 5; i++) {
            if (random.nextBoolean()) {
                sb.append(NUMBERS[random.nextInt(NUMBERS.length)]);
            } else {
                sb.append(LETTERS[random.nextInt(LETTERS.length)]);
            }
        }

        return sb.toString();
    }

    /**
     * 仿真请求DTO
     */
    @lombok.Data
    public static class SimulationRequest {
        private Integer count;
        private String eventType;
        private String mode;
        private String difficulty;
        private Integer delay;
    }
}

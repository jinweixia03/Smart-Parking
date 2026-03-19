package com.parking.controller;

import com.parking.service.AlgorithmService;
import com.parking.vo.Result;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * 算法服务Controller
 * 提供车牌识别相关接口
 */
@Slf4j
@RestController
@RequestMapping("/algorithm")
@RequiredArgsConstructor
@CrossOrigin
public class AlgorithmController {

    private final AlgorithmService algorithmService;

    /**
     * 检测车牌位置
     */
    @PostMapping("/detect")
    public Result<Map<String, Object>> detect(@RequestParam("image") MultipartFile image) {
        log.info("车牌检测请求: filename={}, size={}", image.getOriginalFilename(), image.getSize());
        Map<String, Object> result = algorithmService.detectPlate(image);
        return parseResult(result);
    }

    /**
     * 识别车牌号码
     */
    @PostMapping("/recognize")
    public Result<Map<String, Object>> recognize(@RequestParam("image") MultipartFile image) {
        log.info("车牌识别请求: filename={}, size={}", image.getOriginalFilename(), image.getSize());
        Map<String, Object> result = algorithmService.recognizePlate(image);
        return parseResult(result);
    }

    /**
     * 入场识别（检测+识别）
     */
    @PostMapping("/entry")
    public Result<Map<String, Object>> entryRecognize(@RequestParam("image") MultipartFile image) {
        log.info("入场识别请求: filename={}, size={}", image.getOriginalFilename(), image.getSize());
        Map<String, Object> result = algorithmService.entryRecognize(image);
        return parseResult(result);
    }

    /**
     * 出场识别（检测+识别）
     */
    @PostMapping("/exit")
    public Result<Map<String, Object>> exitRecognize(
            @RequestParam("image") MultipartFile image,
            @RequestParam(required = false) String plateNumber) {
        log.info("出场识别请求: filename={}, size={}, plateNumber={}",
                image.getOriginalFilename(), image.getSize(), plateNumber);
        Map<String, Object> result = algorithmService.exitRecognize(image, plateNumber);
        return parseResult(result);
    }

    /**
     * 获取算法模型信息
     */
    @GetMapping("/model-info")
    public Result<Map<String, Object>> getModelInfo() {
        Map<String, Object> result = algorithmService.getModelInfo();
        return parseResult(result);
    }

    /**
     * 健康检查
     */
    @GetMapping("/health")
    public Result<Boolean> healthCheck() {
        boolean healthy = algorithmService.healthCheck();
        return Result.success(healthy);
    }

    /**
     * 解析算法服务返回结果
     */
    @SuppressWarnings("unchecked")
    private Result<Map<String, Object>> parseResult(Map<String, Object> result) {
        if (result == null) {
            return Result.error("算法服务返回空结果");
        }
        Object code = result.get("code");
        Object message = result.get("message");
        Object data = result.get("data");

        if (code instanceof Integer && (Integer) code == 200) {
            return Result.success(message != null ? message.toString() : "success", (Map<String, Object>) data);
        } else {
            return Result.error(message != null ? message.toString() : "算法服务调用失败");
        }
    }
}

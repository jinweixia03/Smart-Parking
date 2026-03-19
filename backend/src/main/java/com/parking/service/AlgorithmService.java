package com.parking.service;

import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * 算法服务接口
 * 对接Python车牌识别算法服务
 */
public interface AlgorithmService {

    /**
     * 检测车牌位置
     * @param image 图片文件
     * @return 检测结果
     */
    Map<String, Object> detectPlate(MultipartFile image);

    /**
     * 识别车牌号码
     * @param image 图片文件
     * @return 识别结果：车牌号、置信度等
     */
    Map<String, Object> recognizePlate(MultipartFile image);

    /**
     * 入场识别（检测+识别）
     * @param image 入场图片
     * @return 识别结果
     */
    Map<String, Object> entryRecognize(MultipartFile image);

    /**
     * 出场识别（检测+识别）
     * @param image 出场图片
     * @param plateNumber 预期车牌号（可选，用于验证）
     * @return 识别结果
     */
    Map<String, Object> exitRecognize(MultipartFile image, String plateNumber);

    /**
     * 获取算法模型信息
     * @return 模型信息
     */
    Map<String, Object> getModelInfo();

    /**
     * 健康检查
     * @return 是否可用
     */
    boolean healthCheck();
}

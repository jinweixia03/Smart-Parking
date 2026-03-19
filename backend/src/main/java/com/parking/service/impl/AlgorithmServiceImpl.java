package com.parking.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.parking.service.AlgorithmService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * 算法服务实现
 * 通过HTTP调用Python算法服务
 */
@Slf4j
@Service
public class AlgorithmServiceImpl implements AlgorithmService {

    @Value("${algorithm.service.url:http://localhost:5000}")
    private String algorithmServiceUrl;

    private final RestTemplate restTemplate = createRestTemplate();

    private static RestTemplate createRestTemplate() {
        org.springframework.http.client.SimpleClientHttpRequestFactory factory =
            new org.springframework.http.client.SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(5000);
        factory.setReadTimeout(120000); // 模型推理最多等2分钟
        return new RestTemplate(factory);
    }
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public Map<String, Object> detectPlate(MultipartFile image) {
        try {
            String url = algorithmServiceUrl + "/api/detect";
            return callAlgorithmService(url, image);
        } catch (Exception e) {
            log.error("车牌检测失败: {}", e.getMessage());
            return createErrorResult("检测失败: " + e.getMessage());
        }
    }

    @Override
    public Map<String, Object> recognizePlate(MultipartFile image) {
        try {
            String url = algorithmServiceUrl + "/api/recognize";
            return callAlgorithmService(url, image);
        } catch (Exception e) {
            log.error("车牌识别失败: {}", e.getMessage());
            return createErrorResult("识别失败: " + e.getMessage());
        }
    }

    @Override
    public Map<String, Object> entryRecognize(MultipartFile image) {
        try {
            String url = algorithmServiceUrl + "/api/parking/entry";
            return callAlgorithmService(url, image);
        } catch (Exception e) {
            log.error("入场识别失败: {}", e.getMessage());
            return createErrorResult("入场识别失败: " + e.getMessage());
        }
    }

    @Override
    public Map<String, Object> exitRecognize(MultipartFile image, String plateNumber) {
        try {
            String url = algorithmServiceUrl + "/api/parking/exit";
            // 如果有预期车牌号，添加到请求
            if (plateNumber != null && !plateNumber.isEmpty()) {
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.MULTIPART_FORM_DATA);

                MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
                body.add("image", new MultipartFileResource(image));
                body.add("plate_number", plateNumber);

                HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);
                ResponseEntity<Map> response = restTemplate.postForEntity(url, requestEntity, Map.class);
                return response.getBody();
            }
            return callAlgorithmService(url, image);
        } catch (Exception e) {
            log.error("出场识别失败: {}", e.getMessage());
            return createErrorResult("出场识别失败: " + e.getMessage());
        }
    }

    @Override
    public Map<String, Object> getModelInfo() {
        try {
            String url = algorithmServiceUrl + "/api/model/info";
            ResponseEntity<Map> response = restTemplate.getForEntity(url, Map.class);
            return response.getBody();
        } catch (Exception e) {
            log.error("获取模型信息失败: {}", e.getMessage());
            return createErrorResult("获取模型信息失败: " + e.getMessage());
        }
    }

    @Override
    public boolean healthCheck() {
        try {
            String url = algorithmServiceUrl + "/api/health";
            ResponseEntity<Map> response = restTemplate.getForEntity(url, Map.class);
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                Object code = response.getBody().get("code");
                return code != null && code.equals(200);
            }
            return false;
        } catch (Exception e) {
            log.warn("算法服务健康检查失败: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 调用算法服务
     */
    private Map<String, Object> callAlgorithmService(String url, MultipartFile image) throws IOException {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);

        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("image", new MultipartFileResource(image));

        HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);
        ResponseEntity<Map> response = restTemplate.postForEntity(url, requestEntity, Map.class);

        return response.getBody();
    }

    /**
     * 创建错误结果
     */
    private Map<String, Object> createErrorResult(String message) {
        Map<String, Object> result = new HashMap<>();
        result.put("code", 500);
        result.put("message", message);
        result.put("data", null);
        return result;
    }

    /**
     * MultipartFile包装类，用于RestTemplate上传
     */
    private static class MultipartFileResource extends ByteArrayResource {
        private final String filename;

        public MultipartFileResource(MultipartFile file) throws IOException {
            super(file.getBytes());
            this.filename = file.getOriginalFilename();
        }

        @Override
        public String getFilename() {
            return filename;
        }
    }
}

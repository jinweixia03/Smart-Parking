package com.parking.service.impl;

import com.parking.config.UploadConfig;
import com.parking.service.FileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

/**
 * 文件服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class FileServiceImpl implements FileService {

    private final UploadConfig uploadConfig;

    // 允许的图片类型
    private static final String[] ALLOWED_IMAGE_TYPES = {
            "image/jpeg", "image/png", "image/gif", "image/bmp", "image/webp"
    };

    // 最大文件大小：10MB
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024;

    @Override
    public String uploadImage(MultipartFile file, String type) {
        if (file == null || file.isEmpty()) {
            log.warn("上传文件为空");
            return null;
        }

        // 校验文件大小
        if (file.getSize() > MAX_FILE_SIZE) {
            log.warn("文件大小超过限制: {} bytes", file.getSize());
            throw new IllegalArgumentException("文件大小不能超过10MB");
        }

        // 校验文件类型
        String contentType = file.getContentType();
        if (!isAllowedImageType(contentType)) {
            log.warn("不支持的文件类型: {}", contentType);
            throw new IllegalArgumentException("只支持 jpg, png, gif, bmp, webp 格式的图片");
        }

        // 生成文件名：类型_时间戳_UUID.扩展名
        String originalFilename = file.getOriginalFilename();
        String extension = getFileExtension(originalFilename);
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        String filename = String.format("%s_%s_%s%s", type, timestamp, uuid, extension);

        // 根据类型选择存储目录
        String basePath;
        switch (type) {
            case "plates":
                basePath = uploadConfig.getPlatesPath();
                break;
            case "scenes":
            case "images":
                basePath = uploadConfig.getImagesPath();
                break;
            default:
                basePath = uploadConfig.getAbsolutePath();
        }

        // 保存文件
        Path filePath = Paths.get(basePath, filename);
        try {
            File dest = filePath.toFile();
            file.transferTo(dest);
            log.info("文件上传成功: {}", filePath);

            // 返回相对URL，例如：/uploads/plates/plates_20240318120000_12345678.jpg
            return String.format("/uploads/%s/%s",
                    type.equals("plates") ? "plates" : "images",
                    filename);
        } catch (IOException e) {
            log.error("文件保存失败: {}", e.getMessage(), e);
            throw new RuntimeException("文件保存失败: " + e.getMessage());
        }
    }

    @Override
    public boolean deleteFile(String fileUrl) {
        if (!StringUtils.hasText(fileUrl)) {
            return false;
        }

        String absolutePath = getAbsolutePath(fileUrl);
        if (absolutePath == null) {
            return false;
        }

        File file = new File(absolutePath);
        if (file.exists()) {
            boolean deleted = file.delete();
            if (deleted) {
                log.info("文件删除成功: {}", absolutePath);
            } else {
                log.warn("文件删除失败: {}", absolutePath);
            }
            return deleted;
        }
        return false;
    }

    @Override
    public String getAbsolutePath(String fileUrl) {
        if (!StringUtils.hasText(fileUrl)) {
            return null;
        }

        // 去除URL前缀，得到相对路径
        String relativePath = fileUrl;
        if (fileUrl.startsWith("/uploads/")) {
            relativePath = fileUrl.substring("/uploads/".length());
        } else if (fileUrl.startsWith("uploads/")) {
            relativePath = fileUrl.substring("uploads/".length());
        }

        return Paths.get(uploadConfig.getAbsolutePath(), relativePath).toString();
    }

    /**
     * 校验图片类型
     */
    private boolean isAllowedImageType(String contentType) {
        if (!StringUtils.hasText(contentType)) {
            return false;
        }
        for (String allowedType : ALLOWED_IMAGE_TYPES) {
            if (allowedType.equals(contentType)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String filename) {
        if (!StringUtils.hasText(filename)) {
            return ".jpg";
        }
        int lastDotIndex = filename.lastIndexOf('.');
        if (lastDotIndex > 0 && lastDotIndex < filename.length() - 1) {
            return filename.substring(lastDotIndex).toLowerCase();
        }
        return ".jpg";
    }
}

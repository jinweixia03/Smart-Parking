package com.parking.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import jakarta.annotation.PostConstruct;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * 文件上传配置
 *
 * <p>配置说明：</p>
 * <ul>
 *   <li>上传文件存储在项目的 uploads 目录下（相对路径）</li>
 *   <li>按文件类型分子目录：images, plates, logs</li>
 *   <li>支持通过 /uploads/** 访问上传的文件</li>
 * </ul>
 */
@Slf4j
@Configuration
public class UploadConfig implements WebMvcConfigurer {

    /**
     * 上传根目录（相对路径）
     */
    @Value("${upload.path:uploads}")
    private String uploadPath;

    /**
     * 图片访问URL前缀
     */
    @Value("${upload.url-prefix:/uploads}")
    private String urlPrefix;

    /**
     * 获取绝对路径
     */
    public String getAbsolutePath() {
        // 获取项目根目录
        String projectRoot = System.getProperty("user.dir");
        Path path = Paths.get(projectRoot, uploadPath);
        return path.toAbsolutePath().normalize().toString();
    }

    /**
     * 获取图片子目录
     */
    public String getImagesPath() {
        return Paths.get(getAbsolutePath(), "images").toString();
    }

    /**
     * 获取车牌识别图片目录
     */
    public String getPlatesPath() {
        return Paths.get(getAbsolutePath(), "plates").toString();
    }

    /**
     * 获取日志目录
     */
    public String getLogsPath() {
        return Paths.get(getAbsolutePath(), "logs").toString();
    }

    /**
     * 初始化上传目录
     */
    @PostConstruct
    public void init() {
        try {
            // 创建上传根目录
            createDirectory(getAbsolutePath());
            // 创建子目录
            createDirectory(getImagesPath());
            createDirectory(getPlatesPath());
            createDirectory(getLogsPath());

            log.info("上传目录初始化完成: {}", getAbsolutePath());
        } catch (Exception e) {
            log.error("创建上传目录失败: {}", e.getMessage(), e);
        }
    }

    /**
     * 创建目录
     */
    private void createDirectory(String path) {
        File dir = new File(path);
        if (!dir.exists()) {
            boolean created = dir.mkdirs();
            if (created) {
                log.debug("创建目录: {}", path);
            }
        }
    }

    /**
     * 配置静态资源映射
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 将 /uploads/** 映射到文件系统的 uploads 目录
        String uploadAbsolutePath = "file:" + getAbsolutePath() + "/";
        registry.addResourceHandler(urlPrefix + "/**")
                .addResourceLocations(uploadAbsolutePath);

        log.info("配置静态资源映射: {} -> {}", urlPrefix, uploadAbsolutePath);
    }
}

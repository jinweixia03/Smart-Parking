package com.parking.controller;

import com.parking.service.FileService;
import com.parking.vo.Result;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * 文件上传Controller
 *
 * <p>提供文件上传相关接口：</p>
 * <ul>
 *   <li>图片上传（车牌识别图片、场景图片）</li>
 *   <li>文件删除</li>
 * </ul>
 */
@Slf4j
@RestController
@RequestMapping("/file")
@RequiredArgsConstructor
@CrossOrigin
public class FileController {

    private final FileService fileService;

    /**
     * 上传车牌识别图片
     *
     * @param file 图片文件
     * @return 图片访问URL
     */
    @PostMapping("/upload/plate")
    public Result<String> uploadPlateImage(@RequestParam("file") MultipartFile file) {
        log.info("上传车牌识别图片: filename={}, size={}",
                file.getOriginalFilename(), file.getSize());

        try {
            String url = fileService.uploadImage(file, "plates");
            return Result.success("上传成功", url);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        } catch (Exception e) {
            log.error("上传失败: {}", e.getMessage(), e);
            return Result.error("上传失败: " + e.getMessage());
        }
    }

    /**
     * 上传场景图片
     *
     * @param file 图片文件
     * @return 图片访问URL
     */
    @PostMapping("/upload/scene")
    public Result<String> uploadSceneImage(@RequestParam("file") MultipartFile file) {
        log.info("上传场景图片: filename={}, size={}",
                file.getOriginalFilename(), file.getSize());

        try {
            String url = fileService.uploadImage(file, "scenes");
            return Result.success("上传成功", url);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        } catch (Exception e) {
            log.error("上传失败: {}", e.getMessage(), e);
            return Result.error("上传失败: " + e.getMessage());
        }
    }

    /**
     * 通用图片上传
     *
     * @param file 图片文件
     * @param type 图片类型: plates, scenes, images
     * @return 图片访问URL
     */
    @PostMapping("/upload")
    public Result<String> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(defaultValue = "images") String type) {
        log.info("上传图片: filename={}, type={}, size={}",
                file.getOriginalFilename(), type, file.getSize());

        try {
            String url = fileService.uploadImage(file, type);
            return Result.success("上传成功", url);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        } catch (Exception e) {
            log.error("上传失败: {}", e.getMessage(), e);
            return Result.error("上传失败: " + e.getMessage());
        }
    }

    /**
     * 删除文件
     *
     * @param fileUrl 文件URL
     * @return 是否成功
     */
    @DeleteMapping("/delete")
    public Result<Void> deleteFile(@RequestParam String fileUrl) {
        log.info("删除文件: {}", fileUrl);

        boolean success = fileService.deleteFile(fileUrl);
        if (success) {
            return Result.success();
        } else {
            return Result.error("文件删除失败");
        }
    }
}

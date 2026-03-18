package com.parking.service;

import org.springframework.web.multipart.MultipartFile;

/**
 * 文件服务接口
 */
public interface FileService {

    /**
     * 上传图片
     *
     * @param file 图片文件
     * @param type 图片类型：plates-车牌识别图, scenes-场景图
     * @return 文件访问URL
     */
    String uploadImage(MultipartFile file, String type);

    /**
     * 删除文件
     *
     * @param fileUrl 文件URL
     * @return 是否成功
     */
    boolean deleteFile(String fileUrl);

    /**
     * 获取文件的绝对路径
     *
     * @param fileUrl 文件URL
     * @return 绝对路径
     */
    String getAbsolutePath(String fileUrl);
}

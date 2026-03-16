package com.parking;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * 智能停车场管理系统 - 主启动类
 *
 * @author Parking Team
 * @version 1.0.0
 */
@SpringBootApplication
@MapperScan("com.parking.mapper")
@EnableCaching
@EnableAsync
@EnableScheduling
public class ParkingSystemApplication {

    public static void main(String[] args) {
        SpringApplication.run(ParkingSystemApplication.class, args);
        System.out.println("========================================");
        System.out.println("  智能停车场管理系统启动成功!");
        System.out.println("  API文档: http://localhost:8080/api/doc.html");
        System.out.println("========================================");
    }
}

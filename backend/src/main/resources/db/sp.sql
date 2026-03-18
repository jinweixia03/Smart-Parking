/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80408 (8.4.8)
 Source Host           : localhost:3306
 Source Schema         : smart_parking

 Target Server Type    : MySQL
 Target Server Version : 80408 (8.4.8)
 File Encoding         : 65001

 Date: 18/03/2026 01:56:42
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 删除顺序：先删除有外键的表，再删除被引用的表
DROP TABLE IF EXISTS `parking_record`;
DROP TABLE IF EXISTS `parking_space`;
DROP TABLE IF EXISTS `parking_area`;
DROP TABLE IF EXISTS `fee_rule`;
DROP TABLE IF EXISTS `sys_user`;

-- ==================== 第一批：创建无依赖的表 ====================

-- ----------------------------
-- Table structure for fee_rule
-- ----------------------------
CREATE TABLE `fee_rule`  (
  `rule_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `rule_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '规则名称',
  `free_minutes` int UNSIGNED NULL DEFAULT 15 COMMENT '免费时长(分钟)',
  `first_hour_fee` decimal(8, 2) NULL DEFAULT 5.00 COMMENT '首小时费用',
  `extra_hour_fee` decimal(8, 2) NULL DEFAULT 3.00 COMMENT '超出每小时费用',
  `daily_max_fee` decimal(10, 2) NULL DEFAULT 50.00 COMMENT '24小时封顶',
  `is_default` tinyint NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT 1,
  PRIMARY KEY (`rule_id`) USING BTREE,
  CONSTRAINT `chk_fee_positive` CHECK ((`first_hour_fee` >= 0) and (`extra_hour_fee` >= 0) and (`daily_max_fee` >= 0)),
  CONSTRAINT `chk_free_minutes` CHECK (`free_minutes` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '收费规则表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
CREATE TABLE `sys_user`  (
  `user_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `user_type` tinyint NOT NULL DEFAULT 2 COMMENT '用户类型: 1-管理员 2-普通用户',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone` ASC) USING BTREE,
  CONSTRAINT `chk_user_status` CHECK (`status` in (0,1))
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for parking_area
-- ----------------------------
CREATE TABLE `parking_area`  (
  `area_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '区域ID',
  `area_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '区域编号',
  `area_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '区域名称',
  `total_spaces` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '总车位数',
  `available_spaces` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '可用车位数',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  PRIMARY KEY (`area_id`) USING BTREE,
  UNIQUE INDEX `uk_area_code`(`area_code` ASC) USING BTREE,
  CONSTRAINT `chk_available` CHECK (`available_spaces` <= `total_spaces`)
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '停车区域表' ROW_FORMAT = Dynamic;

-- ==================== 第二批：创建依赖 parking_area 的表 ====================

-- ----------------------------
-- Table structure for parking_space
-- ----------------------------
CREATE TABLE `parking_space`  (
  `space_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '车位ID',
  `area_id` bigint UNSIGNED NOT NULL COMMENT '所属区域ID',
  `floor` tinyint UNSIGNED NOT NULL DEFAULT 1 COMMENT '楼层: 1-一层 2-二层',
  `space_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '车位编号',
  `space_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '普通' COMMENT '车位类型',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0-空闲 1-占用',
  `current_plate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前停放车牌',
  `entry_time` datetime NULL DEFAULT NULL COMMENT '入场时间',
  PRIMARY KEY (`space_id`) USING BTREE,
  UNIQUE INDEX `uk_area_space`(`area_id` ASC, `space_code` ASC) USING BTREE,
  INDEX `idx_space_area`(`area_id` ASC) USING BTREE,
  INDEX `idx_space_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_space_area` FOREIGN KEY (`area_id`) REFERENCES `parking_area` (`area_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `chk_space_status` CHECK (`status` in (0,1)),
  CONSTRAINT `chk_space_type` CHECK (`space_type` in (_utf8mb4'普通',_utf8mb4'VIP',_utf8mb4'充电桩',_utf8mb4'大型车',_utf8mb4'临时专用',_utf8mb4'访客专用'))
) ENGINE = InnoDB AUTO_INCREMENT = 91 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '停车位表' ROW_FORMAT = Dynamic;

-- ==================== 第三批：创建依赖 sys_user 和 parking_space 的表 ====================

-- ----------------------------
-- Table structure for parking_record
-- ----------------------------
CREATE TABLE `parking_record`  (
  `record_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `plate_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '车牌号',
  `space_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '车位ID',
  `entry_time` datetime NOT NULL COMMENT '入场时间',
  `entry_gate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '入口',
  `exit_time` datetime NULL DEFAULT NULL COMMENT '出场时间',
  `exit_gate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出口',
  `parking_minutes` int UNSIGNED NULL DEFAULT NULL COMMENT '停车时长(分钟)',
  `fee_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '应收费用',
  `payable_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '应付金额',
  `paid_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '实付金额',
  `pay_status` tinyint NOT NULL DEFAULT 0 COMMENT '支付状态: 0-未支付 1-已支付 2-免费',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `pay_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付方式',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0-停车中 1-已完成',
  PRIMARY KEY (`record_id`) USING BTREE,
  INDEX `idx_record_space`(`space_id` ASC) USING BTREE,
  INDEX `idx_record_plate`(`plate_number` ASC) USING BTREE,
  INDEX `idx_record_entry`(`entry_time` ASC) USING BTREE,
  INDEX `idx_record_status`(`status` ASC) USING BTREE,
  INDEX `idx_record_pay`(`pay_status` ASC) USING BTREE,
  INDEX `idx_record_status_entry`(`status`, `entry_time` DESC) USING BTREE,
  INDEX `idx_record_pay_entry`(`pay_status`, `entry_time` DESC) USING BTREE,
  INDEX `idx_record_plate_entry`(`plate_number`, `entry_time` DESC) USING BTREE,
  CONSTRAINT `fk_record_space` FOREIGN KEY (`space_id`) REFERENCES `parking_space` (`space_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `chk_pay_status` CHECK (`pay_status` in (0,1,2)),
  CONSTRAINT `chk_record_status` CHECK (`status` in (0,1)),
  CONSTRAINT `chk_time_valid` CHECK ((`exit_time` is null) or (`exit_time` >= `entry_time`))
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '停车记录表' ROW_FORMAT = Dynamic;

-- ==================== 创建触发器 ====================

delimiter ;;

CREATE TRIGGER `trg_space_insert` AFTER INSERT ON `parking_space` FOR EACH ROW BEGIN
    UPDATE parking_area SET total_spaces = total_spaces + 1 WHERE area_id = NEW.area_id;
    IF NEW.status = 0 THEN
        UPDATE parking_area SET available_spaces = available_spaces + 1 WHERE area_id = NEW.area_id;
    END IF;
END;;

CREATE TRIGGER `trg_space_change` AFTER UPDATE ON `parking_space` FOR EACH ROW BEGIN
    IF OLD.status != NEW.status THEN
        IF NEW.status = 0 THEN
            UPDATE parking_area SET available_spaces = available_spaces + 1 WHERE area_id = NEW.area_id;
        ELSE
            UPDATE parking_area SET available_spaces = available_spaces - 1 WHERE area_id = NEW.area_id;
        END IF;
    END IF;
END;;

delimiter ;
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
  `area_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '普通' COMMENT '区域类型: 普通/VIP/充电桩/大型车/临时专用/访客专用',
  PRIMARY KEY (`area_id`) USING BTREE,
  UNIQUE INDEX `uk_area_code`(`area_code` ASC) USING BTREE,
  CONSTRAINT `chk_area_type` CHECK (`area_type` in (_utf8mb4'普通',_utf8mb4'VIP',_utf8mb4'充电桩',_utf8mb4'大型车',_utf8mb4'临时专用',_utf8mb4'访客专用'))
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '停车区域表' ROW_FORMAT = Dynamic;

-- ==================== 第二批：创建依赖 parking_area 的表 ====================

-- ----------------------------
-- Table structure for parking_space
-- ----------------------------
CREATE TABLE `parking_space`  (
  `space_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '车位ID',
  `floor` tinyint UNSIGNED NOT NULL DEFAULT 1 COMMENT '楼层: 1-一层 2-二层',
  `space_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '车位编号',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0-空闲 1-占用',
  `current_plate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前停放车牌',
  PRIMARY KEY (`space_id`) USING BTREE,
  UNIQUE INDEX `uk_space_code`(`space_code` ASC) USING BTREE,
  INDEX `idx_space_status`(`status` ASC) USING BTREE,
  CONSTRAINT `chk_space_status` CHECK (`status` in (0,1))
) ENGINE = InnoDB AUTO_INCREMENT = 509 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '停车位表' ROW_FORMAT = Dynamic;

-- ==================== 第三批：创建依赖 sys_user 和 parking_space 的表 ====================

-- ----------------------------
-- Table structure for parking_record
-- ----------------------------
CREATE TABLE `parking_record`  (
  `record_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `plate_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '车牌号',
  `space_id` bigint UNSIGNED NOT NULL COMMENT '车位ID',
  `entry_time` datetime NOT NULL COMMENT '入场时间',
  `exit_time` datetime NULL DEFAULT NULL COMMENT '出场时间',
  `fee_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '应收费用',
  `pay_status` tinyint NOT NULL DEFAULT 0 COMMENT '支付状态: 0-未支付(停车中) 1-已支付(已完成) 2-免费(已完成)',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  PRIMARY KEY (`record_id`) USING BTREE,
  INDEX `idx_record_space`(`space_id` ASC) USING BTREE,
  INDEX `idx_record_plate`(`plate_number` ASC) USING BTREE,
  INDEX `idx_record_entry`(`entry_time` ASC) USING BTREE,
  INDEX `idx_record_pay`(`pay_status` ASC) USING BTREE,
  INDEX `idx_record_pay_entry`(`pay_status`, `entry_time` DESC) USING BTREE,
  INDEX `idx_record_plate_entry`(`plate_number`, `entry_time` DESC) USING BTREE,
  CONSTRAINT `fk_record_space` FOREIGN KEY (`space_id`) REFERENCES `parking_space` (`space_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `chk_pay_status` CHECK (`pay_status` in (0,1,2)),
  CONSTRAINT `chk_time_valid` CHECK ((`exit_time` is null) or (`exit_time` >= `entry_time`))
) ENGINE = InnoDB AUTO_INCREMENT = 1001 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '停车记录表' ROW_FORMAT = Dynamic;

-- ==================== 创建函数：计算停车费用 ====================
-- 收费规则（标准收费-日间）：
--   - 免费时长: 15分钟
--   - 首小时费用: 5元
--   - 额外每小时: 3元
--   - 24小时封顶: 50元
-- ====================

DELIMITER ;;

CREATE FUNCTION IF NOT EXISTS `calculate_parking_fee`(
    p_entry_time DATETIME,
    p_exit_time DATETIME
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_minutes INT;
    DECLARE v_hours INT;
    DECLARE v_days INT;
    DECLARE v_remaining_hours INT;
    DECLARE v_fee DECIMAL(10,2);
    DECLARE v_daily_fee DECIMAL(10,2);
    DECLARE v_remaining_fee DECIMAL(10,2);

    -- 免费分钟数
    DECLARE FREE_MINUTES INT DEFAULT 15;
    -- 首小时费用
    DECLARE FIRST_HOUR_FEE DECIMAL(10,2) DEFAULT 5.00;
    -- 额外每小时费用
    DECLARE EXTRA_HOUR_FEE DECIMAL(10,2) DEFAULT 3.00;
    -- 24小时封顶
    DECLARE DAILY_MAX_FEE DECIMAL(10,2) DEFAULT 50.00;
    -- 每小时分钟数
    DECLARE MINUTES_PER_HOUR INT DEFAULT 60;
    -- 每天小时数
    DECLARE HOURS_PER_DAY INT DEFAULT 24;

    -- 计算停车分钟数
    SET v_minutes = TIMESTAMPDIFF(MINUTE, p_entry_time, p_exit_time);

    -- 免费时长内
    IF v_minutes <= FREE_MINUTES THEN
        RETURN 0.00;
    END IF;

    -- 计算小时数，不足1小时按1小时算
    SET v_hours = CEIL(v_minutes / MINUTES_PER_HOUR);

    -- 计算天数和剩余小时
    SET v_days = v_hours / HOURS_PER_DAY;
    SET v_remaining_hours = v_hours % HOURS_PER_DAY;

    -- 计算基础费用
    IF v_remaining_hours <= 1 THEN
        SET v_remaining_fee = FIRST_HOUR_FEE;
    ELSE
        SET v_remaining_fee = FIRST_HOUR_FEE + (EXTRA_HOUR_FEE * (v_remaining_hours - 1));
    END IF;

    -- 应用封顶规则
    IF v_remaining_fee > DAILY_MAX_FEE THEN
        SET v_remaining_fee = DAILY_MAX_FEE;
    END IF;

    -- 总费用 = 完整天数费用 + 剩余时间费用
    SET v_fee = (v_days * DAILY_MAX_FEE) + v_remaining_fee;

    RETURN v_fee;
END;;

DELIMITER ;

-- ==================== 创建触发器（已移除，统计从space表实时计算） ====================

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
CREATE TABLE IF NOT EXISTS `operation_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `operator_type` int NULL DEFAULT NULL COMMENT '操作者类型 1-管理员 2-普通用户',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作者ID',
  `operator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作者姓名',
  `module` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模块名称',
  `operation` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作类型',
  `request_method` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '请求方法',
  `request_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '请求URL',
  `status` int NULL DEFAULT NULL COMMENT '操作状态 1-成功 0-失败',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`log_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
CREATE TABLE IF NOT EXISTS `sys_notice` (
  `notice_id` bigint NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '内容',
  `notice_type` int NULL DEFAULT 1 COMMENT '公告类型 1-通知 2-公告 3-提醒',
  `is_top` int NULL DEFAULT 0 COMMENT '是否置顶 0-否 1-是',
  `status` int NULL DEFAULT 1 COMMENT '状态 0-禁用 1-启用',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统公告表' ROW_FORMAT = Dynamic;
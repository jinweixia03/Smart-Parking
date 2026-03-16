-- =====================================================
-- 智能停车场管理系统 - 精简版数据库设计
-- =====================================================

CREATE DATABASE IF NOT EXISTS smart_parking
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE smart_parking;

-- =====================================================
-- 1. 用户表
-- =====================================================
CREATE TABLE sys_user (
    user_id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username        VARCHAR(50) NOT NULL COMMENT '用户名',
    password        VARCHAR(100) NOT NULL COMMENT '密码',
    phone           VARCHAR(20) COMMENT '手机号',
    real_name       VARCHAR(50) COMMENT '真实姓名',
    status          TINYINT DEFAULT 1 NOT NULL COMMENT '状态: 0-禁用 1-启用',
    last_login_time DATETIME COMMENT '最后登录时间',
    last_login_ip   VARCHAR(50) COMMENT '最后登录IP',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT uk_username UNIQUE (username),
    CONSTRAINT uk_phone UNIQUE (phone),
    CONSTRAINT chk_user_status CHECK (status IN (0, 1))
) ENGINE=InnoDB COMMENT='用户表';

-- =====================================================
-- 2. 车辆表
-- =====================================================
CREATE TABLE vehicle (
    vehicle_id      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '车辆ID',
    user_id         BIGINT UNSIGNED NOT NULL COMMENT '所属用户ID',
    plate_number    VARCHAR(20) NOT NULL COMMENT '车牌号',
    plate_color     VARCHAR(10) DEFAULT '蓝' NOT NULL COMMENT '车牌颜色',
    vehicle_type    VARCHAR(20) DEFAULT '小型车' NOT NULL COMMENT '车辆类型',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT fk_vehicle_user FOREIGN KEY (user_id) REFERENCES sys_user(user_id) ON DELETE CASCADE,
    CONSTRAINT uk_plate_number UNIQUE (plate_number),
    CONSTRAINT chk_plate_color CHECK (plate_color IN ('蓝', '黄', '绿', '白', '黑'))
) ENGINE=InnoDB COMMENT='车辆表';

CREATE INDEX idx_vehicle_user ON vehicle(user_id);

-- =====================================================
-- 4. 停车区域表
-- =====================================================
CREATE TABLE parking_area (
    area_id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '区域ID',
    area_code       VARCHAR(20) NOT NULL COMMENT '区域编号',
    area_name       VARCHAR(50) NOT NULL COMMENT '区域名称',
    total_spaces    INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '总车位数',
    available_spaces INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '可用车位数',
    status          TINYINT DEFAULT 1 NOT NULL COMMENT '状态: 0-禁用 1-启用',

    CONSTRAINT uk_area_code UNIQUE (area_code),
    CONSTRAINT chk_available CHECK (available_spaces <= total_spaces)
) ENGINE=InnoDB COMMENT='停车区域表';

-- =====================================================
-- 5. 停车位表
-- =====================================================
CREATE TABLE parking_space (
    space_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '车位ID',
    area_id         BIGINT UNSIGNED NOT NULL COMMENT '所属区域ID',
    space_code      VARCHAR(20) NOT NULL COMMENT '车位编号',
    space_type      VARCHAR(20) DEFAULT '普通' NOT NULL COMMENT '车位类型',
    status          TINYINT DEFAULT 0 NOT NULL COMMENT '状态: 0-空闲 1-占用',
    current_plate   VARCHAR(20) COMMENT '当前停放车牌',
    entry_time      DATETIME COMMENT '入场时间',

    CONSTRAINT fk_space_area FOREIGN KEY (area_id) REFERENCES parking_area(area_id) ON DELETE CASCADE,
    CONSTRAINT uk_area_space UNIQUE (area_id, space_code),
    CONSTRAINT chk_space_type CHECK (space_type IN ('普通', 'VIP', '残疾人', '充电桩')),
    CONSTRAINT chk_space_status CHECK (status IN (0, 1))
) ENGINE=InnoDB COMMENT='停车位表';

CREATE INDEX idx_space_area ON parking_space(area_id);
CREATE INDEX idx_space_status ON parking_space(status);

-- =====================================================
-- 6. 收费规则表
-- =====================================================
CREATE TABLE fee_rule (
    rule_id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '规则ID',
    rule_name       VARCHAR(50) NOT NULL COMMENT '规则名称',
    free_minutes    INT UNSIGNED DEFAULT 15 COMMENT '免费时长(分钟)',
    first_hour_fee  DECIMAL(8,2) DEFAULT 5.00 COMMENT '首小时费用',
    extra_hour_fee  DECIMAL(8,2) DEFAULT 3.00 COMMENT '超出每小时费用',
    daily_max_fee   DECIMAL(10,2) DEFAULT 50.00 COMMENT '24小时封顶',
    is_default      TINYINT DEFAULT 0 NOT NULL,
    status          TINYINT DEFAULT 1 NOT NULL,

    CONSTRAINT chk_free_minutes CHECK (free_minutes >= 0),
    CONSTRAINT chk_fee_positive CHECK (first_hour_fee >= 0 AND extra_hour_fee >= 0 AND daily_max_fee >= 0)
) ENGINE=InnoDB COMMENT='收费规则表';

-- =====================================================
-- 7. 停车记录表
-- =====================================================
CREATE TABLE parking_record (
    record_id       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id         BIGINT UNSIGNED COMMENT '用户ID',
    vehicle_id      BIGINT UNSIGNED COMMENT '车辆ID',
    plate_number    VARCHAR(20) NOT NULL COMMENT '车牌号',
    space_id        BIGINT UNSIGNED COMMENT '车位ID',

    -- 入场信息
    entry_time      DATETIME NOT NULL COMMENT '入场时间',
    entry_gate      VARCHAR(20) NOT NULL COMMENT '入口',

    -- 出场信息
    exit_time       DATETIME COMMENT '出场时间',
    exit_gate       VARCHAR(20) COMMENT '出口',

    -- 费用
    parking_minutes INT UNSIGNED COMMENT '停车时长(分钟)',
    fee_amount      DECIMAL(10,2) DEFAULT 0.00 COMMENT '应收费用',
    payable_amount  DECIMAL(10,2) DEFAULT 0.00 COMMENT '应付金额',
    paid_amount     DECIMAL(10,2) DEFAULT 0.00 COMMENT '实付金额',
    pay_status      TINYINT DEFAULT 0 NOT NULL COMMENT '支付状态: 0-未支付 1-已支付 2-免费',
    pay_time        DATETIME COMMENT '支付时间',

    -- 状态: 0-进行中 1-已完成
    status          TINYINT DEFAULT 0 NOT NULL,

    CONSTRAINT fk_record_user FOREIGN KEY (user_id) REFERENCES sys_user(user_id) ON DELETE SET NULL,
    CONSTRAINT fk_record_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id) ON DELETE SET NULL,
    CONSTRAINT fk_record_space FOREIGN KEY (space_id) REFERENCES parking_space(space_id) ON DELETE SET NULL,
    CONSTRAINT chk_pay_status CHECK (pay_status IN (0, 1, 2)),
    CONSTRAINT chk_record_status CHECK (status IN (0, 1)),
    CONSTRAINT chk_time_valid CHECK (exit_time IS NULL OR exit_time >= entry_time)
) ENGINE=InnoDB COMMENT='停车记录表';

CREATE INDEX idx_record_plate ON parking_record(plate_number);
CREATE INDEX idx_record_entry ON parking_record(entry_time);
CREATE INDEX idx_record_status ON parking_record(status);
CREATE INDEX idx_record_pay ON parking_record(pay_status);

-- =====================================================
-- 8. 系统公告表
-- =====================================================
CREATE TABLE sys_notice (
    notice_id       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    title           VARCHAR(100) NOT NULL COMMENT '标题',
    content         TEXT NOT NULL COMMENT '内容',
    notice_type     TINYINT DEFAULT 1 COMMENT '类型: 1-通知 2-公告',
    is_top          TINYINT DEFAULT 0 NOT NULL,
    status          TINYINT DEFAULT 1 NOT NULL,
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT chk_notice_type CHECK (notice_type IN (1, 2))
) ENGINE=InnoDB COMMENT='系统公告表';

-- =====================================================
-- 9. 操作日志表
-- =====================================================
CREATE TABLE operation_log (
    log_id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    operator_type   TINYINT DEFAULT 1 NOT NULL COMMENT '1-用户 2-管理员',
    operator_id     BIGINT UNSIGNED NOT NULL COMMENT '操作者ID',
    operator_name   VARCHAR(50) NOT NULL,
    module          VARCHAR(50) NOT NULL COMMENT '模块',
    operation       VARCHAR(100) NOT NULL COMMENT '操作',
    request_method  VARCHAR(10) NOT NULL,
    request_url     VARCHAR(500) NOT NULL,
    status          TINYINT NOT NULL COMMENT '0-失败 1-成功',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT chk_operator_type CHECK (operator_type IN (1, 2)),
    CONSTRAINT chk_log_status CHECK (status IN (0, 1))
) ENGINE=InnoDB COMMENT='操作日志表';

CREATE INDEX idx_log_time ON operation_log(create_time);

-- =====================================================
-- 触发器：自动维护区域车位数量
-- =====================================================
DELIMITER //

-- 车位状态变更时更新可用数量
CREATE TRIGGER trg_space_change AFTER UPDATE ON parking_space
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        IF NEW.status = 0 THEN
            UPDATE parking_area SET available_spaces = available_spaces + 1 WHERE area_id = NEW.area_id;
        ELSE
            UPDATE parking_area SET available_spaces = available_spaces - 1 WHERE area_id = NEW.area_id;
        END IF;
    END IF;
END//

-- 新增车位
CREATE TRIGGER trg_space_insert AFTER INSERT ON parking_space
FOR EACH ROW
BEGIN
    UPDATE parking_area SET total_spaces = total_spaces + 1 WHERE area_id = NEW.area_id;
    IF NEW.status = 0 THEN
        UPDATE parking_area SET available_spaces = available_spaces + 1 WHERE area_id = NEW.area_id;
    END IF;
END//

DELIMITER ;

-- =====================================================
-- 初始化数据
-- =====================================================

-- 默认用户 (密码: admin123)
INSERT INTO sys_user (username, password, phone, real_name, status, create_time, update_time) VALUES
('admin', '$2a$10$XPCUEhXqfM.oKyXHCeejbuCJ6d0qUlJbY5vKCNYpBW2xTwZS.UASO', '13800138000', '管理员', 1, NOW(), NOW()),
('operator', '$2a$10$XPCUEhXqfM.oKyXHCeejbuCJ6d0qUlJbY5vKCNYpBW2xTwZS.UASO', '13800138001', '操作员', 1, NOW(), NOW());

-- 收费规则
INSERT INTO fee_rule (rule_name, free_minutes, first_hour_fee, extra_hour_fee, daily_max_fee, is_default) VALUES
('标准计费', 15, 5.00, 3.00, 50.00, 1);

-- 停车区域
INSERT INTO parking_area (area_code, area_name, total_spaces, available_spaces) VALUES
('A', 'A区-地面', 0, 0),
('B', 'B区-地下一层', 0, 0);

-- 批量插入车位
DELIMITER //
CREATE PROCEDURE InitSpaces()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE area_a BIGINT;
    DECLARE area_b BIGINT;

    SELECT area_id INTO area_a FROM parking_area WHERE area_code = 'A';
    SELECT area_id INTO area_b FROM parking_area WHERE area_code = 'B';

    -- A区30个车位
    WHILE i <= 30 DO
        INSERT INTO parking_space (area_id, space_code, space_type) VALUES
        (area_a, CONCAT('A', LPAD(i, 3, '0')), IF(i <= 2, '残疾人', IF(i <= 5, '充电桩', '普通')));
        SET i = i + 1;
    END WHILE;

    -- B区30个车位
    SET i = 1;
    WHILE i <= 30 DO
        INSERT INTO parking_space (area_id, space_code, space_type) VALUES
        (area_b, CONCAT('B', LPAD(i, 3, '0')), IF(i <= 3, 'VIP', '普通'));
        SET i = i + 1;
    END WHILE;
END//
DELIMITER ;

CALL InitSpaces();
DROP PROCEDURE InitSpaces;

-- 系统公告
INSERT INTO sys_notice (title, content, notice_type, is_top) VALUES
('系统上线', '智能停车系统正式上线', 2, 1),
('收费标准', '首小时5元，超出每小时3元', 1, 0);

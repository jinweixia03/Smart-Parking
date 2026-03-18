-- ----------------------------
-- 收费规则（真实场景设计）
-- ----------------------------

-- 1. 标准收费（白天时段）- 适用于A、B、C区
INSERT INTO `fee_rule` (`rule_id`, `rule_name`, `free_minutes`, `first_hour_fee`, `extra_hour_fee`, `daily_max_fee`, `is_default`, `status`) VALUES
(1, '标准收费-日间', 15, 5.00, 3.00, 50.00, 1, 1);

-- 2. VIP区收费（更高价格，更好服务）
INSERT INTO `fee_rule` (`rule_id`, `rule_name`, `free_minutes`, `first_hour_fee`, `extra_hour_fee`, `daily_max_fee`, `is_default`, `status`) VALUES
(2, 'VIP专区收费', 30, 10.00, 6.00, 100.00, 0, 1);

-- 3. 夜间优惠收费（18:00-08:00）
INSERT INTO `fee_rule` (`rule_id`, `rule_name`, `free_minutes`, `first_hour_fee`, `extra_hour_fee`, `daily_max_fee`, `is_default`, `status`) VALUES
(3, '夜间优惠收费', 60, 3.00, 2.00, 20.00, 0, 1);

-- 4. 工作日包月套餐（企业用户）
INSERT INTO `fee_rule` (`rule_id`, `rule_name`, `free_minutes`, `first_hour_fee`, `extra_hour_fee`, `daily_max_fee`, `is_default`, `status`) VALUES
(4, '工作日包月-普通区', 0, 0.00, 0.00, 600.00, 0, 1);

-- 5. 24小时封顶优惠（适合长时间停车）
INSERT INTO `fee_rule` (`rule_id`, `rule_name`, `free_minutes`, `first_hour_fee`, `extra_hour_fee`, `daily_max_fee`, `is_default`, `status`) VALUES
(5, '24小时封顶优惠', 0, 4.00, 2.50, 35.00, 0, 1);

-- 6. 周末节假日优惠
INSERT INTO `fee_rule` (`rule_id`, `rule_name`, `free_minutes`, `first_hour_fee`, `extra_hour_fee`, `daily_max_fee`, `is_default`, `status`) VALUES
(6, '周末节假日优惠', 30, 4.00, 2.00, 40.00, 0, 1);

-- 7. 充电桩车位（含电费）
INSERT INTO `fee_rule` (`rule_id`, `rule_name`, `free_minutes`, `first_hour_fee`, `extra_hour_fee`, `daily_max_fee`, `is_default`, `status`) VALUES
(7, '充电桩车位收费', 15, 8.00, 5.00, 80.00, 0, 1);

-- ----------------------------
-- 停车区域（4个区域，每层254个车位，两层共508个）
-- ----------------------------

-- A区：P普通车位区域（每层188个，共376个）
INSERT INTO `parking_area` (`area_id`, `area_code`, `area_name`, `area_type`) VALUES
(1, 'A', 'A区-普通车位', '普通');

-- B区：S新能源充电桩区域（每层40个，共80个）
INSERT INTO `parking_area` (`area_id`, `area_code`, `area_name`, `area_type`) VALUES
(2, 'B', 'B区-充电桩区', '充电桩');

-- C区：E东向普通车位（每层13个，共26个）
INSERT INTO `parking_area` (`area_id`, `area_code`, `area_name`, `area_type`) VALUES
(3, 'C', 'C区-东向车位', '普通');

-- D区：W西向VIP车位（每层13个，共26个）
INSERT INTO `parking_area` (`area_id`, `area_code`, `area_name`, `area_type`) VALUES
(4, 'D', 'D区-VIP车位', 'VIP');

-- ----------------------------
-- 用户账号
-- ----------------------------

-- 管理员账号 (密码: 123456)
INSERT INTO `sys_user` (`user_id`, `username`, `password`, `phone`, `user_type`, `status`, `create_time`) VALUES
(1, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EW', '13800138000', 1, 1, NOW());

-- 测试普通用户 (密码: 123456)
INSERT INTO `sys_user` (`user_id`, `username`, `password`, `phone`, `user_type`, `status`, `create_time`) VALUES
(2, 'user', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EW', '13800138001', 2, 1, NOW());

-- ----------------------------
-- 停车位（共508个，每层254个，与MAP格子数匹配）
-- ----------------------------

-- ==================== 一层车位 (floor=1, space_id=1-254) ====================

-- 一层A区：P车位 188个（A001-A188）
INSERT INTO `parking_space` (`space_id`, `floor`, `space_code`, `status`) VALUES
(1, 1, 'A001', 0), (2, 1, 'A002', 0), (3, 1, 'A003', 0), (4, 1, 'A004', 0), (5, 1, 'A005', 0),
(6, 1, 'A006', 0), (7, 1, 'A007', 0), (8, 1, 'A008', 0), (9, 1, 'A009', 0), (10, 1, 'A010', 0),
(11, 1, 'A011', 0), (12, 1, 'A012', 0), (13, 1, 'A013', 0), (14, 1, 'A014', 0), (15, 1, 'A015', 0),
(16, 1, 'A016', 0), (17, 1, 'A017', 0), (18, 1, 'A018', 0), (19, 1, 'A019', 0), (20, 1, 'A020', 0),
(21, 1, 'A021', 0), (22, 1, 'A022', 0), (23, 1, 'A023', 0), (24, 1, 'A024', 0), (25, 1, 'A025', 0),
(26, 1, 'A026', 0), (27, 1, 'A027', 0), (28, 1, 'A028', 0), (29, 1, 'A029', 0), (30, 1, 'A030', 0),
(31, 1, 'A031', 0), (32, 1, 'A032', 0), (33, 1, 'A033', 0), (34, 1, 'A034', 0), (35, 1, 'A035', 0),
(36, 1, 'A036', 0), (37, 1, 'A037', 0), (38, 1, 'A038', 0), (39, 1, 'A039', 0), (40, 1, 'A040', 0),
(41, 1, 'A041', 0), (42, 1, 'A042', 0), (43, 1, 'A043', 0), (44, 1, 'A044', 0), (45, 1, 'A045', 0),
(46, 1, 'A046', 0), (47, 1, 'A047', 0), (48, 1, 'A048', 0), (49, 1, 'A049', 0), (50, 1, 'A050', 0),
(51, 1, 'A051', 0), (52, 1, 'A052', 0), (53, 1, 'A053', 0), (54, 1, 'A054', 0), (55, 1, 'A055', 0),
(56, 1, 'A056', 0), (57, 1, 'A057', 0), (58, 1, 'A058', 0), (59, 1, 'A059', 0), (60, 1, 'A060', 0),
(61, 1, 'A061', 0), (62, 1, 'A062', 0), (63, 1, 'A063', 0), (64, 1, 'A064', 0), (65, 1, 'A065', 0),
(66, 1, 'A066', 0), (67, 1, 'A067', 0), (68, 1, 'A068', 0), (69, 1, 'A069', 0), (70, 1, 'A070', 0),
(71, 1, 'A071', 0), (72, 1, 'A072', 0), (73, 1, 'A073', 0), (74, 1, 'A074', 0), (75, 1, 'A075', 0),
(76, 1, 'A076', 0), (77, 1, 'A077', 0), (78, 1, 'A078', 0), (79, 1, 'A079', 0), (80, 1, 'A080', 0),
(81, 1, 'A081', 0), (82, 1, 'A082', 0), (83, 1, 'A083', 0), (84, 1, 'A084', 0), (85, 1, 'A085', 0),
(86, 1, 'A086', 0), (87, 1, 'A087', 0), (88, 1, 'A088', 0), (89, 1, 'A089', 0), (90, 1, 'A090', 0),
(91, 1, 'A091', 0), (92, 1, 'A092', 0), (93, 1, 'A093', 0), (94, 1, 'A094', 0), (95, 1, 'A095', 0),
(96, 1, 'A096', 0), (97, 1, 'A097', 0), (98, 1, 'A098', 0), (99, 1, 'A099', 0), (100, 1, 'A100', 0),
(101, 1, 'A101', 0), (102, 1, 'A102', 0), (103, 1, 'A103', 0), (104, 1, 'A104', 0), (105, 1, 'A105', 0),
(106, 1, 'A106', 0), (107, 1, 'A107', 0), (108, 1, 'A108', 0), (109, 1, 'A109', 0), (110, 1, 'A110', 0),
(111, 1, 'A111', 0), (112, 1, 'A112', 0), (113, 1, 'A113', 0), (114, 1, 'A114', 0), (115, 1, 'A115', 0),
(116, 1, 'A116', 0), (117, 1, 'A117', 0), (118, 1, 'A118', 0), (119, 1, 'A119', 0), (120, 1, 'A120', 0),
(121, 1, 'A121', 0), (122, 1, 'A122', 0), (123, 1, 'A123', 0), (124, 1, 'A124', 0), (125, 1, 'A125', 0),
(126, 1, 'A126', 0), (127, 1, 'A127', 0), (128, 1, 'A128', 0), (129, 1, 'A129', 0), (130, 1, 'A130', 0),
(131, 1, 'A131', 0), (132, 1, 'A132', 0), (133, 1, 'A133', 0), (134, 1, 'A134', 0), (135, 1, 'A135', 0),
(136, 1, 'A136', 0), (137, 1, 'A137', 0), (138, 1, 'A138', 0), (139, 1, 'A139', 0), (140, 1, 'A140', 0),
(141, 1, 'A141', 0), (142, 1, 'A142', 0), (143, 1, 'A143', 0), (144, 1, 'A144', 0), (145, 1, 'A145', 0),
(146, 1, 'A146', 0), (147, 1, 'A147', 0), (148, 1, 'A148', 0), (149, 1, 'A149', 0), (150, 1, 'A150', 0),
(151, 1, 'A151', 0), (152, 1, 'A152', 0), (153, 1, 'A153', 0), (154, 1, 'A154', 0), (155, 1, 'A155', 0),
(156, 1, 'A156', 0), (157, 1, 'A157', 0), (158, 1, 'A158', 0), (159, 1, 'A159', 0), (160, 1, 'A160', 0),
(161, 1, 'A161', 0), (162, 1, 'A162', 0), (163, 1, 'A163', 0), (164, 1, 'A164', 0), (165, 1, 'A165', 0),
(166, 1, 'A166', 0), (167, 1, 'A167', 0), (168, 1, 'A168', 0), (169, 1, 'A169', 0), (170, 1, 'A170', 0),
(171, 1, 'A171', 0), (172, 1, 'A172', 0), (173, 1, 'A173', 0), (174, 1, 'A174', 0), (175, 1, 'A175', 0),
(176, 1, 'A176', 0), (177, 1, 'A177', 0), (178, 1, 'A178', 0), (179, 1, 'A179', 0), (180, 1, 'A180', 0),
(181, 1, 'A181', 0), (182, 1, 'A182', 0), (183, 1, 'A183', 0), (184, 1, 'A184', 0), (185, 1, 'A185', 0),
(186, 1, 'A186', 0), (187, 1, 'A187', 0), (188, 1, 'A188', 0);

-- 一层B区：S车位 40个（B001-B040）
INSERT INTO `parking_space` (`space_id`, `floor`, `space_code`, `status`) VALUES
(189, 1, 'B001', 0), (190, 1, 'B002', 0), (191, 1, 'B003', 0), (192, 1, 'B004', 0), (193, 1, 'B005', 0),
(194, 1, 'B006', 0), (195, 1, 'B007', 0), (196, 1, 'B008', 0), (197, 1, 'B009', 0), (198, 1, 'B010', 0),
(199, 1, 'B011', 0), (200, 1, 'B012', 0), (201, 1, 'B013', 0), (202, 1, 'B014', 0), (203, 1, 'B015', 0),
(204, 1, 'B016', 0), (205, 1, 'B017', 0), (206, 1, 'B018', 0), (207, 1, 'B019', 0), (208, 1, 'B020', 0),
(209, 1, 'B021', 0), (210, 1, 'B022', 0), (211, 1, 'B023', 0), (212, 1, 'B024', 0), (213, 1, 'B025', 0),
(214, 1, 'B026', 0), (215, 1, 'B027', 0), (216, 1, 'B028', 0), (217, 1, 'B029', 0), (218, 1, 'B030', 0),
(219, 1, 'B031', 0), (220, 1, 'B032', 0), (221, 1, 'B033', 0), (222, 1, 'B034', 0), (223, 1, 'B035', 0),
(224, 1, 'B036', 0), (225, 1, 'B037', 0), (226, 1, 'B038', 0), (227, 1, 'B039', 0), (228, 1, 'B040', 0);

-- 一层C区：E车位 13个（C001-C013）
INSERT INTO `parking_space` (`space_id`, `floor`, `space_code`, `status`) VALUES
(229, 1, 'C001', 0), (230, 1, 'C002', 0), (231, 1, 'C003', 0), (232, 1, 'C004', 0),
(233, 1, 'C005', 0), (234, 1, 'C006', 0), (235, 1, 'C007', 0), (236, 1, 'C008', 0),
(237, 1, 'C009', 0), (238, 1, 'C010', 0), (239, 1, 'C011', 0), (240, 1, 'C012', 0),
(241, 1, 'C013', 0);

-- 一层D区：W车位 13个（D001-D013）
INSERT INTO `parking_space` (`space_id`, `floor`, `space_code`, `status`) VALUES
(242, 1, 'D001', 0), (243, 1, 'D002', 0), (244, 1, 'D003', 0), (245, 1, 'D004', 0),
(246, 1, 'D005', 0), (247, 1, 'D006', 0), (248, 1, 'D007', 0), (249, 1, 'D008', 0),
(250, 1, 'D009', 0), (251, 1, 'D010', 0), (252, 1, 'D011', 0), (253, 1, 'D012', 0),
(254, 1, 'D013', 0);

-- ==================== 二层车位 (floor=2, space_id=255-508) ====================

-- 二层A区：P车位 188个（A201-A388）
INSERT INTO `parking_space` (`space_id`, `floor`, `space_code`, `status`) VALUES
(255, 2, 'A201', 0), (256, 2, 'A202', 0), (257, 2, 'A203', 0), (258, 2, 'A204', 0), (259, 2, 'A205', 0),
(260, 2, 'A206', 0), (261, 2, 'A207', 0), (262, 2, 'A208', 0), (263, 2, 'A209', 0), (264, 2, 'A210', 0),
(265, 2, 'A211', 0), (266, 2, 'A212', 0), (267, 2, 'A213', 0), (268, 2, 'A214', 0), (269, 2, 'A215', 0),
(270, 2, 'A216', 0), (271, 2, 'A217', 0), (272, 2, 'A218', 0), (273, 2, 'A219', 0), (274, 2, 'A220', 0),
(275, 2, 'A221', 0), (276, 2, 'A222', 0), (277, 2, 'A223', 0), (278, 2, 'A224', 0), (279, 2, 'A225', 0),
(280, 2, 'A226', 0), (281, 2, 'A227', 0), (282, 2, 'A228', 0), (283, 2, 'A229', 0), (284, 2, 'A230', 0),
(285, 2, 'A231', 0), (286, 2, 'A232', 0), (287, 2, 'A233', 0), (288, 2, 'A234', 0), (289, 2, 'A235', 0),
(290, 2, 'A236', 0), (291, 2, 'A237', 0), (292, 2, 'A238', 0), (293, 2, 'A239', 0), (294, 2, 'A240', 0),
(295, 2, 'A241', 0), (296, 2, 'A242', 0), (297, 2, 'A243', 0), (298, 2, 'A244', 0), (299, 2, 'A245', 0),
(300, 2, 'A246', 0), (301, 2, 'A247', 0), (302, 2, 'A248', 0), (303, 2, 'A249', 0), (304, 2, 'A250', 0),
(305, 2, 'A251', 0), (306, 2, 'A252', 0), (307, 2, 'A253', 0), (308, 2, 'A254', 0), (309, 2, 'A255', 0),
(310, 2, 'A256', 0), (311, 2, 'A257', 0), (312, 2, 'A258', 0), (313, 2, 'A259', 0), (314, 2, 'A260', 0),
(315, 2, 'A261', 0), (316, 2, 'A262', 0), (317, 2, 'A263', 0), (318, 2, 'A264', 0), (319, 2, 'A265', 0),
(320, 2, 'A266', 0), (321, 2, 'A267', 0), (322, 2, 'A268', 0), (323, 2, 'A269', 0), (324, 2, 'A270', 0),
(325, 2, 'A271', 0), (326, 2, 'A272', 0), (327, 2, 'A273', 0), (328, 2, 'A274', 0), (329, 2, 'A275', 0),
(330, 2, 'A276', 0), (331, 2, 'A277', 0), (332, 2, 'A278', 0), (333, 2, 'A279', 0), (334, 2, 'A280', 0),
(335, 2, 'A281', 0), (336, 2, 'A282', 0), (337, 2, 'A283', 0), (338, 2, 'A284', 0), (339, 2, 'A285', 0),
(340, 2, 'A286', 0), (341, 2, 'A287', 0), (342, 2, 'A288', 0), (343, 2, 'A289', 0), (344, 2, 'A290', 0),
(345, 2, 'A291', 0), (346, 2, 'A292', 0), (347, 2, 'A293', 0), (348, 2, 'A294', 0), (349, 2, 'A295', 0),
(350, 2, 'A296', 0), (351, 2, 'A297', 0), (352, 2, 'A298', 0), (353, 2, 'A299', 0), (354, 2, 'A300', 0),
(355, 2, 'A301', 0), (356, 2, 'A302', 0), (357, 2, 'A303', 0), (358, 2, 'A304', 0), (359, 2, 'A305', 0),
(360, 2, 'A306', 0), (361, 2, 'A307', 0), (362, 2, 'A308', 0), (363, 2, 'A309', 0), (364, 2, 'A310', 0),
(365, 2, 'A311', 0), (366, 2, 'A312', 0), (367, 2, 'A313', 0), (368, 2, 'A314', 0), (369, 2, 'A315', 0),
(370, 2, 'A316', 0), (371, 2, 'A317', 0), (372, 2, 'A318', 0), (373, 2, 'A319', 0), (374, 2, 'A320', 0),
(375, 2, 'A321', 0), (376, 2, 'A322', 0), (377, 2, 'A323', 0), (378, 2, 'A324', 0), (379, 2, 'A325', 0),
(380, 2, 'A326', 0), (381, 2, 'A327', 0), (382, 2, 'A328', 0), (383, 2, 'A329', 0), (384, 2, 'A330', 0),
(385, 2, 'A331', 0), (386, 2, 'A332', 0), (387, 2, 'A333', 0), (388, 2, 'A334', 0), (389, 2, 'A335', 0),
(390, 2, 'A336', 0), (391, 2, 'A337', 0), (392, 2, 'A338', 0), (393, 2, 'A339', 0), (394, 2, 'A340', 0),
(395, 2, 'A341', 0), (396, 2, 'A342', 0), (397, 2, 'A343', 0), (398, 2, 'A344', 0), (399, 2, 'A345', 0),
(400, 2, 'A346', 0), (401, 2, 'A347', 0), (402, 2, 'A348', 0), (403, 2, 'A349', 0), (404, 2, 'A350', 0),
(405, 2, 'A351', 0), (406, 2, 'A352', 0), (407, 2, 'A353', 0), (408, 2, 'A354', 0), (409, 2, 'A355', 0),
(410, 2, 'A356', 0), (411, 2, 'A357', 0), (412, 2, 'A358', 0), (413, 2, 'A359', 0), (414, 2, 'A360', 0),
(415, 2, 'A361', 0), (416, 2, 'A362', 0), (417, 2, 'A363', 0), (418, 2, 'A364', 0), (419, 2, 'A365', 0),
(420, 2, 'A366', 0), (421, 2, 'A367', 0), (422, 2, 'A368', 0), (423, 2, 'A369', 0), (424, 2, 'A370', 0),
(425, 2, 'A371', 0), (426, 2, 'A372', 0), (427, 2, 'A373', 0), (428, 2, 'A374', 0), (429, 2, 'A375', 0),
(430, 2, 'A376', 0), (431, 2, 'A377', 0), (432, 2, 'A378', 0), (433, 2, 'A379', 0), (434, 2, 'A380', 0),
(435, 2, 'A381', 0), (436, 2, 'A382', 0), (437, 2, 'A383', 0), (438, 2, 'A384', 0), (439, 2, 'A385', 0),
(440, 2, 'A386', 0), (441, 2, 'A387', 0), (442, 2, 'A388', 0);

-- 二层B区：S车位 40个（B201-B240）
INSERT INTO `parking_space` (`space_id`, `floor`, `space_code`, `status`) VALUES
(443, 2, 'B201', 0), (444, 2, 'B202', 0), (445, 2, 'B203', 0), (446, 2, 'B204', 0), (447, 2, 'B205', 0),
(448, 2, 'B206', 0), (449, 2, 'B207', 0), (450, 2, 'B208', 0), (451, 2, 'B209', 0), (452, 2, 'B210', 0),
(453, 2, 'B211', 0), (454, 2, 'B212', 0), (455, 2, 'B213', 0), (456, 2, 'B214', 0), (457, 2, 'B215', 0),
(458, 2, 'B216', 0), (459, 2, 'B217', 0), (460, 2, 'B218', 0), (461, 2, 'B219', 0), (462, 2, 'B220', 0),
(463, 2, 'B221', 0), (464, 2, 'B222', 0), (465, 2, 'B223', 0), (466, 2, 'B224', 0), (467, 2, 'B225', 0),
(468, 2, 'B226', 0), (469, 2, 'B227', 0), (470, 2, 'B228', 0), (471, 2, 'B229', 0), (472, 2, 'B230', 0),
(473, 2, 'B231', 0), (474, 2, 'B232', 0), (475, 2, 'B233', 0), (476, 2, 'B234', 0), (477, 2, 'B235', 0),
(478, 2, 'B236', 0), (479, 2, 'B237', 0), (480, 2, 'B238', 0), (481, 2, 'B239', 0), (482, 2, 'B240', 0);

-- 二层C区：E车位 13个（C201-C213）
INSERT INTO `parking_space` (`space_id`, `floor`, `space_code`, `status`) VALUES
(483, 2, 'C201', 0), (484, 2, 'C202', 0), (485, 2, 'C203', 0), (486, 2, 'C204', 0),
(487, 2, 'C205', 0), (488, 2, 'C206', 0), (489, 2, 'C207', 0), (490, 2, 'C208', 0),
(491, 2, 'C209', 0), (492, 2, 'C210', 0), (493, 2, 'C211', 0), (494, 2, 'C212', 0),
(495, 2, 'C213', 0);

-- 二层D区：W车位 13个（D201-D213）
INSERT INTO `parking_space` (`space_id`, `floor`, `space_code`, `status`) VALUES
(496, 2, 'D201', 0), (497, 2, 'D202', 0), (498, 2, 'D203', 0), (499, 2, 'D204', 0),
(500, 2, 'D205', 0), (501, 2, 'D206', 0), (502, 2, 'D207', 0), (503, 2, 'D208', 0),
(504, 2, 'D209', 0), (505, 2, 'D210', 0), (506, 2, 'D211', 0), (507, 2, 'D212', 0),
(508, 2, 'D213', 0);

SET FOREIGN_KEY_CHECKS = 1;

-- ========================================
-- 智能停车场管理系统 - 初始化数据导入完成
-- ========================================
-- 共导入：
-- - 收费规则: 7条
-- - 停车区域: 4个 (A区376个、B区80个、C区26个、D区26个)
-- - 停车位: 508个 (每层254个，共两层)
-- - 用户账号: 2个 (admin/user，密码123456)
-- ========================================
-- ==================== 生成1000条拟真停车记录 ====================
-- 时间范围：最近30天
-- 约100条未支付（正在停车），约900条已完成

-- 先清空现有记录（保留车位数据，只重置状态）
TRUNCATE TABLE `parking_record`;

-- 重置所有车位为空闲
UPDATE `parking_space` SET `status` = 0, `current_plate` = NULL;

SET FOREIGN_KEY_CHECKS = 0;

-- ==================== 100条未支付记录（正在停车） ====================
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(1, '苏G17833', 446, '2026-03-18 11:02:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '苏G17833' WHERE `space_id` = 446;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(2, '浙A09218', 59, '2026-03-18 21:44:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '浙A09218' WHERE `space_id` = 59;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(3, '蒙K83111', 166, '2026-03-18 19:39:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '蒙K83111' WHERE `space_id` = 166;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(4, '黑A89392', 268, '2026-03-18 15:54:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '黑A89392' WHERE `space_id` = 268;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(5, '陕B98416', 481, '2026-03-18 13:45:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '陕B98416' WHERE `space_id` = 481;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(6, '赣B28585', 458, '2026-03-18 22:14:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '赣B28585' WHERE `space_id` = 458;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(7, '陕T63091', 24, '2026-03-18 15:25:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '陕T63091' WHERE `space_id` = 24;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(8, '渝Z98686', 291, '2026-03-18 17:41:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '渝Z98686' WHERE `space_id` = 291;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(9, '苏B01325', 267, '2026-03-18 21:11:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '苏B01325' WHERE `space_id` = 267;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(10, '桂L96574', 170, '2026-03-18 03:47:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '桂L96574' WHERE `space_id` = 170;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(11, '晋E72472', 147, '2026-03-18 23:32:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '晋E72472' WHERE `space_id` = 147;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(12, '晋A08377', 81, '2026-03-18 03:40:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '晋A08377' WHERE `space_id` = 81;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(13, '湘A06172', 281, '2026-03-18 05:27:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '湘A06172' WHERE `space_id` = 281;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(14, '贵V23896', 448, '2026-03-18 23:50:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '贵V23896' WHERE `space_id` = 448;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(15, '湘A80730', 274, '2026-03-18 15:11:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '湘A80730' WHERE `space_id` = 274;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(16, '皖D14832', 66, '2026-03-18 22:26:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '皖D14832' WHERE `space_id` = 66;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(17, '蒙H25379', 242, '2026-03-18 19:21:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '蒙H25379' WHERE `space_id` = 242;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(18, '渝V20141', 179, '2026-03-18 15:17:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '渝V20141' WHERE `space_id` = 179;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(19, '湘P90635', 394, '2026-03-18 08:47:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '湘P90635' WHERE `space_id` = 394;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(20, '蒙G38213', 459, '2026-03-18 19:01:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '蒙G38213' WHERE `space_id` = 459;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(21, '宁M80092', 333, '2026-03-18 04:42:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '宁M80092' WHERE `space_id` = 333;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(22, '闽A75433', 39, '2026-03-18 18:54:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '闽A75433' WHERE `space_id` = 39;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(23, '桂C68622', 283, '2026-03-18 11:12:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '桂C68622' WHERE `space_id` = 283;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(24, '赣C60545', 44, '2026-03-18 03:10:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '赣C60545' WHERE `space_id` = 44;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(25, '吉Y23842', 351, '2026-03-18 19:35:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '吉Y23842' WHERE `space_id` = 351;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(26, '苏W25244', 96, '2026-03-18 14:45:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '苏W25244' WHERE `space_id` = 96;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(27, '藏B84477', 1, '2026-03-18 23:22:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '藏B84477' WHERE `space_id` = 1;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(28, '粤D23283', 323, '2026-03-18 22:12:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '粤D23283' WHERE `space_id` = 323;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(29, '苏B61159', 56, '2026-03-18 02:18:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '苏B61159' WHERE `space_id` = 56;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(30, '晋R37347', 342, '2026-03-19 01:45:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '晋R37347' WHERE `space_id` = 342;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(31, '苏M29325', 322, '2026-03-18 11:16:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '苏M29325' WHERE `space_id` = 322;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(32, '宁G48047', 203, '2026-03-18 17:46:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '宁G48047' WHERE `space_id` = 203;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(33, '苏Q15557', 417, '2026-03-19 01:03:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '苏Q15557' WHERE `space_id` = 417;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(34, '藏T23445', 138, '2026-03-18 13:16:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '藏T23445' WHERE `space_id` = 138;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(35, '贵D26595', 12, '2026-03-18 05:17:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '贵D26595' WHERE `space_id` = 12;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(36, '赣E53159', 53, '2026-03-18 09:11:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '赣E53159' WHERE `space_id` = 53;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(37, '沪Q21831', 171, '2026-03-18 11:51:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '沪Q21831' WHERE `space_id` = 171;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(38, '鲁P00944', 271, '2026-03-18 17:47:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '鲁P00944' WHERE `space_id` = 271;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(39, '津T73252', 377, '2026-03-18 19:34:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '津T73252' WHERE `space_id` = 377;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(40, '辽V06050', 449, '2026-03-18 10:50:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '辽V06050' WHERE `space_id` = 449;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(41, '浙Q63768', 489, '2026-03-18 08:36:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '浙Q63768' WHERE `space_id` = 489;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(42, '沪G95042', 248, '2026-03-18 17:27:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '沪G95042' WHERE `space_id` = 248;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(43, '琼J04641', 507, '2026-03-18 05:06:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '琼J04641' WHERE `space_id` = 507;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(44, '浙S87474', 114, '2026-03-18 04:18:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '浙S87474' WHERE `space_id` = 114;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(45, '渝E76991', 461, '2026-03-18 08:58:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '渝E76991' WHERE `space_id` = 461;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(46, '湘T04993', 502, '2026-03-18 06:42:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '湘T04993' WHERE `space_id` = 502;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(47, '藏Y62338', 133, '2026-03-18 19:13:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '藏Y62338' WHERE `space_id` = 133;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(48, '琼L16939', 430, '2026-03-18 05:21:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '琼L16939' WHERE `space_id` = 430;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(49, '鄂U79479', 157, '2026-03-18 14:48:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '鄂U79479' WHERE `space_id` = 157;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(50, '冀G26578', 319, '2026-03-18 03:38:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '冀G26578' WHERE `space_id` = 319;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(51, '京X21467', 101, '2026-03-18 03:48:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '京X21467' WHERE `space_id` = 101;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(52, '豫X80809', 200, '2026-03-18 02:28:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '豫X80809' WHERE `space_id` = 200;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(53, '贵L96463', 247, '2026-03-18 14:38:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '贵L96463' WHERE `space_id` = 247;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(54, '辽W89363', 245, '2026-03-18 08:18:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '辽W89363' WHERE `space_id` = 245;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(55, '沪T40669', 409, '2026-03-18 15:37:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '沪T40669' WHERE `space_id` = 409;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(56, '辽F54861', 301, '2026-03-19 01:36:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '辽F54861' WHERE `space_id` = 301;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(57, '贵R40661', 310, '2026-03-19 01:47:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '贵R40661' WHERE `space_id` = 310;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(58, '甘U43825', 399, '2026-03-18 16:16:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '甘U43825' WHERE `space_id` = 399;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(59, '宁S94417', 490, '2026-03-18 12:14:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '宁S94417' WHERE `space_id` = 490;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(60, '京K25592', 336, '2026-03-18 02:50:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '京K25592' WHERE `space_id` = 336;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(61, '蒙Y23160', 422, '2026-03-18 20:38:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '蒙Y23160' WHERE `space_id` = 422;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(62, '蒙F09513', 76, '2026-03-18 19:56:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '蒙F09513' WHERE `space_id` = 76;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(63, '苏P71826', 233, '2026-03-18 11:23:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '苏P71826' WHERE `space_id` = 233;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(64, '豫X18499', 183, '2026-03-19 00:54:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '豫X18499' WHERE `space_id` = 183;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(65, '陕S18460', 217, '2026-03-19 01:09:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '陕S18460' WHERE `space_id` = 217;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(66, '鄂A57916', 402, '2026-03-18 07:14:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '鄂A57916' WHERE `space_id` = 402;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(67, '渝L37197', 503, '2026-03-18 15:03:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '渝L37197' WHERE `space_id` = 503;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(68, '苏D04661', 441, '2026-03-18 10:29:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '苏D04661' WHERE `space_id` = 441;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(69, '湘V06855', 244, '2026-03-19 01:03:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '湘V06855' WHERE `space_id` = 244;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(70, '琼E85810', 365, '2026-03-18 17:50:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '琼E85810' WHERE `space_id` = 365;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(71, '宁W95050', 142, '2026-03-18 07:02:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '宁W95050' WHERE `space_id` = 142;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(72, '琼K37500', 201, '2026-03-18 18:20:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '琼K37500' WHERE `space_id` = 201;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(73, '皖D18135', 506, '2026-03-18 19:26:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '皖D18135' WHERE `space_id` = 506;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(74, '湘N91973', 325, '2026-03-18 19:59:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '湘N91973' WHERE `space_id` = 325;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(75, '渝H30671', 92, '2026-03-18 13:04:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '渝H30671' WHERE `space_id` = 92;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(76, '豫Z71461', 508, '2026-03-18 04:36:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '豫Z71461' WHERE `space_id` = 508;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(77, '辽M64746', 454, '2026-03-18 11:31:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '辽M64746' WHERE `space_id` = 454;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(78, '渝Q92343', 174, '2026-03-18 10:42:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '渝Q92343' WHERE `space_id` = 174;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(79, '青E84648', 3, '2026-03-19 01:45:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '青E84648' WHERE `space_id` = 3;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(80, '豫Y69961', 412, '2026-03-18 14:18:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '豫Y69961' WHERE `space_id` = 412;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(81, '皖J80184', 145, '2026-03-18 08:56:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '皖J80184' WHERE `space_id` = 145;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(82, '川P84333', 182, '2026-03-18 13:41:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '川P84333' WHERE `space_id` = 182;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(83, '藏D50718', 404, '2026-03-18 11:36:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '藏D50718' WHERE `space_id` = 404;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(84, '赣V16577', 27, '2026-03-18 17:41:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '赣V16577' WHERE `space_id` = 27;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(85, '赣K12298', 259, '2026-03-18 12:40:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '赣K12298' WHERE `space_id` = 259;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(86, '贵J97193', 45, '2026-03-19 01:39:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '贵J97193' WHERE `space_id` = 45;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(87, '青T28207', 255, '2026-03-19 00:37:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '青T28207' WHERE `space_id` = 255;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(88, '青E26755', 494, '2026-03-18 16:25:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '青E26755' WHERE `space_id` = 494;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(89, '云E97844', 492, '2026-03-18 07:13:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '云E97844' WHERE `space_id` = 492;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(90, '粤V04544', 33, '2026-03-19 00:34:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '粤V04544' WHERE `space_id` = 33;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(91, '桂A62938', 252, '2026-03-18 07:00:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '桂A62938' WHERE `space_id` = 252;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(92, '京R13697', 134, '2026-03-18 11:40:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '京R13697' WHERE `space_id` = 134;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(93, '沪X13959', 314, '2026-03-18 16:28:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '沪X13959' WHERE `space_id` = 314;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(94, '湘G72454', 364, '2026-03-18 23:53:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '湘G72454' WHERE `space_id` = 364;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(95, '赣D64607', 139, '2026-03-18 05:23:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '赣D64607' WHERE `space_id` = 139;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(96, '川P37371', 129, '2026-03-18 12:55:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '川P37371' WHERE `space_id` = 129;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(97, '闽N57069', 97, '2026-03-18 23:24:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '闽N57069' WHERE `space_id` = 97;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(98, '豫D28966', 69, '2026-03-18 04:03:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '豫D28966' WHERE `space_id` = 69;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(99, '陕N46756', 60, '2026-03-18 17:46:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '陕N46756' WHERE `space_id` = 60;
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(100, '苏Z37751', 210, '2026-03-18 15:49:10', NULL, 0.00, 0, NULL);
UPDATE `parking_space` SET `status` = 1, `current_plate` = '苏Z37751' WHERE `space_id` = 210;

-- ==================== 900条已完成记录（已出场） ====================
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(101, '甘C70239', 182, '2026-03-15 11:01:10', '2026-03-17 15:15:10', 117.00, 1, '2026-03-17 15:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(102, '黑X55091', 125, '2026-02-17 08:47:10', '2026-02-19 00:02:10', 100.00, 1, '2026-02-19 00:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(103, '陕R99372', 348, '2026-03-03 17:25:10', '2026-03-06 16:45:10', 155.00, 1, '2026-03-06 16:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(104, '皖P65263', 151, '2026-03-05 21:25:10', '2026-03-06 23:23:10', 58.00, 1, '2026-03-06 23:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(105, '晋Q23173', 479, '2026-03-16 10:31:10', '2026-03-16 16:41:10', 23.00, 1, '2026-03-16 16:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(106, '闽Y09988', 476, '2026-03-05 14:48:10', '2026-03-07 17:07:10', 111.00, 1, '2026-03-07 16:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(107, '冀S64797', 134, '2026-02-25 15:29:10', '2026-02-27 04:26:10', 91.00, 1, '2026-02-27 04:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(108, '鲁R98831', 71, '2026-03-14 13:04:10', '2026-03-14 17:32:10', 17.00, 1, '2026-03-14 17:37:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(109, '黑R77734', 138, '2026-03-04 10:28:10', '2026-03-06 20:57:10', 135.00, 1, '2026-03-06 20:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(110, '宁Q01892', 432, '2026-03-01 16:08:10', '2026-03-03 12:09:10', 100.00, 1, '2026-03-03 12:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(111, '甘F14163', 68, '2026-03-01 18:59:10', '2026-03-04 01:43:10', 123.00, 1, '2026-03-04 01:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(112, '云H05235', 278, '2026-03-14 08:11:10', '2026-03-14 18:19:10', 35.00, 1, '2026-03-14 18:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(113, '吉Y80550', 483, '2026-02-18 02:15:10', '2026-02-18 12:33:10', 35.00, 1, '2026-02-18 12:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(114, '鲁Z26624', 477, '2026-02-23 18:55:10', '2026-02-24 13:16:10', 50.00, 1, '2026-02-24 13:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(115, '吉A96549', 130, '2026-03-06 05:29:10', '2026-03-07 14:33:10', 82.00, 1, '2026-03-07 14:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(116, '藏U43439', 276, '2026-02-19 08:43:10', '2026-02-21 06:34:10', 100.00, 1, '2026-02-21 06:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(117, '晋Y62162', 221, '2026-03-04 03:56:10', '2026-03-05 22:05:10', 100.00, 1, '2026-03-05 22:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(118, '青C76054', 229, '2026-03-03 08:15:10', '2026-03-05 16:42:10', 129.00, 1, '2026-03-05 16:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(119, '鲁A26010', 334, '2026-02-21 19:42:10', '2026-02-24 10:18:10', 147.00, 1, '2026-02-24 10:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(120, '苏S95305', 113, '2026-03-09 23:59:10', '2026-03-12 00:41:10', 105.00, 1, '2026-03-12 00:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(121, '蒙K67500', 76, '2026-03-05 01:41:10', '2026-03-07 07:55:10', 123.00, 1, '2026-03-07 08:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(122, '陕R00583', 470, '2026-03-17 18:38:10', '2026-03-18 13:41:10', 50.00, 1, '2026-03-18 13:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(123, '闽T22103', 11, '2026-03-10 04:59:10', '2026-03-10 14:25:10', 32.00, 1, '2026-03-10 14:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(124, '藏U75370', 71, '2026-03-07 09:16:10', '2026-03-07 13:35:10', 17.00, 1, '2026-03-07 13:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(125, '鲁Y42957', 402, '2026-03-10 00:47:10', '2026-03-10 09:47:10', 29.00, 1, '2026-03-10 09:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(126, '鄂J75298', 491, '2026-03-02 19:04:10', '2026-03-04 10:20:10', 100.00, 1, '2026-03-04 10:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(127, '蒙T53663', 115, '2026-03-13 02:22:10', '2026-03-15 11:24:10', 132.00, 1, '2026-03-15 11:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(128, '粤B71751', 277, '2026-02-25 01:53:10', '2026-02-25 02:34:10', 5.00, 1, '2026-02-25 02:37:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(129, '皖C65613', 333, '2026-03-14 08:40:10', '2026-03-15 03:03:10', 50.00, 1, '2026-03-15 02:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(130, '粤N26864', 75, '2026-02-21 08:08:10', '2026-02-22 16:30:10', 79.00, 1, '2026-02-22 16:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(131, '辽B77449', 170, '2026-02-27 08:09:10', '2026-02-28 02:55:10', 50.00, 1, '2026-02-28 02:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(132, '津X19945', 202, '2026-02-27 22:36:10', '2026-02-28 14:05:10', 50.00, 1, '2026-02-28 14:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(133, '京J18266', 470, '2026-02-20 12:32:10', '2026-02-21 10:25:10', 50.00, 1, '2026-02-21 10:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(134, '吉F19747', 9, '2026-03-11 03:57:10', '2026-03-11 10:43:10', 23.00, 1, '2026-03-11 10:50:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(135, '宁U57906', 267, '2026-02-28 00:38:10', '2026-03-02 12:37:10', 138.00, 1, '2026-03-02 12:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(136, '津S52419', 357, '2026-03-08 19:22:10', '2026-03-09 12:06:10', 50.00, 1, '2026-03-09 11:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(137, '辽B57498', 360, '2026-02-16 11:19:10', '2026-02-19 04:39:10', 150.00, 1, '2026-02-19 04:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(138, '鄂H55371', 344, '2026-03-09 10:16:10', '2026-03-11 03:35:10', 100.00, 1, '2026-03-11 03:30:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(139, '青V33459', 228, '2026-02-23 08:00:10', '2026-02-25 00:44:10', 100.00, 1, '2026-02-25 00:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(140, '贵N68281', 437, '2026-03-08 01:53:10', '2026-03-10 11:40:10', 132.00, 1, '2026-03-10 11:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(141, '豫C39378', 259, '2026-02-26 22:12:10', '2026-03-01 00:34:10', 111.00, 1, '2026-03-01 00:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(142, '豫E86853', 176, '2026-03-04 04:53:10', '2026-03-04 07:31:10', 11.00, 1, '2026-03-04 07:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(143, '辽V78081', 300, '2026-02-24 18:13:10', '2026-02-26 22:20:10', 117.00, 1, '2026-02-26 22:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(144, '桂B46150', 10, '2026-02-24 03:14:10', '2026-02-26 09:33:10', 123.00, 1, '2026-02-26 09:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(145, '黑F69251', 183, '2026-03-07 19:29:10', '2026-03-09 03:14:10', 76.00, 1, '2026-03-09 03:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(146, '冀J82002', 508, '2026-02-17 03:18:10', '2026-02-18 18:35:10', 100.00, 1, '2026-02-18 18:36:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(147, '苏B92989', 414, '2026-02-25 12:20:10', '2026-02-25 17:10:10', 17.00, 1, '2026-02-25 17:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(148, '鄂P81836', 89, '2026-03-11 11:41:10', '2026-03-14 06:30:10', 150.00, 1, '2026-03-14 06:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(149, '粤G28001', 192, '2026-03-07 15:13:10', '2026-03-10 11:22:10', 150.00, 1, '2026-03-10 11:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(150, '赣C69616', 48, '2026-03-09 18:11:10', '2026-03-12 00:22:10', 123.00, 1, '2026-03-12 00:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(151, '津D42004', 334, '2026-03-06 14:10:10', '2026-03-07 11:07:10', 50.00, 1, '2026-03-07 11:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(152, '云G40425', 345, '2026-02-22 09:41:10', '2026-02-24 08:53:10', 105.00, 1, '2026-02-24 08:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(153, '湘V60337', 238, '2026-03-09 13:43:10', '2026-03-11 21:19:10', 126.00, 1, '2026-03-11 21:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(154, '宁Y11831', 366, '2026-03-12 14:06:10', '2026-03-13 16:59:10', 61.00, 1, '2026-03-13 16:49:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(155, '湘U11068', 228, '2026-02-19 12:35:10', '2026-02-21 16:16:10', 114.00, 1, '2026-02-21 16:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(156, '藏D66919', 110, '2026-03-03 09:42:10', '2026-03-03 12:28:10', 11.00, 1, '2026-03-03 12:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(157, '宁D96213', 413, '2026-03-06 04:20:10', '2026-03-08 00:42:10', 100.00, 1, '2026-03-08 00:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(158, '豫Z60702', 362, '2026-03-16 05:22:10', '2026-03-17 04:49:10', 55.00, 1, '2026-03-17 04:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(159, '鄂R42121', 459, '2026-03-03 18:50:10', '2026-03-04 04:20:10', 32.00, 1, '2026-03-04 04:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(160, '云S79618', 375, '2026-03-05 09:30:10', '2026-03-07 19:11:10', 132.00, 1, '2026-03-07 19:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(161, '浙J08943', 243, '2026-03-11 20:14:10', '2026-03-12 06:28:10', 35.00, 1, '2026-03-12 06:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(162, '赣T51313', 211, '2026-02-24 22:04:10', '2026-02-27 12:51:10', 147.00, 1, '2026-02-27 12:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(163, '青T81736', 485, '2026-02-23 14:54:10', '2026-02-25 04:47:10', 94.00, 1, '2026-02-25 04:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(164, '津E74516', 13, '2026-02-26 06:47:10', '2026-02-26 19:05:10', 41.00, 1, '2026-02-26 19:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(165, '闽K64423', 41, '2026-03-10 19:43:10', '2026-03-13 14:31:10', 150.00, 1, '2026-03-13 14:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(166, '鲁B51388', 370, '2026-02-18 21:33:10', '2026-02-21 12:41:10', 150.00, 1, '2026-02-21 12:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(167, '皖J13334', 166, '2026-03-17 21:42:10', '2026-03-19 01:50:10', 67.00, 1, '2026-03-19 01:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(168, '陕C95237', 435, '2026-03-08 07:37:10', '2026-03-10 22:08:10', 147.00, 1, '2026-03-10 22:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(169, '辽T73004', 55, '2026-03-07 09:36:10', '2026-03-08 11:12:10', 58.00, 1, '2026-03-08 11:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(170, '青A01389', 211, '2026-03-17 06:11:10', '2026-03-19 01:49:10', 100.00, 1, '2026-03-19 01:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(171, '苏K76414', 372, '2026-03-03 05:37:10', '2026-03-04 03:48:10', 50.00, 1, '2026-03-04 03:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(172, '黑M36906', 117, '2026-02-22 07:34:10', '2026-02-22 16:48:10', 32.00, 1, '2026-02-22 16:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(173, '藏L74052', 259, '2026-03-10 04:44:10', '2026-03-10 08:03:10', 14.00, 1, '2026-03-10 07:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(174, '鲁J02768', 364, '2026-03-05 05:50:10', '2026-03-06 19:43:10', 94.00, 1, '2026-03-06 19:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(175, '晋X94047', 229, '2026-03-08 10:36:10', '2026-03-08 21:18:10', 35.00, 1, '2026-03-08 21:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(176, '赣X12089', 211, '2026-02-27 08:40:10', '2026-02-27 15:32:10', 23.00, 1, '2026-02-27 15:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(177, '浙S08073', 390, '2026-03-07 05:18:10', '2026-03-09 07:27:10', 111.00, 1, '2026-03-09 07:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(178, '湘V79670', 230, '2026-03-11 12:29:10', '2026-03-13 00:32:10', 91.00, 1, '2026-03-13 00:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(179, '桂U35864', 384, '2026-03-12 07:10:10', '2026-03-14 21:43:10', 147.00, 1, '2026-03-14 21:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(180, '蒙G66913', 76, '2026-03-09 00:30:10', '2026-03-10 19:51:10', 100.00, 1, '2026-03-10 19:48:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(181, '鲁W59075', 36, '2026-02-27 18:57:10', '2026-03-02 08:01:10', 144.00, 1, '2026-03-02 07:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(182, '鄂N85725', 454, '2026-03-07 11:45:10', '2026-03-09 00:35:10', 91.00, 1, '2026-03-09 00:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(183, '京H96919', 326, '2026-02-27 03:46:10', '2026-02-28 04:37:10', 55.00, 1, '2026-02-28 04:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(184, '宁Y97866', 275, '2026-02-28 23:37:10', '2026-03-01 07:43:10', 29.00, 1, '2026-03-01 07:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(185, '桂H91612', 229, '2026-03-06 12:54:10', '2026-03-07 04:26:10', 50.00, 1, '2026-03-07 04:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(186, '鄂K35804', 286, '2026-03-05 10:25:10', '2026-03-06 19:51:10', 82.00, 1, '2026-03-06 19:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(187, '京F89348', 395, '2026-02-16 15:48:10', '2026-02-17 03:43:10', 38.00, 1, '2026-02-17 03:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(188, '苏S85101', 396, '2026-02-18 11:21:10', '2026-02-20 16:20:10', 117.00, 1, '2026-02-20 16:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(189, '赣K28241', 173, '2026-02-17 09:30:10', '2026-02-19 12:50:10', 114.00, 1, '2026-02-19 12:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(190, '豫U07796', 360, '2026-03-05 02:57:10', '2026-03-06 16:45:10', 94.00, 1, '2026-03-06 16:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(191, '桂H87475', 391, '2026-03-16 01:00:10', '2026-03-18 15:03:10', 147.00, 1, '2026-03-18 15:01:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(192, '云W10277', 421, '2026-02-25 14:07:10', '2026-02-26 02:24:10', 41.00, 1, '2026-02-26 02:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(193, '川N89762', 262, '2026-02-22 13:36:10', '2026-02-24 22:05:10', 129.00, 1, '2026-02-24 21:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(194, '粤W93877', 308, '2026-03-12 09:20:10', '2026-03-14 11:38:10', 111.00, 1, '2026-03-14 11:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(195, '鲁P08035', 220, '2026-02-28 12:45:10', '2026-03-03 01:21:10', 141.00, 1, '2026-03-03 01:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(196, '鄂B31468', 482, '2026-03-11 11:21:10', '2026-03-14 09:23:10', 150.00, 1, '2026-03-14 09:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(197, '云Y25979', 449, '2026-03-02 07:12:10', '2026-03-04 03:09:10', 100.00, 1, '2026-03-04 03:10:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(198, '闽F40387', 331, '2026-03-11 13:45:10', '2026-03-12 11:17:10', 50.00, 1, '2026-03-12 11:10:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(199, '云B06183', 391, '2026-03-15 09:58:10', '2026-03-15 19:13:10', 32.00, 1, '2026-03-15 19:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(200, '粤Z33549', 405, '2026-03-13 14:17:10', '2026-03-16 10:32:10', 150.00, 1, '2026-03-16 10:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(201, '琼G88456', 345, '2026-02-24 05:57:10', '2026-02-25 15:40:10', 82.00, 1, '2026-02-25 15:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(202, '浙M92290', 108, '2026-02-28 00:51:10', '2026-03-01 05:29:10', 67.00, 1, '2026-03-01 05:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(203, '桂H83692', 29, '2026-03-14 15:58:10', '2026-03-16 21:00:10', 120.00, 1, '2026-03-16 20:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(204, '闽U74637', 7, '2026-03-01 13:07:10', '2026-03-03 03:10:10', 97.00, 1, '2026-03-03 03:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(205, '津M97065', 29, '2026-02-22 23:55:10', '2026-02-23 16:14:10', 50.00, 1, '2026-02-23 16:24:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(206, '浙M99659', 236, '2026-02-22 09:46:10', '2026-02-23 20:22:10', 85.00, 1, '2026-02-23 20:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(207, '粤S30518', 371, '2026-03-14 00:10:10', '2026-03-14 03:53:10', 14.00, 1, '2026-03-14 03:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(208, '京C62703', 302, '2026-02-20 06:00:10', '2026-02-20 22:01:10', 50.00, 1, '2026-02-20 21:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(209, '沪D63255', 88, '2026-02-26 22:39:10', '2026-03-01 19:07:10', 150.00, 1, '2026-03-01 18:57:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(210, '沪E78073', 275, '2026-03-07 05:04:10', '2026-03-07 15:45:10', 35.00, 1, '2026-03-07 15:50:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(211, '藏U03092', 249, '2026-03-09 08:04:10', '2026-03-09 14:02:10', 20.00, 1, '2026-03-09 13:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(212, '沪M43963', 441, '2026-02-16 23:00:10', '2026-02-18 12:38:10', 94.00, 1, '2026-02-18 12:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(213, '桂D30998', 282, '2026-02-25 16:59:10', '2026-02-28 14:43:10', 150.00, 1, '2026-02-28 14:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(214, '粤V95514', 86, '2026-03-09 21:13:10', '2026-03-12 05:49:10', 129.00, 1, '2026-03-12 05:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(215, '陕A78933', 66, '2026-03-13 03:42:10', '2026-03-14 09:53:10', 73.00, 1, '2026-03-14 10:03:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(216, '京Q76116', 470, '2026-03-09 05:40:10', '2026-03-10 03:08:10', 50.00, 1, '2026-03-10 03:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(217, '青Q90376', 432, '2026-02-26 22:50:10', '2026-02-28 03:41:10', 67.00, 1, '2026-02-28 03:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(218, '云F51288', 21, '2026-03-14 08:26:10', '2026-03-16 19:00:10', 135.00, 1, '2026-03-16 18:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(219, '藏A42416', 170, '2026-02-22 12:44:10', '2026-02-25 03:44:10', 147.00, 1, '2026-02-25 03:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(220, '甘T95029', 256, '2026-03-12 22:14:10', '2026-03-15 09:45:10', 138.00, 1, '2026-03-15 09:49:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(221, '渝Z12884', 6, '2026-03-16 12:28:10', '2026-03-16 15:15:10', 11.00, 1, '2026-03-16 15:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(222, '甘T10366', 45, '2026-02-24 22:21:10', '2026-02-27 07:05:10', 129.00, 1, '2026-02-27 06:57:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(223, '藏F62592', 176, '2026-02-17 18:29:10', '2026-02-18 16:25:10', 50.00, 1, '2026-02-18 16:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(224, '川Z68523', 208, '2026-02-26 03:40:10', '2026-02-26 18:37:10', 47.00, 1, '2026-02-26 18:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(225, '闽A54096', 198, '2026-03-15 21:36:10', '2026-03-18 11:58:10', 147.00, 1, '2026-03-18 11:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(226, '青B65037', 104, '2026-03-12 17:24:10', '2026-03-13 08:27:10', 50.00, 1, '2026-03-13 08:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(227, '辽Q40732', 431, '2026-02-17 12:25:10', '2026-02-19 11:55:10', 105.00, 1, '2026-02-19 11:48:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(228, '桂J24526', 266, '2026-02-22 11:21:10', '2026-02-25 03:06:10', 150.00, 1, '2026-02-25 03:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(229, '浙B18164', 103, '2026-03-05 16:09:10', '2026-03-08 01:13:10', 132.00, 1, '2026-03-08 01:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(230, '皖X89295', 261, '2026-03-12 02:05:10', '2026-03-12 09:00:10', 23.00, 1, '2026-03-12 08:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(231, '云F82270', 347, '2026-03-17 22:55:10', '2026-03-18 09:14:10', 35.00, 1, '2026-03-18 09:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(232, '赣P76492', 251, '2026-02-22 23:38:10', '2026-02-24 15:30:10', 100.00, 1, '2026-02-24 15:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(233, '晋S20255', 269, '2026-02-21 12:43:10', '2026-02-23 09:59:10', 100.00, 1, '2026-02-23 09:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(234, '湘E30169', 78, '2026-02-22 07:25:10', '2026-02-22 08:08:10', 5.00, 1, '2026-02-22 07:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(235, '闽E24579', 181, '2026-02-24 08:22:10', '2026-02-26 18:36:10', 135.00, 1, '2026-02-26 18:36:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(236, '晋Y04878', 353, '2026-02-16 17:05:10', '2026-02-17 00:59:10', 26.00, 1, '2026-02-17 01:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(237, '粤V78943', 263, '2026-02-27 13:46:10', '2026-03-01 00:46:10', 85.00, 1, '2026-03-01 00:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(238, '豫E95420', 360, '2026-03-11 10:38:10', '2026-03-12 18:00:10', 76.00, 1, '2026-03-12 17:57:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(239, '蒙B62973', 463, '2026-03-04 00:18:10', '2026-03-04 04:22:10', 17.00, 1, '2026-03-04 04:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(240, '甘K75201', 10, '2026-02-26 09:09:10', '2026-03-01 06:52:10', 150.00, 1, '2026-03-01 07:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(241, '鲁W51679', 3, '2026-03-05 17:59:10', '2026-03-07 04:15:10', 85.00, 1, '2026-03-07 04:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(242, '蒙N00240', 133, '2026-02-21 19:54:10', '2026-02-22 01:42:10', 20.00, 1, '2026-02-22 01:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(243, '豫J43603', 45, '2026-02-24 06:09:10', '2026-02-24 11:13:10', 20.00, 1, '2026-02-24 11:03:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(244, '青T19100', 476, '2026-02-22 21:05:10', '2026-02-23 13:24:10', 50.00, 1, '2026-02-23 13:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(245, '苏D16480', 233, '2026-02-26 23:15:10', '2026-02-28 00:32:10', 58.00, 1, '2026-02-28 00:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(246, '辽T24422', 219, '2026-03-14 15:38:10', '2026-03-16 19:24:10', 114.00, 1, '2026-03-16 19:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(247, '甘V68801', 181, '2026-02-24 18:58:10', '2026-02-25 03:08:10', 29.00, 1, '2026-02-25 03:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(248, '苏V47149', 125, '2026-03-14 23:48:10', '2026-03-15 17:28:10', 50.00, 1, '2026-03-15 17:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(249, '皖D45734', 136, '2026-03-06 04:18:10', '2026-03-08 01:46:10', 100.00, 1, '2026-03-08 01:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(250, '皖B24144', 37, '2026-03-02 20:57:10', '2026-03-04 16:51:10', 100.00, 1, '2026-03-04 16:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(251, '鲁W08595', 279, '2026-03-02 05:43:10', '2026-03-02 13:38:10', 26.00, 1, '2026-03-02 13:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(252, '渝W34295', 114, '2026-03-17 22:17:10', '2026-03-19 01:42:10', 64.00, 1, '2026-03-19 01:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(253, '京X90364', 465, '2026-02-26 00:07:10', '2026-02-28 00:28:10', 105.00, 1, '2026-02-28 00:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(254, '桂A25399', 477, '2026-03-11 07:27:10', '2026-03-11 20:31:10', 44.00, 1, '2026-03-11 20:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(255, '津S81955', 163, '2026-03-16 00:16:10', '2026-03-16 06:35:10', 23.00, 1, '2026-03-16 06:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(256, '赣L40106', 154, '2026-03-10 18:33:10', '2026-03-11 11:00:10', 50.00, 1, '2026-03-11 10:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(257, '桂F05553', 259, '2026-02-17 02:20:10', '2026-02-18 05:35:10', 64.00, 1, '2026-02-18 05:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(258, '津X76164', 485, '2026-02-16 12:01:10', '2026-02-17 22:38:10', 85.00, 1, '2026-02-17 22:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(259, '鲁M26994', 272, '2026-02-23 14:33:10', '2026-02-25 01:43:10', 88.00, 1, '2026-02-25 01:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(260, '晋H94238', 107, '2026-02-22 16:29:10', '2026-02-25 03:20:10', 135.00, 1, '2026-02-25 03:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(261, '辽J76271', 486, '2026-03-05 21:37:10', '2026-03-07 22:58:10', 108.00, 1, '2026-03-07 23:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(262, '皖P39738', 454, '2026-02-20 06:14:10', '2026-02-21 00:25:10', 50.00, 1, '2026-02-21 00:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(263, '皖Z88614', 148, '2026-02-22 20:21:10', '2026-02-25 16:17:10', 150.00, 1, '2026-02-25 16:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(264, '吉T81012', 464, '2026-02-26 14:44:10', '2026-02-26 17:16:10', 11.00, 1, '2026-02-26 17:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(265, '云Z99927', 232, '2026-02-23 07:35:10', '2026-02-23 14:49:10', 26.00, 1, '2026-02-23 14:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(266, '蒙L05084', 294, '2026-03-02 19:39:10', '2026-03-05 18:58:10', 155.00, 1, '2026-03-05 18:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(267, '鄂E32849', 242, '2026-03-09 06:23:10', '2026-03-10 13:02:10', 73.00, 1, '2026-03-10 13:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(268, '晋J02696', 82, '2026-03-05 04:06:10', '2026-03-06 08:34:10', 67.00, 1, '2026-03-06 08:24:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(269, '浙Y79293', 438, '2026-03-08 08:06:10', '2026-03-11 00:31:10', 150.00, 1, '2026-03-11 00:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(270, '京B60863', 34, '2026-03-15 21:17:10', '2026-03-16 21:06:10', 55.00, 1, '2026-03-16 20:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(271, '津Z89957', 68, '2026-02-25 21:57:10', '2026-02-28 02:56:10', 117.00, 1, '2026-02-28 02:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(272, '豫R56135', 79, '2026-03-06 14:54:10', '2026-03-09 05:33:10', 147.00, 1, '2026-03-09 05:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(273, '豫L59610', 151, '2026-03-15 07:59:10', '2026-03-17 10:49:10', 111.00, 1, '2026-03-17 10:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(274, '藏H07397', 498, '2026-02-27 10:32:10', '2026-02-27 16:44:10', 23.00, 1, '2026-02-27 16:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(275, '皖P37897', 79, '2026-03-13 05:55:10', '2026-03-14 17:37:10', 88.00, 1, '2026-03-14 17:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(276, '皖V73241', 66, '2026-02-26 02:27:10', '2026-02-28 12:32:10', 135.00, 1, '2026-02-28 12:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(277, '桂N94874', 285, '2026-03-16 11:46:10', '2026-03-18 00:07:10', 91.00, 1, '2026-03-18 00:10:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(278, '黑W44986', 130, '2026-03-14 14:58:10', '2026-03-17 06:07:10', 150.00, 1, '2026-03-17 06:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(279, '宁F76253', 178, '2026-03-04 21:12:10', '2026-03-07 14:28:10', 150.00, 1, '2026-03-07 14:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(280, '甘F97690', 210, '2026-03-03 09:49:10', '2026-03-05 00:16:10', 97.00, 1, '2026-03-05 00:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(281, '黑C04083', 212, '2026-03-08 08:10:10', '2026-03-10 22:41:10', 147.00, 1, '2026-03-10 22:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(282, '川G34953', 372, '2026-02-26 03:07:10', '2026-02-27 08:38:10', 70.00, 1, '2026-02-27 08:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(283, '桂V76897', 283, '2026-02-28 14:41:10', '2026-03-03 06:13:10', 150.00, 1, '2026-03-03 06:10:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(284, '鲁G30846', 474, '2026-02-23 19:49:10', '2026-02-24 11:46:10', 50.00, 1, '2026-02-24 11:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(285, '陕L39567', 116, '2026-02-16 22:46:10', '2026-02-17 16:10:10', 50.00, 1, '2026-02-17 16:03:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(286, '桂Y65023', 83, '2026-03-04 06:03:10', '2026-03-05 08:14:10', 61.00, 1, '2026-03-05 08:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(287, '冀V88927', 459, '2026-02-24 09:02:10', '2026-02-24 19:51:10', 35.00, 1, '2026-02-24 19:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(288, '津N15947', 198, '2026-03-03 01:31:10', '2026-03-05 11:38:10', 135.00, 1, '2026-03-05 11:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(289, '鲁G92727', 89, '2026-03-13 02:00:10', '2026-03-13 09:40:10', 26.00, 1, '2026-03-13 09:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(290, '皖X79066', 364, '2026-02-25 01:07:10', '2026-02-25 21:08:10', 50.00, 1, '2026-02-25 21:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(291, '云T70250', 395, '2026-03-01 15:27:10', '2026-03-02 22:57:10', 76.00, 1, '2026-03-02 22:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(292, '京A73112', 118, '2026-02-23 04:43:10', '2026-02-24 20:45:10', 100.00, 1, '2026-02-24 20:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(293, '琼N50664', 122, '2026-02-25 23:28:10', '2026-02-27 22:17:10', 100.00, 1, '2026-02-27 22:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(294, '宁Q24558', 245, '2026-03-02 20:21:10', '2026-03-03 20:48:10', 55.00, 1, '2026-03-03 20:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(295, '川F77974', 210, '2026-02-17 00:49:10', '2026-02-18 02:24:10', 58.00, 1, '2026-02-18 02:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(296, '沪Q69180', 336, '2026-02-26 06:42:10', '2026-02-28 16:22:10', 132.00, 1, '2026-02-28 16:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(297, '闽E65382', 396, '2026-03-06 05:33:10', '2026-03-08 19:30:10', 144.00, 1, '2026-03-08 19:36:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(298, '辽A81874', 263, '2026-03-03 18:03:10', '2026-03-04 22:47:10', 67.00, 1, '2026-03-04 22:37:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(299, '豫R25200', 118, '2026-03-10 09:52:10', '2026-03-12 13:17:10', 114.00, 1, '2026-03-12 13:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(300, '粤Q70014', 212, '2026-02-17 10:58:10', '2026-02-18 09:41:10', 50.00, 1, '2026-02-18 09:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(301, '陕Q89400', 500, '2026-02-21 22:00:10', '2026-02-23 03:35:10', 70.00, 1, '2026-02-23 03:37:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(302, '浙K39270', 356, '2026-03-05 22:22:10', '2026-03-07 09:11:10', 85.00, 1, '2026-03-07 09:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(303, '川Y48470', 491, '2026-03-15 21:12:10', '2026-03-15 22:20:10', 8.00, 1, '2026-03-15 22:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(304, '闽Z10367', 149, '2026-02-25 12:01:10', '2026-02-27 21:40:10', 132.00, 1, '2026-02-27 21:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(305, '青H96385', 205, '2026-02-19 03:49:10', '2026-02-21 17:40:10', 144.00, 1, '2026-02-21 17:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(306, '豫V66841', 495, '2026-02-22 01:09:10', '2026-02-22 23:54:10', 50.00, 1, '2026-02-22 23:49:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(307, '陕Y80676', 8, '2026-03-15 12:18:10', '2026-03-18 08:22:10', 150.00, 1, '2026-03-18 08:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(308, '贵F21903', 429, '2026-02-19 14:59:10', '2026-02-20 10:23:10', 50.00, 1, '2026-02-20 10:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(309, '川X38481', 155, '2026-03-12 13:11:10', '2026-03-13 08:37:10', 50.00, 1, '2026-03-13 08:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(310, '粤Y80552', 387, '2026-02-25 11:32:10', '2026-02-25 12:13:10', 5.00, 1, '2026-02-25 12:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(311, '晋C10867', 65, '2026-03-12 23:59:10', '2026-03-15 04:48:10', 117.00, 1, '2026-03-15 04:48:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(312, '川W38742', 108, '2026-03-08 07:08:10', '2026-03-08 16:30:10', 32.00, 1, '2026-03-08 16:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(313, '蒙D78937', 449, '2026-03-04 03:56:10', '2026-03-05 07:59:10', 67.00, 1, '2026-03-05 08:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(314, '津D09360', 214, '2026-02-22 07:58:10', '2026-02-23 23:21:10', 100.00, 1, '2026-02-23 23:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(315, '冀L43366', 11, '2026-03-03 13:15:10', '2026-03-04 14:15:10', 55.00, 1, '2026-03-04 14:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(316, '辽P71853', 342, '2026-02-16 05:15:10', '2026-02-18 07:30:10', 111.00, 1, '2026-02-18 07:22:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(317, '闽U78406', 135, '2026-03-06 14:35:10', '2026-03-07 11:03:10', 50.00, 1, '2026-03-07 11:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(318, '苏F20171', 17, '2026-03-11 15:41:10', '2026-03-12 08:38:10', 50.00, 1, '2026-03-12 08:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(319, '青N13513', 44, '2026-02-19 11:31:10', '2026-02-20 10:09:10', 50.00, 1, '2026-02-20 10:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(320, '闽C18764', 120, '2026-03-03 11:30:10', '2026-03-06 00:12:10', 141.00, 1, '2026-03-06 00:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(321, '渝Y04791', 22, '2026-03-09 13:37:10', '2026-03-11 13:06:10', 105.00, 1, '2026-03-11 13:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(322, '豫F08317', 104, '2026-03-11 10:48:10', '2026-03-13 21:08:10', 135.00, 1, '2026-03-13 21:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(323, '鄂L75919', 204, '2026-03-15 05:21:10', '2026-03-16 23:27:10', 100.00, 1, '2026-03-16 23:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(324, '豫B27847', 457, '2026-02-16 22:01:10', '2026-02-17 14:00:10', 50.00, 1, '2026-02-17 13:50:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(325, '贵K33470', 285, '2026-03-15 21:29:10', '2026-03-18 20:37:10', 155.00, 1, '2026-03-18 20:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(326, '闽B14843', 206, '2026-02-21 12:21:10', '2026-02-22 17:52:10', 70.00, 1, '2026-02-22 17:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(327, '吉L66346', 143, '2026-03-12 07:37:10', '2026-03-12 20:58:10', 44.00, 1, '2026-03-12 20:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(328, '藏W96015', 169, '2026-02-21 05:09:10', '2026-02-22 19:55:10', 97.00, 1, '2026-02-22 19:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(329, '浙J85482', 143, '2026-03-15 07:19:10', '2026-03-15 23:09:10', 50.00, 1, '2026-03-15 23:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(330, '陕C76963', 63, '2026-02-26 08:21:10', '2026-02-27 15:44:10', 76.00, 1, '2026-02-27 15:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(331, '闽M50849', 77, '2026-03-07 01:33:10', '2026-03-09 08:41:10', 126.00, 1, '2026-03-09 08:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(332, '晋L24810', 438, '2026-03-03 15:41:10', '2026-03-04 21:48:10', 73.00, 1, '2026-03-04 21:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(333, '贵U77956', 58, '2026-03-13 23:27:10', '2026-03-16 23:27:10', 155.00, 1, '2026-03-16 23:26:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(334, '浙B62533', 190, '2026-03-05 08:28:10', '2026-03-08 03:05:10', 150.00, 1, '2026-03-08 03:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(335, '冀F85742', 205, '2026-03-11 04:32:10', '2026-03-13 11:23:10', 123.00, 1, '2026-03-13 11:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(336, '渝A51496', 501, '2026-03-03 23:21:10', '2026-03-04 03:55:10', 17.00, 1, '2026-03-04 03:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(337, '湘Q44185', 237, '2026-03-08 10:48:10', '2026-03-08 19:13:10', 29.00, 1, '2026-03-08 19:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(338, '苏C61838', 435, '2026-02-22 02:22:10', '2026-02-23 12:26:10', 85.00, 1, '2026-02-23 12:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(339, '苏C52966', 285, '2026-03-15 06:18:10', '2026-03-15 07:23:10', 8.00, 1, '2026-03-15 07:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(340, '渝U15226', 156, '2026-02-27 23:03:10', '2026-03-02 21:47:10', 150.00, 1, '2026-03-02 21:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(341, '川H46351', 495, '2026-02-26 21:39:10', '2026-02-27 13:39:10', 50.00, 1, '2026-02-27 13:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(342, '宁C94929', 136, '2026-03-06 23:55:10', '2026-03-09 20:09:10', 150.00, 1, '2026-03-09 20:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(343, '冀Y29634', 49, '2026-02-20 01:13:10', '2026-02-22 22:57:10', 150.00, 1, '2026-02-22 23:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(344, '蒙K27902', 10, '2026-03-11 00:21:10', '2026-03-12 05:54:10', 70.00, 1, '2026-03-12 05:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(345, '津M39282', 397, '2026-02-16 07:52:10', '2026-02-18 03:50:10', 100.00, 1, '2026-02-18 03:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(346, '宁G76190', 195, '2026-03-09 09:27:10', '2026-03-09 15:41:10', 23.00, 1, '2026-03-09 15:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(347, '苏Z03395', 251, '2026-02-24 02:33:10', '2026-02-26 22:50:10', 150.00, 1, '2026-02-26 22:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(348, '青T81207', 99, '2026-02-24 11:20:10', '2026-02-27 10:27:10', 155.00, 1, '2026-02-27 10:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(349, '渝D29315', 143, '2026-03-05 18:17:10', '2026-03-08 16:42:10', 150.00, 1, '2026-03-08 16:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(350, '豫U45167', 332, '2026-03-14 20:40:10', '2026-03-16 09:08:10', 91.00, 1, '2026-03-16 09:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(351, '粤K70130', 252, '2026-02-19 03:07:10', '2026-02-21 08:57:10', 120.00, 1, '2026-02-21 09:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(352, '渝T31135', 241, '2026-02-22 23:34:10', '2026-02-24 14:05:10', 97.00, 1, '2026-02-24 14:01:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(353, '宁A88084', 397, '2026-02-20 22:35:10', '2026-02-23 13:35:10', 147.00, 1, '2026-02-23 13:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(354, '渝P10190', 17, '2026-03-13 17:10:10', '2026-03-16 00:36:10', 126.00, 1, '2026-03-16 00:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(355, '晋M81096', 48, '2026-02-25 01:02:10', '2026-02-27 13:13:10', 141.00, 1, '2026-02-27 13:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(356, '黑B75882', 391, '2026-03-07 13:46:10', '2026-03-10 11:30:10', 150.00, 1, '2026-03-10 11:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(357, '云Q30798', 455, '2026-02-24 23:26:10', '2026-02-25 07:36:10', 29.00, 1, '2026-02-25 07:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(358, '豫D30176', 109, '2026-02-20 05:35:10', '2026-02-20 18:36:10', 44.00, 1, '2026-02-20 18:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(359, '黑P06650', 332, '2026-03-08 10:59:10', '2026-03-09 18:47:10', 76.00, 1, '2026-03-09 18:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(360, '青Q24464', 339, '2026-02-21 20:01:10', '2026-02-23 23:30:10', 114.00, 1, '2026-02-23 23:24:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(361, '宁A96424', 394, '2026-02-23 18:52:10', '2026-02-24 12:14:10', 50.00, 1, '2026-02-24 12:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(362, '粤B88430', 376, '2026-02-18 13:58:10', '2026-02-18 22:28:10', 29.00, 1, '2026-02-18 22:36:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(363, '贵X72460', 160, '2026-03-16 04:09:10', '2026-03-17 23:30:10', 100.00, 1, '2026-03-17 23:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(364, '津E95863', 493, '2026-03-04 17:46:10', '2026-03-05 23:10:10', 70.00, 1, '2026-03-05 23:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(365, '宁N04348', 218, '2026-02-25 20:14:10', '2026-02-26 12:20:10', 50.00, 1, '2026-02-26 12:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(366, '贵U42352', 402, '2026-03-01 09:49:10', '2026-03-02 15:53:10', 73.00, 1, '2026-03-02 15:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(367, '鲁K15072', 405, '2026-03-09 04:18:10', '2026-03-11 23:29:10', 150.00, 1, '2026-03-11 23:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(368, '甘T22622', 357, '2026-02-18 18:23:10', '2026-02-19 19:41:10', 58.00, 1, '2026-02-19 19:48:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(369, '甘M79144', 117, '2026-02-24 02:37:10', '2026-02-26 15:43:10', 144.00, 1, '2026-02-26 15:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(370, '粤Y41803', 363, '2026-02-21 03:43:10', '2026-02-23 03:53:10', 105.00, 1, '2026-02-23 04:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(371, '皖U59504', 68, '2026-03-03 09:52:10', '2026-03-05 14:10:10', 117.00, 1, '2026-03-05 14:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(372, '京G88756', 76, '2026-03-08 17:30:10', '2026-03-10 03:26:10', 82.00, 1, '2026-03-10 03:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(373, '甘R82463', 507, '2026-03-10 13:11:10', '2026-03-11 19:36:10', 73.00, 1, '2026-03-11 19:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(374, '甘G49484', 204, '2026-02-18 09:34:10', '2026-02-19 12:17:10', 61.00, 1, '2026-02-19 12:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(375, '津Z15679', 483, '2026-02-19 04:47:10', '2026-02-20 12:30:10', 76.00, 1, '2026-02-20 12:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(376, '豫F78516', 83, '2026-03-11 13:31:10', '2026-03-12 13:41:10', 55.00, 1, '2026-03-12 13:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(377, '京H84160', 89, '2026-03-09 18:20:10', '2026-03-10 21:43:10', 64.00, 1, '2026-03-10 21:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(378, '津D85747', 451, '2026-03-05 01:23:10', '2026-03-07 10:36:10', 132.00, 1, '2026-03-07 10:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(379, '陕K80223', 178, '2026-03-09 17:39:10', '2026-03-10 01:28:10', 26.00, 1, '2026-03-10 01:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(380, '京Y68197', 246, '2026-03-04 07:44:10', '2026-03-04 16:46:10', 32.00, 1, '2026-03-04 16:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(381, '京X13610', 491, '2026-02-23 17:35:10', '2026-02-24 06:30:10', 41.00, 1, '2026-02-24 06:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(382, '豫D85441', 24, '2026-03-13 13:29:10', '2026-03-13 15:27:10', 8.00, 1, '2026-03-13 15:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(383, '浙Q00401', 150, '2026-02-27 12:08:10', '2026-02-28 13:39:10', 58.00, 1, '2026-02-28 13:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(384, '青Q17173', 6, '2026-03-01 10:25:10', '2026-03-03 23:22:10', 141.00, 1, '2026-03-03 23:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(385, '浙E90512', 296, '2026-03-17 12:53:10', '2026-03-18 14:41:10', 58.00, 1, '2026-03-18 14:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(386, '贵V06503', 108, '2026-03-11 15:40:10', '2026-03-14 02:21:10', 135.00, 1, '2026-03-14 02:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(387, '川Q44906', 17, '2026-03-02 17:40:10', '2026-03-04 01:57:10', 79.00, 1, '2026-03-04 01:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(388, '赣Y44630', 399, '2026-03-16 15:17:10', '2026-03-17 08:21:10', 50.00, 1, '2026-03-17 08:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(389, '贵X08588', 13, '2026-02-26 02:00:10', '2026-02-26 23:40:10', 50.00, 1, '2026-02-26 23:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(390, '甘F92546', 160, '2026-03-08 19:37:10', '2026-03-10 18:11:10', 100.00, 1, '2026-03-10 18:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(391, '晋D11829', 353, '2026-02-23 18:05:10', '2026-02-26 13:44:10', 150.00, 1, '2026-02-26 13:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(392, '皖N87554', 170, '2026-02-18 17:32:10', '2026-02-18 23:36:10', 23.00, 1, '2026-02-18 23:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(393, '黑A00045', 299, '2026-02-23 07:13:10', '2026-02-24 12:57:10', 70.00, 1, '2026-02-24 13:01:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(394, '贵K74880', 145, '2026-02-20 16:46:10', '2026-02-21 12:02:10', 50.00, 1, '2026-02-21 12:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(395, '鲁W82624', 363, '2026-02-25 18:51:10', '2026-02-27 09:45:10', 97.00, 1, '2026-02-27 09:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(396, '琼R18686', 488, '2026-03-14 12:03:10', '2026-03-16 10:01:10', 100.00, 1, '2026-03-16 10:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(397, '冀D50151', 350, '2026-02-20 21:47:10', '2026-02-23 02:10:10', 117.00, 1, '2026-02-23 02:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(398, '辽Y88860', 75, '2026-02-24 14:49:10', '2026-02-25 20:45:10', 70.00, 1, '2026-02-25 20:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(399, '青U54706', 65, '2026-03-01 03:20:10', '2026-03-01 06:44:10', 14.00, 1, '2026-03-01 06:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(400, '贵Q60958', 149, '2026-03-04 11:23:10', '2026-03-06 00:06:10', 91.00, 1, '2026-03-06 00:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(401, '贵M61936', 372, '2026-03-10 11:54:10', '2026-03-11 08:15:10', 50.00, 1, '2026-03-11 08:24:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(402, '黑S00473', 218, '2026-03-05 06:34:10', '2026-03-05 07:41:10', 8.00, 1, '2026-03-05 07:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(403, '闽H79692', 140, '2026-03-04 18:24:10', '2026-03-05 12:57:10', 50.00, 1, '2026-03-05 12:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(404, '苏R86312', 95, '2026-03-04 21:18:10', '2026-03-06 17:22:10', 100.00, 1, '2026-03-06 17:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(405, '湘V30434', 266, '2026-02-19 06:28:10', '2026-02-20 22:03:10', 100.00, 1, '2026-02-20 22:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(406, '蒙G00854', 473, '2026-02-21 18:22:10', '2026-02-22 19:08:10', 55.00, 1, '2026-02-22 19:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(407, '青M73561', 101, '2026-03-06 11:13:10', '2026-03-07 11:24:10', 55.00, 1, '2026-03-07 11:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(408, '宁K09955', 285, '2026-02-21 08:31:10', '2026-02-24 03:38:10', 150.00, 1, '2026-02-24 03:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(409, '青X15676', 205, '2026-03-13 02:30:10', '2026-03-14 01:10:10', 50.00, 1, '2026-03-14 01:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(410, '陕C29802', 174, '2026-03-13 02:28:10', '2026-03-15 23:26:10', 150.00, 1, '2026-03-15 23:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(411, '蒙L21912', 456, '2026-03-16 11:28:10', '2026-03-17 00:41:10', 44.00, 1, '2026-03-17 00:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(412, '川V54411', 357, '2026-02-18 09:13:10', '2026-02-20 06:08:10', 100.00, 1, '2026-02-20 06:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(413, '甘Z18596', 50, '2026-03-14 20:22:10', '2026-03-16 03:31:10', 76.00, 1, '2026-03-16 03:26:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(414, '闽X72485', 229, '2026-02-27 06:04:10', '2026-02-27 09:47:10', 14.00, 1, '2026-02-27 09:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(415, '桂W24803', 55, '2026-03-17 18:00:10', '2026-03-19 02:06:10', 79.00, 1, '2026-03-19 02:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(416, '晋W32844', 363, '2026-03-16 21:32:10', '2026-03-18 04:57:10', 76.00, 1, '2026-03-18 04:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(417, '沪S28218', 488, '2026-02-26 06:51:10', '2026-02-27 05:37:10', 50.00, 1, '2026-02-27 05:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(418, '豫K41183', 315, '2026-02-21 13:08:10', '2026-02-23 15:48:10', 111.00, 1, '2026-02-23 15:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(419, '青J06724', 340, '2026-03-04 01:57:10', '2026-03-04 13:58:10', 41.00, 1, '2026-03-04 13:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(420, '藏D83793', 304, '2026-03-06 06:34:10', '2026-03-07 19:45:10', 94.00, 1, '2026-03-07 19:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(421, '甘Q62165', 239, '2026-03-11 06:59:10', '2026-03-13 00:44:10', 100.00, 1, '2026-03-13 00:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(422, '沪S42734', 254, '2026-03-08 18:46:10', '2026-03-10 16:29:10', 100.00, 1, '2026-03-10 16:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(423, '浙C81251', 48, '2026-02-25 08:44:10', '2026-02-25 09:30:10', 5.00, 1, '2026-02-25 09:22:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(424, '桂V02081', 461, '2026-03-08 03:11:10', '2026-03-10 06:28:10', 114.00, 1, '2026-03-10 06:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(425, '藏N10364', 207, '2026-03-04 14:14:10', '2026-03-05 06:31:10', 50.00, 1, '2026-03-05 06:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(426, '陕F58227', 179, '2026-03-06 02:00:10', '2026-03-08 07:02:10', 120.00, 1, '2026-03-08 06:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(427, '粤B56462', 494, '2026-03-09 12:09:10', '2026-03-11 18:10:10', 123.00, 1, '2026-03-11 18:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(428, '粤V59070', 95, '2026-02-27 02:51:10', '2026-03-01 11:28:10', 129.00, 1, '2026-03-01 11:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(429, '辽L02489', 248, '2026-03-14 20:45:10', '2026-03-15 04:35:10', 26.00, 1, '2026-03-15 04:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(430, '藏R68833', 63, '2026-03-14 21:12:10', '2026-03-16 23:27:10', 111.00, 1, '2026-03-16 23:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(431, '陕M93875', 255, '2026-03-01 14:23:10', '2026-03-03 07:52:10', 100.00, 1, '2026-03-03 07:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(432, '青T66777', 145, '2026-03-04 11:54:10', '2026-03-05 23:21:10', 88.00, 1, '2026-03-05 23:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(433, '蒙G36558', 426, '2026-02-28 07:29:10', '2026-03-03 00:32:10', 150.00, 1, '2026-03-03 00:26:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(434, '辽T79353', 25, '2026-03-03 19:47:10', '2026-03-04 08:36:10', 41.00, 1, '2026-03-04 08:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(435, '浙F34064', 306, '2026-02-28 18:44:10', '2026-03-02 14:38:10', 100.00, 1, '2026-03-02 14:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(436, '湘E16676', 483, '2026-03-11 20:03:10', '2026-03-14 14:50:10', 150.00, 1, '2026-03-14 14:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(437, '闽R88792', 20, '2026-03-17 06:24:10', '2026-03-18 01:42:10', 50.00, 1, '2026-03-18 01:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(438, '豫F36741', 33, '2026-03-11 08:52:10', '2026-03-13 09:50:10', 105.00, 1, '2026-03-13 09:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(439, '浙R94090', 39, '2026-02-23 07:28:10', '2026-02-23 22:02:10', 47.00, 1, '2026-02-23 22:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(440, '鄂Z58739', 40, '2026-02-17 06:09:10', '2026-02-19 20:12:10', 147.00, 1, '2026-02-19 20:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(441, '津D09849', 482, '2026-03-11 02:51:10', '2026-03-11 06:03:10', 14.00, 1, '2026-03-11 06:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(442, '闽M42703', 210, '2026-03-05 10:12:10', '2026-03-06 11:56:10', 58.00, 1, '2026-03-06 11:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(443, '贵R40077', 434, '2026-02-28 18:24:10', '2026-03-02 15:12:10', 100.00, 1, '2026-03-02 15:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(444, '鲁C55644', 431, '2026-03-16 10:41:10', '2026-03-17 12:47:10', 61.00, 1, '2026-03-17 12:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(445, '陕F61100', 404, '2026-03-04 20:38:10', '2026-03-07 00:22:10', 114.00, 1, '2026-03-07 00:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(446, '沪X47445', 446, '2026-03-09 01:24:10', '2026-03-11 17:43:10', 150.00, 1, '2026-03-11 17:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(447, '贵M38945', 256, '2026-03-05 00:31:10', '2026-03-07 01:10:10', 105.00, 1, '2026-03-07 01:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(448, '桂D35410', 145, '2026-02-23 13:44:10', '2026-02-24 22:10:10', 79.00, 1, '2026-02-24 22:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(449, '沪H36024', 263, '2026-03-02 11:59:10', '2026-03-04 06:40:10', 100.00, 1, '2026-03-04 06:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(450, '津S46596', 42, '2026-02-24 06:34:10', '2026-02-26 23:03:10', 150.00, 1, '2026-02-26 22:57:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(451, '川K96243', 382, '2026-02-23 00:20:10', '2026-02-23 22:43:10', 50.00, 1, '2026-02-23 22:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(452, '湘V42195', 365, '2026-03-05 15:50:10', '2026-03-06 23:24:10', 76.00, 1, '2026-03-06 23:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(453, '川Z57175', 115, '2026-03-17 13:38:10', '2026-03-19 01:29:10', 88.00, 1, '2026-03-19 01:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(454, '甘D07508', 217, '2026-02-20 14:12:10', '2026-02-20 22:49:10', 29.00, 1, '2026-02-20 22:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(455, '青E35945', 337, '2026-03-14 17:28:10', '2026-03-16 04:37:10', 88.00, 1, '2026-03-16 04:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(456, '皖W51462', 26, '2026-03-18 00:57:10', '2026-03-18 16:25:10', 50.00, 1, '2026-03-18 16:26:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(457, '青F29541', 486, '2026-03-12 07:57:10', '2026-03-15 04:05:10', 150.00, 1, '2026-03-15 04:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(458, '甘D40314', 434, '2026-02-24 12:09:10', '2026-02-25 19:48:10', 76.00, 1, '2026-02-25 19:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(459, '黑Z23834', 437, '2026-03-10 19:33:10', '2026-03-12 04:21:10', 79.00, 1, '2026-03-12 04:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(460, '贵H48618', 505, '2026-03-15 02:11:10', '2026-03-15 23:47:10', 50.00, 1, '2026-03-15 23:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(461, '苏H54806', 332, '2026-02-27 16:40:10', '2026-02-28 16:34:10', 55.00, 1, '2026-02-28 16:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(462, '渝Z48619', 185, '2026-02-26 06:46:10', '2026-02-27 01:17:10', 50.00, 1, '2026-02-27 01:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(463, '闽S73145', 505, '2026-02-21 12:00:10', '2026-02-24 05:51:10', 150.00, 1, '2026-02-24 06:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(464, '鄂M65312', 301, '2026-02-28 18:08:10', '2026-03-02 01:38:10', 76.00, 1, '2026-03-02 01:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(465, '京S64461', 158, '2026-03-08 09:44:10', '2026-03-11 09:21:10', 155.00, 1, '2026-03-11 09:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(466, '沪S28209', 81, '2026-03-01 19:30:10', '2026-03-04 08:54:10', 144.00, 1, '2026-03-04 08:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(467, '青Z28086', 370, '2026-02-23 17:19:10', '2026-02-24 13:00:10', 50.00, 1, '2026-02-24 13:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(468, '苏Z67549', 129, '2026-02-28 05:15:10', '2026-03-02 05:28:10', 105.00, 1, '2026-03-02 05:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(469, '沪N30383', 505, '2026-02-21 06:47:10', '2026-02-23 21:20:10', 147.00, 1, '2026-02-23 21:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(470, '渝B15091', 430, '2026-03-17 18:42:10', '2026-03-19 02:07:10', 76.00, 1, '2026-03-19 02:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(471, '粤H80223', 4, '2026-03-03 13:29:10', '2026-03-04 09:43:10', 50.00, 1, '2026-03-04 09:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(472, '蒙U68450', 186, '2026-03-03 05:49:10', '2026-03-04 23:43:10', 100.00, 1, '2026-03-04 23:50:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(473, '鲁R02814', 317, '2026-03-12 11:25:10', '2026-03-14 17:10:10', 120.00, 1, '2026-03-14 17:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(474, '鄂F48834', 206, '2026-03-14 23:55:10', '2026-03-15 10:45:10', 35.00, 1, '2026-03-15 10:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(475, '黑D32775', 348, '2026-03-07 11:08:10', '2026-03-07 20:42:10', 32.00, 1, '2026-03-07 20:36:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(476, '浙E33595', 77, '2026-03-11 15:09:10', '2026-03-12 11:03:10', 50.00, 1, '2026-03-12 11:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(477, '沪J60841', 433, '2026-02-16 03:50:10', '2026-02-18 04:25:10', 105.00, 1, '2026-02-18 04:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(478, '宁Z38247', 453, '2026-03-09 00:42:10', '2026-03-09 11:45:10', 38.00, 1, '2026-03-09 11:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(479, '湘N79206', 106, '2026-03-10 17:12:10', '2026-03-12 23:31:10', 123.00, 1, '2026-03-12 23:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(480, '黑Q32464', 195, '2026-02-24 21:04:10', '2026-02-25 21:33:10', 55.00, 1, '2026-02-25 21:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(481, '辽N95898', 440, '2026-03-13 04:54:10', '2026-03-15 09:04:10', 117.00, 1, '2026-03-15 09:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(482, '皖T85916', 240, '2026-03-02 12:20:10', '2026-03-05 00:55:10', 141.00, 1, '2026-03-05 00:57:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(483, '桂R55374', 80, '2026-03-16 03:07:10', '2026-03-17 15:04:10', 88.00, 1, '2026-03-17 15:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(484, '甘F11808', 177, '2026-03-11 13:24:10', '2026-03-13 21:20:10', 126.00, 1, '2026-03-13 21:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(485, '赣E36835', 24, '2026-03-11 01:35:10', '2026-03-12 15:13:10', 94.00, 1, '2026-03-12 15:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(486, '川P05513', 199, '2026-03-16 21:41:10', '2026-03-17 13:10:10', 50.00, 1, '2026-03-17 13:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(487, '鲁F95945', 358, '2026-02-27 13:22:10', '2026-02-28 21:57:10', 79.00, 1, '2026-02-28 21:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(488, '闽P81021', 71, '2026-03-06 20:04:10', '2026-03-08 12:17:10', 100.00, 1, '2026-03-08 12:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(489, '琼D40721', 177, '2026-02-17 14:57:10', '2026-02-18 05:57:10', 47.00, 1, '2026-02-18 05:48:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(490, '蒙J33546', 156, '2026-03-08 18:07:10', '2026-03-11 11:40:10', 150.00, 1, '2026-03-11 11:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(491, '皖P17896', 271, '2026-03-16 22:09:10', '2026-03-19 01:48:10', 114.00, 1, '2026-03-19 01:50:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(492, '甘P48968', 27, '2026-03-07 19:59:10', '2026-03-10 01:19:10', 120.00, 1, '2026-03-10 01:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(493, '豫W44070', 265, '2026-02-27 10:29:10', '2026-03-01 11:53:10', 108.00, 1, '2026-03-01 11:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(494, '黑Q10969', 254, '2026-02-17 21:40:10', '2026-02-20 10:14:10', 141.00, 1, '2026-02-20 10:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(495, '赣M06635', 170, '2026-03-12 01:25:10', '2026-03-13 14:40:10', 94.00, 1, '2026-03-13 14:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(496, '川H91254', 7, '2026-03-17 09:24:10', '2026-03-19 01:23:10', 100.00, 1, '2026-03-19 01:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(497, '桂P76519', 281, '2026-03-03 02:27:10', '2026-03-05 12:25:10', 132.00, 1, '2026-03-05 12:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(498, '粤Y59459', 144, '2026-03-01 02:22:10', '2026-03-01 09:17:10', 23.00, 1, '2026-03-01 09:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(499, '皖A79117', 142, '2026-02-18 07:51:10', '2026-02-20 00:38:10', 100.00, 1, '2026-02-20 00:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(500, '赣J03638', 138, '2026-02-25 01:57:10', '2026-02-27 19:37:10', 150.00, 1, '2026-02-27 19:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(501, '青H13198', 51, '2026-02-18 05:11:10', '2026-02-19 21:00:10', 100.00, 1, '2026-02-19 21:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(502, '桂A37044', 59, '2026-02-17 23:59:10', '2026-02-20 05:45:10', 120.00, 1, '2026-02-20 05:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(503, '沪T29991', 265, '2026-02-17 22:01:10', '2026-02-19 19:51:10', 100.00, 1, '2026-02-19 19:49:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(504, '闽J91346', 120, '2026-03-03 03:05:10', '2026-03-06 00:44:10', 150.00, 1, '2026-03-06 00:37:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(505, '赣W44682', 258, '2026-02-26 21:43:10', '2026-02-27 10:16:10', 41.00, 1, '2026-02-27 10:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(506, '蒙L58127', 323, '2026-03-10 01:38:10', '2026-03-11 04:59:10', 64.00, 1, '2026-03-11 05:03:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(507, '粤Z00685', 217, '2026-03-08 01:39:10', '2026-03-09 21:32:10', 100.00, 1, '2026-03-09 21:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(508, '鄂U75806', 407, '2026-03-03 07:26:10', '2026-03-04 07:35:10', 55.00, 1, '2026-03-04 07:30:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(509, '云L28929', 2, '2026-02-19 05:06:10', '2026-02-22 01:37:10', 150.00, 1, '2026-02-22 01:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(510, '贵N45040', 255, '2026-03-01 04:57:10', '2026-03-02 09:15:10', 67.00, 1, '2026-03-02 09:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(511, '鄂Q67483', 133, '2026-03-12 02:15:10', '2026-03-15 01:19:10', 155.00, 1, '2026-03-15 01:26:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(512, '藏V39461', 263, '2026-03-14 19:31:10', '2026-03-15 06:29:10', 35.00, 1, '2026-03-15 06:30:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(513, '湘M79882', 201, '2026-03-09 21:52:10', '2026-03-11 20:59:10', 105.00, 1, '2026-03-11 20:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(514, '桂C61230', 499, '2026-02-24 06:42:10', '2026-02-25 19:05:10', 91.00, 1, '2026-02-25 19:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(515, '陕V96661', 236, '2026-02-26 07:48:10', '2026-02-26 15:16:10', 26.00, 1, '2026-02-26 15:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(516, '沪R05427', 240, '2026-03-15 03:25:10', '2026-03-16 16:05:10', 91.00, 1, '2026-03-16 16:01:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(517, '云T46440', 444, '2026-03-11 08:13:10', '2026-03-12 13:49:10', 70.00, 1, '2026-03-12 13:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(518, '晋T13129', 19, '2026-03-09 02:55:10', '2026-03-11 20:03:10', 150.00, 1, '2026-03-11 20:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(519, '桂Z48521', 81, '2026-03-02 10:04:10', '2026-03-02 23:43:10', 44.00, 1, '2026-03-02 23:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(520, '宁A77917', 19, '2026-03-03 15:25:10', '2026-03-06 09:12:10', 150.00, 1, '2026-03-06 09:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(521, '赣Z95026', 146, '2026-03-06 01:12:10', '2026-03-08 23:26:10', 150.00, 1, '2026-03-08 23:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(522, '粤X39495', 149, '2026-02-18 11:37:10', '2026-02-20 21:48:10', 135.00, 1, '2026-02-20 21:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(523, '吉Z12490', 301, '2026-03-17 21:07:10', '2026-03-19 01:45:10', 67.00, 1, '2026-03-19 01:37:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(524, '桂P08068', 364, '2026-03-02 15:58:10', '2026-03-03 10:27:10', 50.00, 1, '2026-03-03 10:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(525, '鲁Y54300', 387, '2026-02-22 05:16:10', '2026-02-22 09:26:10', 17.00, 1, '2026-02-22 09:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(526, '蒙T65409', 150, '2026-02-27 15:41:10', '2026-03-02 01:34:10', 132.00, 1, '2026-03-02 01:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(527, '陕R40416', 29, '2026-02-17 20:27:10', '2026-02-20 12:35:10', 150.00, 1, '2026-02-20 12:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(528, '津H24499', 113, '2026-02-24 20:03:10', '2026-02-26 14:52:10', 100.00, 1, '2026-02-26 14:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(529, '贵H77596', 315, '2026-03-14 07:50:10', '2026-03-16 16:14:10', 129.00, 1, '2026-03-16 16:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(530, '甘S37499', 453, '2026-03-08 02:57:10', '2026-03-09 14:47:10', 88.00, 1, '2026-03-09 14:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(531, '晋Q87563', 332, '2026-02-18 18:18:10', '2026-02-20 17:18:10', 100.00, 1, '2026-02-20 17:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(532, '蒙Y78608', 394, '2026-03-12 11:39:10', '2026-03-14 08:45:10', 100.00, 1, '2026-03-14 08:36:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(533, '青E18614', 423, '2026-02-28 06:52:10', '2026-02-28 23:05:10', 50.00, 1, '2026-02-28 23:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(534, '黑B71419', 16, '2026-03-03 00:54:10', '2026-03-05 12:05:10', 138.00, 1, '2026-03-05 12:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(535, '皖Q51631', 226, '2026-02-24 17:27:10', '2026-02-25 19:00:10', 58.00, 1, '2026-02-25 18:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(536, '甘S73028', 229, '2026-03-11 21:57:10', '2026-03-14 01:33:10', 114.00, 1, '2026-03-14 01:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(537, '鄂U83752', 466, '2026-03-16 20:52:10', '2026-03-18 08:00:10', 88.00, 1, '2026-03-18 07:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(538, '赣S09791', 132, '2026-02-24 21:29:10', '2026-02-27 15:32:10', 150.00, 1, '2026-02-27 15:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(539, '晋H29916', 429, '2026-02-21 10:33:10', '2026-02-23 03:59:10', 100.00, 1, '2026-02-23 04:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(540, '豫P23338', 42, '2026-02-22 04:36:10', '2026-02-24 06:11:10', 108.00, 1, '2026-02-24 06:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(541, '吉K40402', 372, '2026-02-27 01:50:10', '2026-02-28 08:19:10', 73.00, 1, '2026-02-28 08:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(542, '冀X09763', 367, '2026-03-15 19:24:10', '2026-03-17 22:46:10', 114.00, 1, '2026-03-17 22:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(543, '鄂K87749', 248, '2026-02-22 16:50:10', '2026-02-25 02:13:10', 132.00, 1, '2026-02-25 02:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(544, '津L50761', 160, '2026-03-12 08:51:10', '2026-03-14 16:42:10', 126.00, 1, '2026-03-14 16:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(545, '豫K04684', 11, '2026-03-14 08:50:10', '2026-03-15 15:57:10', 76.00, 1, '2026-03-15 15:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(546, '藏Y29450', 118, '2026-03-01 01:10:10', '2026-03-01 21:22:10', 50.00, 1, '2026-03-01 21:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(547, '粤M32012', 1, '2026-03-05 18:59:10', '2026-03-07 03:10:10', 79.00, 1, '2026-03-07 03:10:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(548, '黑J65672', 375, '2026-02-17 01:58:10', '2026-02-18 04:08:10', 61.00, 1, '2026-02-18 04:10:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(549, '琼G73914', 113, '2026-03-12 07:24:10', '2026-03-15 01:15:10', 150.00, 1, '2026-03-15 01:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(550, '冀A42296', 22, '2026-03-03 12:15:10', '2026-03-05 18:08:10', 120.00, 1, '2026-03-05 17:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(551, '湘P83499', 185, '2026-02-17 04:56:10', '2026-02-18 00:00:10', 50.00, 1, '2026-02-17 23:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(552, '晋C93407', 106, '2026-02-28 00:25:10', '2026-02-28 04:52:10', 17.00, 1, '2026-02-28 04:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(553, '浙L89921', 412, '2026-03-15 05:38:10', '2026-03-17 13:30:10', 126.00, 1, '2026-03-17 13:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(554, '陕R24296', 382, '2026-03-13 04:10:10', '2026-03-13 10:13:10', 23.00, 1, '2026-03-13 10:03:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(555, '吉U41463', 154, '2026-02-22 13:39:10', '2026-02-23 20:17:10', 73.00, 1, '2026-02-23 20:24:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(556, '豫Y33405', 227, '2026-02-22 09:31:10', '2026-02-24 15:32:10', 123.00, 1, '2026-02-24 15:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(557, '冀L27701', 362, '2026-03-09 01:18:10', '2026-03-10 20:19:10', 100.00, 1, '2026-03-10 20:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(558, '冀Y54663', 379, '2026-03-07 18:16:10', '2026-03-07 21:34:10', 14.00, 1, '2026-03-07 21:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(559, '湘U34758', 364, '2026-02-17 07:23:10', '2026-02-19 00:05:10', 100.00, 1, '2026-02-18 23:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(560, '沪T76710', 315, '2026-02-22 17:47:10', '2026-02-24 15:22:10', 100.00, 1, '2026-02-24 15:22:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(561, '冀U92312', 71, '2026-03-05 04:58:10', '2026-03-08 03:24:10', 150.00, 1, '2026-03-08 03:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(562, '鄂Y35354', 350, '2026-03-06 12:47:10', '2026-03-07 16:33:10', 64.00, 1, '2026-03-07 16:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(563, '渝R43838', 140, '2026-02-25 23:17:10', '2026-02-26 18:50:10', 50.00, 1, '2026-02-26 18:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(564, '湘F74241', 30, '2026-03-17 17:45:10', '2026-03-19 02:06:10', 79.00, 1, '2026-03-19 02:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(565, '鄂E00483', 6, '2026-03-11 09:46:10', '2026-03-13 09:00:10', 105.00, 1, '2026-03-13 08:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(566, '蒙P91798', 330, '2026-02-23 17:31:10', '2026-02-25 07:21:10', 94.00, 1, '2026-02-25 07:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(567, '陕G33222', 390, '2026-03-17 17:11:10', '2026-03-18 05:19:10', 41.00, 1, '2026-03-18 05:24:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(568, '浙P23648', 85, '2026-03-14 23:45:10', '2026-03-16 00:48:10', 58.00, 1, '2026-03-16 00:57:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(569, '赣W88509', 506, '2026-02-21 18:47:10', '2026-02-23 18:18:10', 105.00, 1, '2026-02-23 18:26:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(570, '青A96983', 378, '2026-03-09 17:54:10', '2026-03-11 14:00:10', 100.00, 1, '2026-03-11 13:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(571, '川W92348', 269, '2026-03-15 09:36:10', '2026-03-15 23:10:10', 44.00, 1, '2026-03-15 23:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(572, '贵L04837', 259, '2026-03-04 06:02:10', '2026-03-05 07:32:10', 58.00, 1, '2026-03-05 07:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(573, '闽N53233', 370, '2026-02-18 00:12:10', '2026-02-20 23:41:10', 155.00, 1, '2026-02-20 23:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(574, '苏Z84827', 440, '2026-03-06 01:59:10', '2026-03-07 14:21:10', 91.00, 1, '2026-03-07 14:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(575, '吉Q58599', 251, '2026-03-05 14:35:10', '2026-03-07 03:16:10', 91.00, 1, '2026-03-07 03:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(576, '沪U34707', 237, '2026-02-18 17:30:10', '2026-02-19 10:12:10', 50.00, 1, '2026-02-19 10:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(577, '云U93226', 283, '2026-02-26 23:16:10', '2026-02-28 19:55:10', 100.00, 1, '2026-02-28 20:03:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(578, '青G48145', 76, '2026-02-26 04:20:10', '2026-02-26 20:37:10', 50.00, 1, '2026-02-26 20:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(579, '冀E18414', 454, '2026-03-05 08:23:10', '2026-03-06 19:56:10', 88.00, 1, '2026-03-06 19:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(580, '皖A17037', 10, '2026-03-03 19:34:10', '2026-03-05 18:12:10', 100.00, 1, '2026-03-05 18:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(581, '甘Z63188', 392, '2026-03-04 13:03:10', '2026-03-06 05:43:10', 100.00, 1, '2026-03-06 05:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(582, '沪Q78604', 409, '2026-02-17 22:50:10', '2026-02-19 07:20:10', 79.00, 1, '2026-02-19 07:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(583, '晋R89779', 498, '2026-03-11 10:44:10', '2026-03-13 22:45:10', 141.00, 1, '2026-03-13 22:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(584, '沪E21402', 26, '2026-02-25 13:01:10', '2026-02-26 09:07:10', 50.00, 1, '2026-02-26 09:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(585, '冀T70098', 330, '2026-03-04 16:53:10', '2026-03-06 07:40:10', 97.00, 1, '2026-03-06 07:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(586, '冀S34727', 267, '2026-03-06 06:58:10', '2026-03-06 16:03:10', 32.00, 1, '2026-03-06 15:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(587, '湘X46158', 353, '2026-03-09 04:51:10', '2026-03-11 05:40:10', 105.00, 1, '2026-03-11 05:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(588, '宁K02483', 392, '2026-03-02 00:46:10', '2026-03-02 05:45:10', 17.00, 1, '2026-03-02 05:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(589, '甘J67434', 394, '2026-02-25 21:45:10', '2026-02-26 08:11:10', 35.00, 1, '2026-02-26 08:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(590, '津P62109', 163, '2026-02-26 03:34:10', '2026-02-27 10:58:10', 76.00, 1, '2026-02-27 11:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(591, '琼L23971', 218, '2026-02-19 09:52:10', '2026-02-19 13:59:10', 17.00, 1, '2026-02-19 14:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(592, '青W58334', 71, '2026-03-17 22:13:10', '2026-03-18 03:37:10', 20.00, 1, '2026-03-18 03:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(593, '沪D63165', 286, '2026-03-05 12:31:10', '2026-03-06 14:20:10', 58.00, 1, '2026-03-06 14:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(594, '闽S71694', 497, '2026-03-08 04:36:10', '2026-03-10 12:17:10', 126.00, 1, '2026-03-10 12:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(595, '宁G11499', 390, '2026-02-23 22:15:10', '2026-02-24 01:44:10', 14.00, 1, '2026-02-24 01:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(596, '闽J64127', 11, '2026-03-15 21:06:10', '2026-03-17 05:17:10', 79.00, 1, '2026-03-17 05:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(597, '鲁Y38526', 278, '2026-02-27 18:00:10', '2026-02-28 17:14:10', 55.00, 1, '2026-02-28 17:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(598, '辽W98691', 58, '2026-03-14 09:48:10', '2026-03-15 01:45:10', 50.00, 1, '2026-03-15 01:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(599, '渝B91399', 371, '2026-02-21 19:01:10', '2026-02-22 16:29:10', 50.00, 1, '2026-02-22 16:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(600, '京C88951', 34, '2026-03-17 18:45:10', '2026-03-18 04:40:10', 32.00, 1, '2026-03-18 04:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(601, '沪X81523', 348, '2026-02-21 09:15:10', '2026-02-21 23:25:10', 47.00, 1, '2026-02-21 23:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(602, '浙G67674', 335, '2026-03-04 02:47:10', '2026-03-06 05:47:10', 111.00, 1, '2026-03-06 05:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(603, '吉W46509', 160, '2026-02-20 23:30:10', '2026-02-21 08:56:10', 32.00, 1, '2026-02-21 08:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(604, '鲁K88636', 272, '2026-03-15 03:56:10', '2026-03-16 09:32:10', 70.00, 1, '2026-03-16 09:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(605, '宁B28870', 55, '2026-02-26 23:58:10', '2026-02-28 09:54:10', 82.00, 1, '2026-02-28 10:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(606, '晋F55237', 499, '2026-03-14 15:43:10', '2026-03-15 05:27:10', 44.00, 1, '2026-03-15 05:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(607, '苏F86176', 473, '2026-03-12 10:17:10', '2026-03-13 06:44:10', 50.00, 1, '2026-03-13 06:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(608, '津C79141', 118, '2026-03-05 05:11:10', '2026-03-06 18:43:10', 94.00, 1, '2026-03-06 18:50:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(609, '闽R76776', 250, '2026-03-05 17:32:10', '2026-03-07 18:32:10', 105.00, 1, '2026-03-07 18:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(610, '贵U67066', 125, '2026-03-12 21:17:10', '2026-03-15 04:08:10', 123.00, 1, '2026-03-15 04:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(611, '晋A86486', 176, '2026-03-11 11:42:10', '2026-03-12 12:53:10', 58.00, 1, '2026-03-12 12:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(612, '云U29494', 215, '2026-03-02 22:30:10', '2026-03-04 06:35:10', 79.00, 1, '2026-03-04 06:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(613, '晋D56605', 494, '2026-02-18 18:48:10', '2026-02-20 21:12:10', 111.00, 1, '2026-02-20 21:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(614, '豫X11824', 470, '2026-02-28 10:56:10', '2026-03-02 07:18:10', 100.00, 1, '2026-03-02 07:26:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(615, '闽A72474', 474, '2026-02-22 13:59:10', '2026-02-25 01:22:10', 138.00, 1, '2026-02-25 01:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(616, '湘Y45664', 508, '2026-03-13 15:53:10', '2026-03-16 10:06:10', 150.00, 1, '2026-03-16 10:10:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(617, '黑Q16954', 477, '2026-03-02 20:05:10', '2026-03-04 10:20:10', 97.00, 1, '2026-03-04 10:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(618, '黑S38809', 164, '2026-02-24 12:47:10', '2026-02-24 22:10:10', 32.00, 1, '2026-02-24 22:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(619, '晋Y53106', 58, '2026-03-03 07:57:10', '2026-03-06 04:49:10', 150.00, 1, '2026-03-06 04:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(620, '甘F65231', 238, '2026-03-06 00:52:10', '2026-03-06 04:39:10', 14.00, 1, '2026-03-06 04:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(621, '冀U34455', 24, '2026-02-19 20:36:10', '2026-02-20 00:35:10', 14.00, 1, '2026-02-20 00:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(622, '湘C50712', 248, '2026-03-17 11:20:10', '2026-03-18 01:57:10', 47.00, 1, '2026-03-18 01:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(623, '苏N06444', 179, '2026-03-16 04:07:10', '2026-03-16 23:40:10', 50.00, 1, '2026-03-16 23:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(624, '湘H88060', 450, '2026-03-16 17:47:10', '2026-03-19 01:37:10', 126.00, 1, '2026-03-19 01:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(625, '津J98449', 336, '2026-02-20 00:15:10', '2026-02-22 22:45:10', 150.00, 1, '2026-02-22 22:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(626, '闽J14594', 119, '2026-03-16 17:05:10', '2026-03-17 14:20:10', 50.00, 1, '2026-03-17 14:24:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(627, '津H77795', 143, '2026-03-15 18:50:10', '2026-03-17 18:52:10', 105.00, 1, '2026-03-17 18:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(628, '鄂C11729', 389, '2026-02-21 06:17:10', '2026-02-22 01:48:10', 50.00, 1, '2026-02-22 01:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(629, '湘J63353', 474, '2026-03-08 05:58:10', '2026-03-10 14:36:10', 129.00, 1, '2026-03-10 14:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(630, '闽K63002', 70, '2026-02-27 21:40:10', '2026-02-28 05:21:10', 26.00, 1, '2026-02-28 05:30:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(631, '青S02395', 413, '2026-02-21 16:47:10', '2026-02-23 18:47:10', 108.00, 1, '2026-02-23 18:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(632, '辽H66778', 129, '2026-03-03 16:09:10', '2026-03-04 14:44:10', 50.00, 1, '2026-03-04 14:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(633, '冀C31985', 381, '2026-03-08 08:34:10', '2026-03-08 16:59:10', 29.00, 1, '2026-03-08 16:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(634, '京S07745', 65, '2026-03-14 05:43:10', '2026-03-16 16:46:10', 138.00, 1, '2026-03-16 16:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(635, '青L77841', 445, '2026-02-19 03:37:10', '2026-02-21 07:09:10', 114.00, 1, '2026-02-21 07:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(636, '闽T81480', 498, '2026-02-25 05:09:10', '2026-02-27 11:03:10', 120.00, 1, '2026-02-27 11:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(637, '云L98768', 287, '2026-03-17 13:11:10', '2026-03-17 14:40:10', 8.00, 1, '2026-03-17 14:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(638, '蒙U88788', 144, '2026-03-09 14:05:10', '2026-03-10 20:39:10', 73.00, 1, '2026-03-10 20:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(639, '陕W21255', 160, '2026-02-26 02:29:10', '2026-02-28 04:23:10', 108.00, 1, '2026-02-28 04:30:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(640, '黑S09583', 1, '2026-03-12 08:59:10', '2026-03-13 03:10:10', 50.00, 1, '2026-03-13 03:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(641, '藏A22014', 144, '2026-03-11 01:01:10', '2026-03-13 08:28:10', 126.00, 1, '2026-03-13 08:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(642, '皖M71495', 202, '2026-03-01 13:16:10', '2026-03-04 05:48:10', 150.00, 1, '2026-03-04 05:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(643, '蒙Q19621', 314, '2026-02-25 17:08:10', '2026-02-27 12:36:10', 100.00, 1, '2026-02-27 12:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(644, '苏L09039', 367, '2026-03-13 19:38:10', '2026-03-15 16:46:10', 100.00, 1, '2026-03-15 16:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(645, '皖H54568', 97, '2026-02-27 18:46:10', '2026-02-28 14:54:10', 50.00, 1, '2026-02-28 15:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(646, '藏R17815', 309, '2026-03-05 18:49:10', '2026-03-07 09:46:10', 97.00, 1, '2026-03-07 09:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(647, '青X50175', 18, '2026-02-28 10:47:10', '2026-03-02 10:09:10', 105.00, 1, '2026-03-02 10:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(648, '粤E72778', 298, '2026-02-19 21:35:10', '2026-02-22 13:12:10', 150.00, 1, '2026-02-22 13:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(649, '青Z52776', 237, '2026-03-03 13:04:10', '2026-03-05 04:42:10', 100.00, 1, '2026-03-05 04:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(650, '苏G07764', 492, '2026-03-10 17:24:10', '2026-03-13 14:16:10', 150.00, 1, '2026-03-13 14:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(651, '沪N64288', 137, '2026-03-09 23:16:10', '2026-03-11 00:47:10', 58.00, 1, '2026-03-11 00:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(652, '贵A25588', 292, '2026-03-01 15:41:10', '2026-03-04 08:17:10', 150.00, 1, '2026-03-04 08:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(653, '黑M36655', 76, '2026-02-25 23:45:10', '2026-02-27 07:22:10', 76.00, 1, '2026-02-27 07:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(654, '京Y85799', 403, '2026-03-03 16:12:10', '2026-03-04 16:54:10', 55.00, 1, '2026-03-04 16:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(655, '湘V13078', 36, '2026-02-27 04:45:10', '2026-02-27 15:24:10', 35.00, 1, '2026-02-27 15:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(656, '云B36375', 334, '2026-02-27 22:33:10', '2026-02-28 02:09:10', 14.00, 1, '2026-02-28 02:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(657, '皖B52493', 116, '2026-02-25 11:05:10', '2026-02-27 10:16:10', 105.00, 1, '2026-02-27 10:22:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(658, '琼Q40244', 119, '2026-03-02 12:51:10', '2026-03-03 06:11:10', 50.00, 1, '2026-03-03 06:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(659, '辽R79554', 423, '2026-03-08 16:40:10', '2026-03-09 10:39:10', 50.00, 1, '2026-03-09 10:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(660, '川U13316', 436, '2026-03-11 08:27:10', '2026-03-12 16:02:10', 76.00, 1, '2026-03-12 15:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(661, '吉P41116', 371, '2026-03-12 05:17:10', '2026-03-14 14:30:10', 132.00, 1, '2026-03-14 14:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(662, '蒙T41291', 424, '2026-02-27 10:02:10', '2026-03-01 07:02:10', 100.00, 1, '2026-03-01 06:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(663, '陕F98175', 464, '2026-02-22 17:13:10', '2026-02-23 19:05:10', 58.00, 1, '2026-02-23 19:01:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(664, '皖W19844', 367, '2026-02-25 00:23:10', '2026-02-27 23:28:10', 155.00, 1, '2026-02-27 23:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(665, '苏N75445', 385, '2026-02-23 00:27:10', '2026-02-25 01:29:10', 108.00, 1, '2026-02-25 01:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(666, '晋V78513', 374, '2026-02-23 20:15:10', '2026-02-24 05:16:10', 32.00, 1, '2026-02-24 05:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(667, '辽J91833', 324, '2026-02-16 21:14:10', '2026-02-18 16:49:10', 100.00, 1, '2026-02-18 16:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(668, '鲁L93254', 160, '2026-03-16 02:35:10', '2026-03-16 10:48:10', 29.00, 1, '2026-03-16 10:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(669, '甘U36289', 214, '2026-02-16 10:57:10', '2026-02-19 10:49:10', 155.00, 1, '2026-02-19 10:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(670, '晋M74185', 234, '2026-03-02 00:12:10', '2026-03-02 14:30:10', 47.00, 1, '2026-03-02 14:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(671, '川J37448', 417, '2026-03-11 06:01:10', '2026-03-13 19:05:10', 144.00, 1, '2026-03-13 19:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(672, '豫B90659', 217, '2026-02-25 18:01:10', '2026-02-26 12:19:10', 50.00, 1, '2026-02-26 12:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(673, '蒙S76695', 277, '2026-03-09 02:32:10', '2026-03-11 17:29:10', 147.00, 1, '2026-03-11 17:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(674, '吉V00683', 437, '2026-02-21 21:34:10', '2026-02-21 22:34:10', 5.00, 1, '2026-02-21 22:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(675, '贵R87634', 233, '2026-03-13 04:35:10', '2026-03-15 20:06:10', 150.00, 1, '2026-03-15 19:57:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(676, '桂K73503', 353, '2026-02-21 13:35:10', '2026-02-22 04:45:10', 50.00, 1, '2026-02-22 04:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(677, '晋F32102', 392, '2026-03-13 07:37:10', '2026-03-14 13:37:10', 70.00, 1, '2026-03-14 13:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(678, '贵N80553', 435, '2026-02-25 15:52:10', '2026-02-27 06:22:10', 97.00, 1, '2026-02-27 06:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(679, '贵U21158', 291, '2026-02-18 03:29:10', '2026-02-19 10:22:10', 73.00, 1, '2026-02-19 10:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(680, '豫L22918', 247, '2026-02-25 05:28:10', '2026-02-26 03:47:10', 50.00, 1, '2026-02-26 03:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(681, '京N60042', 33, '2026-02-18 11:39:10', '2026-02-21 05:17:10', 150.00, 1, '2026-02-21 05:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(682, '贵V58779', 114, '2026-03-07 20:02:10', '2026-03-08 03:32:10', 26.00, 1, '2026-03-08 03:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(683, '陕H48952', 39, '2026-02-19 15:34:10', '2026-02-22 06:13:10', 147.00, 1, '2026-02-22 06:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(684, '吉J05992', 387, '2026-03-09 02:08:10', '2026-03-09 23:45:10', 50.00, 1, '2026-03-09 23:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(685, '京J35809', 352, '2026-03-15 17:18:10', '2026-03-16 06:23:10', 44.00, 1, '2026-03-16 06:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(686, '湘H47857', 279, '2026-02-24 06:20:10', '2026-02-26 20:31:10', 147.00, 1, '2026-02-26 20:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(687, '吉Q38307', 149, '2026-03-09 10:12:10', '2026-03-10 18:11:10', 76.00, 1, '2026-03-10 18:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(688, '鲁H93434', 314, '2026-02-22 12:35:10', '2026-02-23 16:57:10', 67.00, 1, '2026-02-23 17:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(689, '沪S92715', 449, '2026-03-12 14:23:10', '2026-03-13 03:05:10', 41.00, 1, '2026-03-13 02:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(690, '鄂R57071', 112, '2026-03-07 13:43:10', '2026-03-07 18:38:10', 17.00, 1, '2026-03-07 18:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(691, '青D20500', 327, '2026-02-18 05:14:10', '2026-02-19 11:54:10', 73.00, 1, '2026-02-19 11:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(692, '晋Y79874', 348, '2026-02-27 23:49:10', '2026-02-28 02:31:10', 11.00, 1, '2026-02-28 02:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(693, '京Z12962', 17, '2026-02-25 22:08:10', '2026-02-28 08:56:10', 135.00, 1, '2026-02-28 09:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(694, '青G86619', 301, '2026-03-11 16:26:10', '2026-03-14 09:25:10', 150.00, 1, '2026-03-14 09:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(695, '沪C13323', 25, '2026-03-13 16:51:10', '2026-03-16 06:38:10', 144.00, 1, '2026-03-16 06:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(696, '川U51367', 484, '2026-02-22 12:19:10', '2026-02-23 13:16:10', 55.00, 1, '2026-02-23 13:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(697, '藏Y29428', 121, '2026-03-12 03:42:10', '2026-03-12 16:02:10', 41.00, 1, '2026-03-12 15:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(698, '蒙R28543', 328, '2026-02-21 06:06:10', '2026-02-24 04:59:10', 150.00, 1, '2026-02-24 05:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(699, '苏M29283', 24, '2026-02-19 05:58:10', '2026-02-22 02:55:10', 150.00, 1, '2026-02-22 02:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(700, '沪P31015', 414, '2026-02-26 01:23:10', '2026-02-26 14:54:10', 44.00, 1, '2026-02-26 14:48:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(701, '吉P44152', 88, '2026-02-20 19:54:10', '2026-02-22 16:11:10', 100.00, 1, '2026-02-22 16:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(702, '湘E45334', 152, '2026-02-17 04:30:10', '2026-02-17 12:49:10', 29.00, 1, '2026-02-17 12:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(703, '桂M58641', 96, '2026-02-24 07:19:10', '2026-02-26 08:44:10', 108.00, 1, '2026-02-26 08:48:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(704, '渝J66271', 376, '2026-02-20 21:43:10', '2026-02-22 00:07:10', 61.00, 1, '2026-02-22 00:10:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(705, '湘R34873', 160, '2026-02-26 16:21:10', '2026-02-26 23:57:10', 26.00, 1, '2026-02-26 23:49:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(706, '京E69031', 469, '2026-03-16 19:28:10', '2026-03-17 22:08:10', 61.00, 1, '2026-03-17 22:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(707, '陕G91656', 293, '2026-03-17 14:49:10', '2026-03-17 19:49:10', 17.00, 1, '2026-03-17 19:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(708, '鲁Y96748', 130, '2026-02-22 06:50:10', '2026-02-22 23:02:10', 50.00, 1, '2026-02-22 23:08:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(709, '宁F60912', 433, '2026-02-24 04:13:10', '2026-02-25 11:51:10', 76.00, 1, '2026-02-25 11:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(710, '鲁A60079', 438, '2026-02-21 09:51:10', '2026-02-23 17:33:10', 126.00, 1, '2026-02-23 17:30:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(711, '豫M65415', 115, '2026-02-20 05:30:10', '2026-02-20 21:44:10', 50.00, 1, '2026-02-20 21:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(712, '黑C97618', 73, '2026-03-05 21:54:10', '2026-03-06 06:04:10', 29.00, 1, '2026-03-06 05:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(713, '桂U18677', 282, '2026-02-28 23:12:10', '2026-03-03 02:04:10', 111.00, 1, '2026-03-03 02:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(714, '贵H02576', 98, '2026-03-02 08:34:10', '2026-03-04 06:21:10', 100.00, 1, '2026-03-04 06:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(715, '云F30674', 208, '2026-02-25 09:01:10', '2026-02-28 05:38:10', 150.00, 1, '2026-02-28 05:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(716, '沪R72183', 327, '2026-02-19 23:05:10', '2026-02-22 06:26:10', 126.00, 1, '2026-02-22 06:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(717, '陕E94293', 282, '2026-03-14 21:04:10', '2026-03-15 21:35:10', 55.00, 1, '2026-03-15 21:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(718, '晋E62150', 35, '2026-03-13 22:07:10', '2026-03-14 10:19:10', 41.00, 1, '2026-03-14 10:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(719, '湘E28314', 353, '2026-02-23 11:04:10', '2026-02-25 08:59:10', 100.00, 1, '2026-02-25 09:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(720, '赣B42730', 173, '2026-02-17 02:14:10', '2026-02-19 15:04:10', 141.00, 1, '2026-02-19 15:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(721, '藏X31393', 54, '2026-02-25 15:09:10', '2026-02-25 19:23:10', 17.00, 1, '2026-02-25 19:30:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(722, '赣S91734', 23, '2026-03-02 20:31:10', '2026-03-04 17:35:10', 100.00, 1, '2026-03-04 17:36:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(723, '赣V98443', 2, '2026-02-16 23:49:10', '2026-02-18 05:52:10', 73.00, 1, '2026-02-18 05:49:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(724, '宁L50041', 380, '2026-02-23 02:10:10', '2026-02-24 10:17:10', 79.00, 1, '2026-02-24 10:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(725, '湘Y14503', 94, '2026-02-28 23:17:10', '2026-03-03 22:13:10', 150.00, 1, '2026-03-03 22:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(726, '津E94820', 96, '2026-02-24 10:05:10', '2026-02-26 10:14:10', 105.00, 1, '2026-02-26 10:22:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(727, '甘Q14051', 356, '2026-02-25 20:30:10', '2026-02-26 19:35:10', 55.00, 1, '2026-02-26 19:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(728, '浙L92097', 111, '2026-02-17 00:36:10', '2026-02-18 04:08:10', 64.00, 1, '2026-02-18 04:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(729, '陕C41800', 466, '2026-03-13 23:24:10', '2026-03-14 01:12:10', 8.00, 1, '2026-03-14 01:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(730, '云P35025', 308, '2026-03-02 18:19:10', '2026-03-04 20:33:10', 111.00, 1, '2026-03-04 20:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(731, '辽V17894', 142, '2026-03-14 04:47:10', '2026-03-15 02:23:10', 50.00, 1, '2026-03-15 02:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(732, '藏J37395', 47, '2026-02-17 07:33:10', '2026-02-17 13:49:10', 23.00, 1, '2026-02-17 13:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(733, '鄂R73014', 456, '2026-03-08 06:13:10', '2026-03-10 16:34:10', 135.00, 1, '2026-03-10 16:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(734, '粤D45266', 14, '2026-03-04 10:40:10', '2026-03-06 13:56:10', 114.00, 1, '2026-03-06 13:48:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(735, '渝B67526', 227, '2026-03-11 01:36:10', '2026-03-12 16:08:10', 97.00, 1, '2026-03-12 16:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(736, '鲁F65077', 181, '2026-02-28 21:01:10', '2026-03-01 03:59:10', 23.00, 1, '2026-03-01 03:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(737, '豫G10349', 351, '2026-03-02 10:50:10', '2026-03-04 03:43:10', 100.00, 1, '2026-03-04 03:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(738, '皖R81469', 432, '2026-03-03 11:33:10', '2026-03-03 16:41:10', 20.00, 1, '2026-03-03 16:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(739, '蒙K17167', 257, '2026-03-07 13:04:10', '2026-03-09 23:58:10', 135.00, 1, '2026-03-10 00:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(740, '晋A25289', 180, '2026-03-17 07:28:10', '2026-03-18 17:48:10', 85.00, 1, '2026-03-18 17:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(741, '蒙A31914', 497, '2026-03-06 00:01:10', '2026-03-06 21:27:10', 50.00, 1, '2026-03-06 21:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(742, '琼X65082', 81, '2026-03-10 09:47:10', '2026-03-10 12:10:10', 11.00, 1, '2026-03-10 12:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(743, '桂K72950', 134, '2026-03-15 21:13:10', '2026-03-16 03:33:10', 23.00, 1, '2026-03-16 03:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(744, '甘M26442', 374, '2026-02-26 09:47:10', '2026-02-27 06:03:10', 50.00, 1, '2026-02-27 06:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(745, '辽X58279', 464, '2026-02-24 06:23:10', '2026-02-26 19:03:10', 141.00, 1, '2026-02-26 18:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(746, '川B31112', 267, '2026-02-26 18:07:10', '2026-03-01 12:19:10', 150.00, 1, '2026-03-01 12:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(747, '冀P15448', 124, '2026-03-04 12:22:10', '2026-03-07 09:08:10', 150.00, 1, '2026-03-07 09:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(748, '粤Y79291', 459, '2026-02-18 08:13:10', '2026-02-18 13:11:10', 17.00, 1, '2026-02-18 13:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(749, '黑M15810', 316, '2026-02-19 01:28:10', '2026-02-20 12:12:10', 85.00, 1, '2026-02-20 12:22:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(750, '津A25474', 16, '2026-03-16 05:23:10', '2026-03-16 12:37:10', 26.00, 1, '2026-03-16 12:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(751, '冀U66228', 200, '2026-02-28 14:33:10', '2026-03-01 10:36:10', 50.00, 1, '2026-03-01 10:30:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(752, '桂A17070', 140, '2026-03-07 08:21:10', '2026-03-07 15:21:10', 23.00, 1, '2026-03-07 15:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(753, '甘G75149', 298, '2026-02-26 05:24:10', '2026-02-27 08:29:10', 64.00, 1, '2026-02-27 08:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(754, '吉Q61239', 412, '2026-03-15 20:12:10', '2026-03-16 03:44:10', 26.00, 1, '2026-03-16 03:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(755, '豫L62022', 410, '2026-03-14 15:38:10', '2026-03-15 22:13:10', 73.00, 1, '2026-03-15 22:03:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(756, '吉Z31625', 26, '2026-03-12 02:47:10', '2026-03-12 07:17:10', 17.00, 1, '2026-03-12 07:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(757, '沪F35490', 341, '2026-03-06 15:44:10', '2026-03-09 01:58:10', 135.00, 1, '2026-03-09 01:48:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(758, '陕V06577', 336, '2026-03-05 06:45:10', '2026-03-07 00:06:10', 100.00, 1, '2026-03-07 00:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(759, '浙P64774', 214, '2026-03-11 04:40:10', '2026-03-12 06:15:10', 58.00, 1, '2026-03-12 06:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(760, '豫Q04564', 144, '2026-03-04 00:04:10', '2026-03-06 08:23:10', 129.00, 1, '2026-03-06 08:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(761, '云S51836', 137, '2026-02-28 05:13:10', '2026-03-01 10:20:10', 70.00, 1, '2026-03-01 10:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(762, '琼N59100', 457, '2026-02-28 08:29:10', '2026-03-01 07:41:10', 55.00, 1, '2026-03-01 07:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(763, '鄂Z54177', 131, '2026-02-19 14:03:10', '2026-02-22 08:10:10', 150.00, 1, '2026-02-22 08:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(764, '津P36813', 189, '2026-03-03 09:23:10', '2026-03-06 03:17:10', 150.00, 1, '2026-03-06 03:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(765, '云U59963', 12, '2026-02-25 02:59:10', '2026-02-26 17:36:10', 97.00, 1, '2026-02-26 17:37:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(766, '琼T77943', 39, '2026-03-12 05:09:10', '2026-03-14 07:55:10', 111.00, 1, '2026-03-14 07:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(767, '苏Z62207', 298, '2026-03-06 16:33:10', '2026-03-09 02:08:10', 132.00, 1, '2026-03-09 02:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(768, '浙E34811', 223, '2026-03-04 04:33:10', '2026-03-06 05:09:10', 105.00, 1, '2026-03-06 05:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(769, '津A69538', 442, '2026-03-06 19:41:10', '2026-03-06 20:03:10', 5.00, 1, '2026-03-06 19:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(770, '渝L52568', 12, '2026-03-08 18:55:10', '2026-03-10 22:48:10', 114.00, 1, '2026-03-10 22:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(771, '皖E39111', 313, '2026-03-04 14:03:10', '2026-03-06 09:36:10', 100.00, 1, '2026-03-06 09:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(772, '贵Z77293', 199, '2026-02-19 16:02:10', '2026-02-21 02:16:10', 85.00, 1, '2026-02-21 02:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(773, '辽W48384', 250, '2026-03-16 02:21:10', '2026-03-17 18:59:10', 100.00, 1, '2026-03-17 18:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(774, '京Z75184', 141, '2026-03-08 20:57:10', '2026-03-11 10:59:10', 147.00, 1, '2026-03-11 11:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(775, '辽W55481', 88, '2026-03-15 23:06:10', '2026-03-17 13:38:10', 97.00, 1, '2026-03-17 13:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(776, '云Z67288', 126, '2026-02-27 17:13:10', '2026-03-02 16:15:10', 155.00, 1, '2026-03-02 16:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(777, '鲁T57113', 256, '2026-03-15 17:53:10', '2026-03-17 20:26:10', 111.00, 1, '2026-03-17 20:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(778, '沪L84492', 423, '2026-03-17 12:43:10', '2026-03-19 01:33:10', 91.00, 1, '2026-03-19 01:26:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(779, '浙S22370', 393, '2026-03-13 19:37:10', '2026-03-16 05:32:10', 132.00, 1, '2026-03-16 05:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(780, '辽E16678', 167, '2026-03-11 08:36:10', '2026-03-13 20:35:10', 138.00, 1, '2026-03-13 20:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(781, '藏P30043', 469, '2026-03-02 17:17:10', '2026-03-05 14:04:10', 150.00, 1, '2026-03-05 14:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(782, '宁P97478', 216, '2026-03-13 00:26:10', '2026-03-14 09:24:10', 79.00, 1, '2026-03-14 09:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(783, '晋R99303', 19, '2026-02-27 06:55:10', '2026-02-28 17:09:10', 85.00, 1, '2026-02-28 17:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(784, '粤Y86639', 36, '2026-02-22 23:04:10', '2026-02-25 17:51:10', 150.00, 1, '2026-02-25 17:50:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(785, '闽G36347', 508, '2026-03-03 07:18:10', '2026-03-03 16:40:10', 32.00, 1, '2026-03-03 16:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(786, '青B54888', 435, '2026-03-04 04:11:10', '2026-03-04 15:42:10', 38.00, 1, '2026-03-04 15:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(787, '桂R98335', 369, '2026-02-21 13:31:10', '2026-02-23 11:23:10', 100.00, 1, '2026-02-23 11:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(788, '蒙Z58813', 144, '2026-02-17 15:22:10', '2026-02-19 19:06:10', 114.00, 1, '2026-02-19 19:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(789, '津X85105', 221, '2026-02-25 07:16:10', '2026-02-27 18:58:10', 138.00, 1, '2026-02-27 18:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(790, '藏E83479', 213, '2026-03-04 12:26:10', '2026-03-07 11:50:10', 155.00, 1, '2026-03-07 11:50:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(791, '鄂L07988', 371, '2026-03-16 07:25:10', '2026-03-16 12:32:10', 20.00, 1, '2026-03-16 12:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(792, '苏A00050', 270, '2026-03-12 13:18:10', '2026-03-15 00:10:10', 135.00, 1, '2026-03-15 00:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(793, '鲁Z27802', 194, '2026-03-09 01:52:10', '2026-03-11 05:35:10', 114.00, 1, '2026-03-11 05:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(794, '琼E77147', 362, '2026-02-27 07:01:10', '2026-03-01 05:57:10', 100.00, 1, '2026-03-01 05:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(795, '沪L88241', 393, '2026-03-15 13:47:10', '2026-03-17 13:09:10', 105.00, 1, '2026-03-17 13:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(796, '浙S88352', 145, '2026-02-22 09:19:10', '2026-02-24 04:30:10', 100.00, 1, '2026-02-24 04:26:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(797, '湘G57373', 365, '2026-02-25 21:47:10', '2026-02-28 16:20:10', 150.00, 1, '2026-02-28 16:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(798, '青E56421', 171, '2026-03-12 14:41:10', '2026-03-14 07:45:10', 100.00, 1, '2026-03-14 07:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(799, '苏J87950', 334, '2026-02-16 08:35:10', '2026-02-18 05:22:10', 100.00, 1, '2026-02-18 05:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(800, '贵Y42854', 101, '2026-02-19 23:40:10', '2026-02-22 21:29:10', 150.00, 1, '2026-02-22 21:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(801, '蒙M53873', 343, '2026-02-23 12:41:10', '2026-02-23 13:23:10', 5.00, 1, '2026-02-23 13:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(802, '皖B45093', 165, '2026-02-28 23:47:10', '2026-03-02 22:16:10', 100.00, 1, '2026-03-02 22:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(803, '桂P10029', 36, '2026-02-22 07:14:10', '2026-02-22 18:59:10', 38.00, 1, '2026-02-22 18:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(804, '京P48948', 367, '2026-03-09 15:39:10', '2026-03-12 14:29:10', 150.00, 1, '2026-03-12 14:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(805, '京Y00960', 489, '2026-03-06 09:49:10', '2026-03-08 14:00:10', 117.00, 1, '2026-03-08 14:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(806, '贵Y45412', 347, '2026-02-24 13:25:10', '2026-02-24 21:09:10', 26.00, 1, '2026-02-24 21:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(807, '桂R67528', 246, '2026-02-17 14:17:10', '2026-02-20 01:19:10', 138.00, 1, '2026-02-20 01:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(808, '皖Z05672', 279, '2026-03-15 01:24:10', '2026-03-16 06:45:10', 70.00, 1, '2026-03-16 06:49:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(809, '桂B57740', 13, '2026-03-15 16:25:10', '2026-03-16 14:12:10', 50.00, 1, '2026-03-16 14:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(810, '吉X80591', 11, '2026-03-04 20:58:10', '2026-03-05 19:41:10', 50.00, 1, '2026-03-05 19:37:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(811, '晋U46869', 432, '2026-03-04 05:38:10', '2026-03-07 04:01:10', 150.00, 1, '2026-03-07 03:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(812, '云F62363', 498, '2026-03-15 11:28:10', '2026-03-17 19:00:10', 126.00, 1, '2026-03-17 19:10:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(813, '蒙C69381', 420, '2026-03-16 07:25:10', '2026-03-19 00:19:10', 150.00, 1, '2026-03-19 00:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(814, '鲁Q47001', 36, '2026-03-17 03:23:10', '2026-03-18 13:38:10', 85.00, 1, '2026-03-18 13:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(815, '苏Y50125', 360, '2026-03-07 04:40:10', '2026-03-08 02:33:10', 50.00, 1, '2026-03-08 02:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(816, '蒙B43228', 505, '2026-03-02 01:41:10', '2026-03-03 21:20:10', 100.00, 1, '2026-03-03 21:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(817, '湘F33117', 303, '2026-03-01 20:59:10', '2026-03-02 22:36:10', 58.00, 1, '2026-03-02 22:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(818, '青S10664', 272, '2026-03-04 06:00:10', '2026-03-06 07:42:10', 108.00, 1, '2026-03-06 07:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(819, '津Q96623', 193, '2026-02-27 22:01:10', '2026-03-01 04:56:10', 73.00, 1, '2026-03-01 05:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(820, '晋U92820', 344, '2026-02-23 20:44:10', '2026-02-24 02:21:10', 20.00, 1, '2026-02-24 02:22:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(821, '藏H49584', 26, '2026-02-27 09:15:10', '2026-02-28 02:56:10', 50.00, 1, '2026-02-28 03:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(822, '鄂Q21777', 400, '2026-02-19 05:54:10', '2026-02-19 19:44:10', 44.00, 1, '2026-02-19 19:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(823, '渝F73219', 179, '2026-03-03 15:14:10', '2026-03-04 21:29:10', 73.00, 1, '2026-03-04 21:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(824, '宁W01942', 68, '2026-03-09 16:31:10', '2026-03-10 13:07:10', 50.00, 1, '2026-03-10 13:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(825, '渝K72235', 231, '2026-03-04 12:23:10', '2026-03-05 12:21:10', 55.00, 1, '2026-03-05 12:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(826, '冀V90417', 507, '2026-03-15 20:58:10', '2026-03-16 08:19:10', 38.00, 1, '2026-03-16 08:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(827, '蒙A20267', 106, '2026-03-03 07:00:10', '2026-03-04 08:20:10', 58.00, 1, '2026-03-04 08:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(828, '宁W81993', 25, '2026-02-23 11:18:10', '2026-02-24 16:16:10', 67.00, 1, '2026-02-24 16:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(829, '云M15496', 457, '2026-03-11 08:46:10', '2026-03-12 10:01:10', 58.00, 1, '2026-03-12 09:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(830, '湘Z10626', 166, '2026-03-08 00:14:10', '2026-03-08 14:52:10', 47.00, 1, '2026-03-08 14:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(831, '云S12274', 94, '2026-03-07 15:29:10', '2026-03-10 12:49:10', 150.00, 1, '2026-03-10 12:49:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(832, '浙S67420', 260, '2026-03-04 21:37:10', '2026-03-06 02:00:10', 67.00, 1, '2026-03-06 02:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(833, '青W83066', 65, '2026-02-27 15:23:10', '2026-02-27 21:23:10', 20.00, 1, '2026-02-27 21:24:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(834, '贵L03352', 128, '2026-02-22 08:42:10', '2026-02-24 20:18:10', 138.00, 1, '2026-02-24 20:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(835, '鲁S05207', 299, '2026-02-25 18:47:10', '2026-02-25 22:02:10', 14.00, 1, '2026-02-25 22:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(836, '吉A56852', 218, '2026-02-26 02:07:10', '2026-03-01 01:04:10', 150.00, 1, '2026-03-01 01:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(837, '苏N19017', 45, '2026-03-06 18:08:10', '2026-03-08 07:29:10', 94.00, 1, '2026-03-08 07:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(838, '宁N94304', 131, '2026-02-28 22:09:10', '2026-03-03 12:51:10', 147.00, 1, '2026-03-03 12:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(839, '桂G84090', 436, '2026-03-16 11:34:10', '2026-03-16 14:32:10', 11.00, 1, '2026-03-16 14:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(840, '甘X28595', 80, '2026-03-09 11:04:10', '2026-03-09 16:43:10', 20.00, 1, '2026-03-09 16:50:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(841, '京R89190', 473, '2026-03-11 01:16:10', '2026-03-13 20:37:10', 150.00, 1, '2026-03-13 20:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(842, '贵G78212', 306, '2026-03-04 05:13:10', '2026-03-05 21:10:10', 100.00, 1, '2026-03-05 21:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(843, '浙P04158', 112, '2026-02-21 05:22:10', '2026-02-23 01:01:10', 100.00, 1, '2026-02-23 01:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(844, '青B00208', 4, '2026-02-24 03:45:10', '2026-02-25 02:47:10', 55.00, 1, '2026-02-25 02:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(845, '蒙M02674', 248, '2026-02-17 12:41:10', '2026-02-19 05:46:10', 100.00, 1, '2026-02-19 05:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(846, '鄂Q80028', 130, '2026-03-07 03:32:10', '2026-03-07 15:45:10', 41.00, 1, '2026-03-07 15:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(847, '湘V63049', 402, '2026-03-08 02:35:10', '2026-03-09 04:46:10', 61.00, 1, '2026-03-09 04:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(848, '川G00763', 286, '2026-03-17 19:35:10', '2026-03-18 10:59:10', 50.00, 1, '2026-03-18 10:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(849, '苏C26092', 354, '2026-02-24 11:23:10', '2026-02-24 14:43:10', 14.00, 1, '2026-02-24 14:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(850, '黑G58166', 382, '2026-02-22 21:57:10', '2026-02-24 20:32:10', 100.00, 1, '2026-02-24 20:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(851, '青M73562', 265, '2026-03-13 03:54:10', '2026-03-13 22:42:10', 50.00, 1, '2026-03-13 22:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(852, '青Q59075', 165, '2026-03-05 03:26:10', '2026-03-05 11:07:10', 26.00, 1, '2026-03-05 11:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(853, '宁L57521', 348, '2026-03-04 19:40:10', '2026-03-05 23:05:10', 64.00, 1, '2026-03-05 23:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(854, '津V03892', 173, '2026-03-07 15:20:10', '2026-03-08 07:25:10', 50.00, 1, '2026-03-08 07:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(855, '赣U53621', 376, '2026-02-16 05:58:10', '2026-02-17 10:53:10', 67.00, 1, '2026-02-17 10:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(856, '川V45592', 354, '2026-03-10 10:29:10', '2026-03-11 02:12:10', 50.00, 1, '2026-03-11 02:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(857, '渝G33656', 350, '2026-03-16 09:01:10', '2026-03-17 14:12:10', 70.00, 1, '2026-03-17 14:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(858, '浙K95263', 351, '2026-03-11 14:23:10', '2026-03-12 16:54:10', 61.00, 1, '2026-03-12 17:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(859, '闽E37095', 69, '2026-02-19 04:02:10', '2026-02-19 06:53:10', 11.00, 1, '2026-02-19 06:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(860, '渝V81541', 256, '2026-02-16 17:12:10', '2026-02-17 01:01:10', 26.00, 1, '2026-02-17 01:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(861, '津S75146', 92, '2026-03-07 02:04:10', '2026-03-08 22:25:10', 100.00, 1, '2026-03-08 22:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(862, '吉T79386', 108, '2026-03-17 04:07:10', '2026-03-19 01:19:10', 100.00, 1, '2026-03-19 01:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(863, '琼L38230', 21, '2026-03-08 16:16:10', '2026-03-09 20:13:10', 64.00, 1, '2026-03-09 20:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(864, '渝B83381', 114, '2026-03-18 01:54:10', '2026-03-19 02:08:10', 55.00, 1, '2026-03-19 02:03:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(865, '苏S05091', 449, '2026-02-18 21:37:10', '2026-02-20 09:09:10', 88.00, 1, '2026-02-20 09:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(866, '湘J30395', 38, '2026-03-11 12:24:10', '2026-03-12 10:39:10', 50.00, 1, '2026-03-12 10:49:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(867, '辽F74490', 108, '2026-03-15 02:22:10', '2026-03-18 01:17:10', 150.00, 1, '2026-03-18 01:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(868, '京C31111', 455, '2026-02-24 04:23:10', '2026-02-25 08:54:10', 67.00, 1, '2026-02-25 08:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(869, '闽Q54987', 60, '2026-03-04 01:12:10', '2026-03-05 23:10:10', 100.00, 1, '2026-03-05 23:01:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(870, '闽E74310', 171, '2026-02-21 04:29:10', '2026-02-23 23:39:10', 150.00, 1, '2026-02-23 23:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(871, '桂V33333', 69, '2026-03-03 17:21:10', '2026-03-06 11:10:10', 150.00, 1, '2026-03-06 11:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(872, '冀U08942', 205, '2026-03-02 03:31:10', '2026-03-04 20:23:10', 150.00, 1, '2026-03-04 20:30:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(873, '闽T03060', 57, '2026-02-27 17:30:10', '2026-03-02 03:31:10', 135.00, 1, '2026-03-02 03:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(874, '赣U77552', 43, '2026-03-10 22:49:10', '2026-03-12 01:00:10', 61.00, 1, '2026-03-12 01:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(875, '渝R29816', 343, '2026-02-19 14:14:10', '2026-02-19 15:46:10', 8.00, 1, '2026-02-19 15:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(876, '宁B88555', 248, '2026-02-21 03:02:10', '2026-02-22 00:35:10', 50.00, 1, '2026-02-22 00:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(877, '辽Q80648', 428, '2026-03-10 04:48:10', '2026-03-13 02:13:10', 150.00, 1, '2026-03-13 02:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(878, '闽Z40003', 200, '2026-02-22 05:27:10', '2026-02-22 23:33:10', 50.00, 1, '2026-02-22 23:27:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(879, '赣J35730', 151, '2026-03-05 01:59:10', '2026-03-07 23:09:10', 150.00, 1, '2026-03-07 22:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(880, '云Z67550', 108, '2026-02-23 06:53:10', '2026-02-23 18:17:10', 38.00, 1, '2026-02-23 18:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(881, '川W70888', 399, '2026-03-10 00:21:10', '2026-03-11 14:20:10', 94.00, 1, '2026-03-11 14:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(882, '浙W87737', 290, '2026-03-17 07:09:10', '2026-03-18 03:17:10', 50.00, 1, '2026-03-18 03:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(883, '宁Z08130', 339, '2026-03-05 06:01:10', '2026-03-07 04:12:10', 100.00, 1, '2026-03-07 04:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(884, '津K77531', 450, '2026-03-06 22:19:10', '2026-03-08 14:40:10', 100.00, 1, '2026-03-08 14:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(885, '冀M73597', 154, '2026-03-10 15:09:10', '2026-03-13 10:05:10', 150.00, 1, '2026-03-13 09:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(886, '蒙K60218', 374, '2026-02-17 22:56:10', '2026-02-18 01:03:10', 11.00, 1, '2026-02-18 01:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(887, '琼R93472', 70, '2026-03-13 06:08:10', '2026-03-15 00:44:10', 100.00, 1, '2026-03-15 00:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(888, '津W64427', 96, '2026-02-19 19:13:10', '2026-02-21 09:03:10', 94.00, 1, '2026-02-21 09:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(889, '津F57264', 378, '2026-02-28 03:16:10', '2026-03-01 08:25:10', 70.00, 1, '2026-03-01 08:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(890, '晋S12754', 136, '2026-02-16 08:11:10', '2026-02-18 17:48:10', 132.00, 1, '2026-02-18 17:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(891, '川K60840', 456, '2026-02-23 13:42:10', '2026-02-24 21:16:10', 76.00, 1, '2026-02-24 21:10:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(892, '蒙P36685', 431, '2026-02-23 04:09:10', '2026-02-25 13:49:10', 132.00, 1, '2026-02-25 13:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(893, '琼V90781', 161, '2026-03-01 06:29:10', '2026-03-01 10:19:10', 14.00, 1, '2026-03-01 10:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(894, '宁A28119', 365, '2026-03-12 04:29:10', '2026-03-14 11:46:10', 126.00, 1, '2026-03-14 11:40:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(895, '豫J97163', 331, '2026-02-20 00:46:10', '2026-02-22 01:18:10', 105.00, 1, '2026-02-22 01:12:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(896, '京E89722', 321, '2026-02-20 14:20:10', '2026-02-21 03:55:10', 44.00, 1, '2026-02-21 03:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(897, '津Q46987', 141, '2026-03-17 12:00:10', '2026-03-18 13:00:10', 55.00, 1, '2026-03-18 12:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(898, '贵U86298', 370, '2026-03-14 23:33:10', '2026-03-16 17:55:10', 100.00, 1, '2026-03-16 17:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(899, '皖A43642', 478, '2026-02-19 09:14:10', '2026-02-21 22:27:10', 144.00, 1, '2026-02-21 22:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(900, '京M35727', 487, '2026-02-22 07:12:10', '2026-02-24 04:23:10', 100.00, 1, '2026-02-24 04:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(901, '闽D85362', 238, '2026-03-17 18:02:10', '2026-03-19 01:54:10', 76.00, 1, '2026-03-19 02:03:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(902, '冀R62791', 219, '2026-02-17 12:40:10', '2026-02-19 09:15:10', 100.00, 1, '2026-02-19 09:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(903, '贵Z85999', 303, '2026-03-14 09:42:10', '2026-03-16 00:05:10', 97.00, 1, '2026-03-16 00:01:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(904, '陕N11828', 124, '2026-03-11 17:26:10', '2026-03-12 17:18:10', 55.00, 1, '2026-03-12 17:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(905, '鲁B41544', 475, '2026-02-17 06:07:10', '2026-02-17 15:47:10', 32.00, 1, '2026-02-17 15:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(906, '吉K20836', 209, '2026-02-21 23:38:10', '2026-02-24 08:13:10', 129.00, 1, '2026-02-24 08:17:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(907, '吉K93474', 129, '2026-02-17 08:43:10', '2026-02-20 03:05:10', 150.00, 1, '2026-02-20 02:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(908, '黑Q94278', 505, '2026-02-17 02:40:10', '2026-02-20 00:28:10', 150.00, 1, '2026-02-20 00:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(909, '冀A27688', 123, '2026-03-15 20:37:10', '2026-03-16 13:35:10', 50.00, 1, '2026-03-16 13:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(910, '豫R52361', 26, '2026-03-04 13:01:10', '2026-03-06 12:24:10', 105.00, 1, '2026-03-06 12:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(911, '琼F53681', 500, '2026-02-21 12:15:10', '2026-02-24 07:51:10', 150.00, 1, '2026-02-24 07:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(912, '皖V71091', 187, '2026-03-18 00:54:10', '2026-03-19 02:02:10', 58.00, 1, '2026-03-19 02:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(913, '吉P97551', 287, '2026-02-21 23:22:10', '2026-02-22 19:39:10', 50.00, 1, '2026-02-22 19:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(914, '鲁G11472', 374, '2026-03-15 23:42:10', '2026-03-16 15:36:10', 50.00, 1, '2026-03-16 15:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(915, '鲁H15889', 425, '2026-02-28 07:11:10', '2026-02-28 17:40:10', 35.00, 1, '2026-02-28 17:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(916, '陕Y22836', 237, '2026-02-28 21:59:10', '2026-03-02 16:08:10', 100.00, 1, '2026-03-02 16:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(917, '桂Z42224', 253, '2026-02-19 04:58:10', '2026-02-21 02:32:10', 100.00, 1, '2026-02-21 02:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(918, '吉N71004', 150, '2026-02-19 21:54:10', '2026-02-20 08:09:10', 35.00, 1, '2026-02-20 08:16:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(919, '闽W48260', 352, '2026-03-09 11:43:10', '2026-03-11 23:35:10', 138.00, 1, '2026-03-11 23:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(920, '吉D53746', 408, '2026-03-12 08:24:10', '2026-03-14 18:57:10', 135.00, 1, '2026-03-14 19:04:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(921, '津K89340', 287, '2026-02-18 12:37:10', '2026-02-20 02:47:10', 97.00, 1, '2026-02-20 02:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(922, '苏S16046', 385, '2026-02-18 15:35:10', '2026-02-19 15:44:10', 55.00, 1, '2026-02-19 15:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(923, '琼V45466', 252, '2026-02-17 10:47:10', '2026-02-20 00:33:10', 144.00, 1, '2026-02-20 00:38:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(924, '苏T42484', 129, '2026-03-14 18:09:10', '2026-03-16 20:27:10', 111.00, 1, '2026-03-16 20:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(925, '鲁E35641', 486, '2026-02-18 05:11:10', '2026-02-18 17:05:10', 38.00, 1, '2026-02-18 17:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(926, '贵R37931', 418, '2026-03-01 06:41:10', '2026-03-03 04:02:10', 100.00, 1, '2026-03-03 04:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(927, '津T76209', 45, '2026-03-16 12:09:10', '2026-03-17 06:21:10', 50.00, 1, '2026-03-17 06:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(928, '晋F27711', 267, '2026-02-20 17:31:10', '2026-02-23 10:38:10', 150.00, 1, '2026-02-23 10:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(929, '浙E38938', 210, '2026-03-12 02:12:10', '2026-03-14 09:48:10', 126.00, 1, '2026-03-14 09:52:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(930, '琼H01229', 391, '2026-02-27 00:21:10', '2026-02-27 12:01:10', 38.00, 1, '2026-02-27 11:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(931, '苏S79466', 154, '2026-02-19 01:37:10', '2026-02-21 14:04:10', 141.00, 1, '2026-02-21 14:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(932, '桂Q31401', 145, '2026-03-16 13:24:10', '2026-03-17 14:41:10', 58.00, 1, '2026-03-17 14:51:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(933, '辽V14400', 41, '2026-03-03 19:55:10', '2026-03-05 00:02:10', 67.00, 1, '2026-03-04 23:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(934, '藏K78988', 446, '2026-02-17 02:15:10', '2026-02-17 03:15:10', 5.00, 1, '2026-02-17 03:21:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(935, '青F06141', 317, '2026-03-02 04:45:10', '2026-03-03 21:44:10', 100.00, 1, '2026-03-03 21:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(936, '京S28181', 496, '2026-03-17 12:44:10', '2026-03-19 02:07:10', 94.00, 1, '2026-03-19 02:06:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(937, '赣M80635', 275, '2026-03-09 11:28:10', '2026-03-11 13:18:10', 108.00, 1, '2026-03-11 13:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(938, '粤N19348', 337, '2026-03-13 19:43:10', '2026-03-16 14:00:10', 150.00, 1, '2026-03-16 14:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(939, '陕W82876', 13, '2026-02-22 18:11:10', '2026-02-24 21:32:10', 114.00, 1, '2026-02-24 21:37:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(940, '辽V57580', 443, '2026-03-10 12:57:10', '2026-03-12 19:29:10', 123.00, 1, '2026-03-12 19:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(941, '贵N25956', 85, '2026-03-10 10:09:10', '2026-03-11 18:19:10', 79.00, 1, '2026-03-11 18:18:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(942, '贵V24432', 26, '2026-02-21 01:12:10', '2026-02-21 17:56:10', 50.00, 1, '2026-02-21 17:50:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(943, '青P79464', 285, '2026-03-05 10:57:10', '2026-03-06 04:15:10', 50.00, 1, '2026-03-06 04:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(944, '闽Q83699', 127, '2026-03-16 17:01:10', '2026-03-18 22:29:10', 120.00, 1, '2026-03-18 22:36:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(945, '湘A03925', 83, '2026-02-24 01:22:10', '2026-02-24 16:57:10', 50.00, 1, '2026-02-24 17:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(946, '渝H06699', 504, '2026-03-08 16:31:10', '2026-03-08 23:06:10', 23.00, 1, '2026-03-08 23:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(947, '云B91595', 155, '2026-03-14 12:14:10', '2026-03-14 19:32:10', 26.00, 1, '2026-03-14 19:35:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(948, '桂K74234', 130, '2026-03-12 09:55:10', '2026-03-15 00:27:10', 147.00, 1, '2026-03-15 00:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(949, '苏K05128', 191, '2026-03-04 08:42:10', '2026-03-05 16:39:10', 76.00, 1, '2026-03-05 16:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(950, '渝H14841', 425, '2026-02-18 16:10:10', '2026-02-19 07:59:10', 50.00, 1, '2026-02-19 07:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(951, '川C51524', 24, '2026-02-18 13:48:10', '2026-02-18 15:57:10', 11.00, 1, '2026-02-18 16:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(952, '沪A61287', 220, '2026-02-19 07:33:10', '2026-02-21 02:39:10', 100.00, 1, '2026-02-21 02:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(953, '湘B75375', 407, '2026-02-25 02:07:10', '2026-02-27 08:51:10', 123.00, 1, '2026-02-27 08:41:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(954, '宁M00426', 337, '2026-03-07 01:21:10', '2026-03-08 13:02:10', 88.00, 1, '2026-03-08 13:09:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(955, '赣D69549', 396, '2026-02-19 12:13:10', '2026-02-21 22:19:10', 135.00, 1, '2026-02-21 22:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(956, '青W00046', 83, '2026-02-19 04:52:10', '2026-02-19 12:01:10', 26.00, 1, '2026-02-19 12:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(957, '青J38401', 31, '2026-03-04 02:25:10', '2026-03-06 20:56:10', 150.00, 1, '2026-03-06 20:56:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(958, '皖Y03463', 113, '2026-03-03 12:09:10', '2026-03-04 16:49:10', 67.00, 1, '2026-03-04 16:59:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(959, '鲁U44592', 244, '2026-02-16 19:31:10', '2026-02-16 20:58:10', 8.00, 1, '2026-02-16 21:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(960, '京E70863', 43, '2026-02-21 03:59:10', '2026-02-22 22:33:10', 100.00, 1, '2026-02-22 22:29:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(961, '蒙E55433', 246, '2026-03-13 00:15:10', '2026-03-13 15:50:10', 50.00, 1, '2026-03-13 15:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(962, '京V32985', 298, '2026-03-04 00:48:10', '2026-03-05 21:23:10', 100.00, 1, '2026-03-05 21:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(963, '赣L68115', 305, '2026-03-06 16:58:10', '2026-03-07 13:10:10', 50.00, 1, '2026-03-07 13:14:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(964, '桂L39161', 361, '2026-03-06 02:43:10', '2026-03-07 15:22:10', 91.00, 1, '2026-03-07 15:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(965, '冀X06429', 294, '2026-03-11 05:11:10', '2026-03-11 15:37:10', 35.00, 1, '2026-03-11 15:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(966, '宁U45041', 251, '2026-03-04 15:57:10', '2026-03-04 16:56:10', 5.00, 1, '2026-03-04 17:05:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(967, '赣D55688', 449, '2026-02-17 21:30:10', '2026-02-20 00:50:10', 114.00, 1, '2026-02-20 00:53:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(968, '豫F43791', 152, '2026-02-21 05:07:10', '2026-02-22 00:47:10', 50.00, 1, '2026-02-22 00:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(969, '辽B26008', 402, '2026-03-07 01:24:10', '2026-03-07 06:41:10', 20.00, 1, '2026-03-07 06:49:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(970, '湘B92260', 41, '2026-02-23 08:04:10', '2026-02-25 11:59:10', 114.00, 1, '2026-02-25 12:00:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(971, '粤N21103', 180, '2026-03-16 22:03:10', '2026-03-19 01:45:10', 114.00, 1, '2026-03-19 01:37:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(972, '冀Q39291', 339, '2026-03-15 00:47:10', '2026-03-17 05:32:10', 117.00, 1, '2026-03-17 05:23:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(973, '桂Q11141', 59, '2026-02-18 09:03:10', '2026-02-20 23:16:10', 147.00, 1, '2026-02-20 23:22:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(974, '陕X16085', 19, '2026-02-20 22:05:10', '2026-02-21 00:34:10', 11.00, 1, '2026-02-21 00:33:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(975, '鄂U22598', 314, '2026-02-18 11:42:10', '2026-02-20 02:32:10', 97.00, 1, '2026-02-20 02:25:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(976, '鄂L11637', 456, '2026-03-06 09:54:10', '2026-03-07 22:54:10', 91.00, 1, '2026-03-07 22:46:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(977, '青M03770', 29, '2026-03-17 21:57:10', '2026-03-19 01:24:10', 64.00, 1, '2026-03-19 01:20:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(978, '渝K40269', 442, '2026-02-24 21:19:10', '2026-02-25 08:15:10', 35.00, 1, '2026-02-25 08:07:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(979, '冀M77244', 432, '2026-03-08 10:33:10', '2026-03-09 11:51:10', 58.00, 1, '2026-03-09 11:58:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(980, '吉E10696', 113, '2026-03-08 05:11:10', '2026-03-08 21:56:10', 50.00, 1, '2026-03-08 22:02:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(981, '湘F99957', 48, '2026-03-14 10:26:10', '2026-03-15 23:17:10', 91.00, 1, '2026-03-15 23:15:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(982, '豫B85653', 40, '2026-02-27 05:03:10', '2026-02-27 12:32:10', 26.00, 1, '2026-02-27 12:31:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(983, '云D38071', 345, '2026-03-12 13:55:10', '2026-03-13 19:44:10', 70.00, 1, '2026-03-13 19:34:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(984, '浙C07815', 58, '2026-03-17 14:23:10', '2026-03-18 17:44:10', 64.00, 1, '2026-03-18 17:45:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(985, '渝V12251', 128, '2026-03-03 05:48:10', '2026-03-04 18:43:10', 91.00, 1, '2026-03-04 18:39:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(986, '桂F32841', 405, '2026-02-26 07:38:10', '2026-02-27 22:51:10', 100.00, 1, '2026-02-27 22:42:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(987, '晋P09288', 133, '2026-03-11 20:03:10', '2026-03-13 01:01:10', 67.00, 1, '2026-03-13 00:55:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(988, '蒙U50633', 268, '2026-03-12 10:31:10', '2026-03-12 15:45:10', 20.00, 1, '2026-03-12 15:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(989, '苏F36432', 38, '2026-03-07 17:49:10', '2026-03-08 12:47:10', 50.00, 1, '2026-03-08 12:47:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(990, '赣Y69728', 6, '2026-02-21 00:00:10', '2026-02-23 22:04:10', 150.00, 1, '2026-02-23 22:11:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(991, '黑V25841', 289, '2026-03-02 03:15:10', '2026-03-02 12:27:10', 32.00, 1, '2026-03-02 12:28:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(992, '津S49549', 388, '2026-03-10 04:14:10', '2026-03-11 17:56:10', 94.00, 1, '2026-03-11 18:01:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(993, '闽W70912', 10, '2026-03-11 04:51:10', '2026-03-11 09:22:10', 17.00, 1, '2026-03-11 09:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(994, '沪Q54998', 358, '2026-02-17 23:51:10', '2026-02-20 12:18:10', 141.00, 1, '2026-02-20 12:13:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(995, '闽A41118', 285, '2026-02-23 10:55:10', '2026-02-25 15:33:10', 117.00, 1, '2026-02-25 15:32:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(996, '浙H97454', 227, '2026-03-13 03:54:10', '2026-03-13 18:44:10', 47.00, 1, '2026-03-13 18:44:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(997, '赣U36771', 308, '2026-03-11 16:58:10', '2026-03-11 22:27:10', 20.00, 1, '2026-03-11 22:19:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(998, '赣X06824', 243, '2026-03-11 14:55:10', '2026-03-12 11:54:10', 50.00, 1, '2026-03-12 11:54:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(999, '川A26172', 71, '2026-03-15 17:21:10', '2026-03-16 05:36:10', 41.00, 1, '2026-03-16 05:43:10');
INSERT INTO `parking_record` (`record_id`, `plate_number`, `space_id`, `entry_time`, `exit_time`, `fee_amount`, `pay_status`, `pay_time`) VALUES
(1000, '贵A84157', 90, '2026-02-22 16:40:10', '2026-02-25 16:04:10', 155.00, 1, '2026-02-25 15:59:10');

SET FOREIGN_KEY_CHECKS = 1;

-- ==================== 数据统计 ====================
-- 总记录数: 1000条
--   - 未支付(停车中): 100条
--   - 已支付(已完成): 约900条（其中免费约10%）
-- ====================

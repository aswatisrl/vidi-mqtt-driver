CREATE DATABASE IF NOT EXISTS nbiot_server;
GRANT ALL PRIVILEGES ON nbiot_server.* TO 'nbiot_user'@'%';
USE nbiot_server;
CREATE TABLE IF NOT EXISTS `addresses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `serial` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE IF NOT EXISTS `brokers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url` varchar(255) DEFAULT NULL,
  `qos` int DEFAULT NULL,
  `user` varchar(45) DEFAULT NULL,
  `password` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE IF NOT EXISTS `device_types` (
  `device_type` varchar(45) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`device_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `device_types` SELECT * FROM (VALUES ROW ('14','VIDI Open Close'), ROW ('16','VIDI Flow'), ROW ('17','VIDI Pressure'), ROW ('18','VIDI Temp'), ROW ('23','VIDI Level'), ROW ('24','VIDI Positioner'), ROW ('28','VIDI PRV')) src WHERE NOT EXISTS (SELECT NULL FROM device_types);
CREATE TABLE IF NOT EXISTS `devices` (
  `serial` varchar(8) NOT NULL,
  `insert_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `join_date` datetime DEFAULT NULL,
  `used_dev_nonces` text,
  `imei` varchar(32) DEFAULT NULL,
  `root_key` varchar(32) DEFAULT NULL,
  `last_seen` datetime DEFAULT NULL,
  `broker_url` varchar(45) DEFAULT NULL,
  `broker_qos` int DEFAULT NULL,
  `broker_user` varchar(45) DEFAULT NULL,
  `broker_password` varchar(45) DEFAULT NULL,
  `hw_type` varchar(45) DEFAULT NULL,
  `device_type` varchar(45) DEFAULT NULL,
  `rid` varchar(32) DEFAULT NULL,
  `master_secret` varchar(32) DEFAULT NULL,
  `lowest_recipient_seq` int DEFAULT NULL,
  `recipient_replay_window` int DEFAULT NULL,
  `recipient_replay_size` int DEFAULT NULL,
  `sender_seq` int DEFAULT NULL,
  `firmware` varchar(45) DEFAULT NULL,
  `last_fota` datetime DEFAULT NULL,
  `last_fota_status` int DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`serial`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE IF NOT EXISTS `downlink_queue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_id` varchar(45) DEFAULT NULL,
  `serial` varchar(45) DEFAULT NULL,
  `generation_date` datetime DEFAULT NULL,
  `insert_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `callback` text,
  `cancel_date` datetime DEFAULT NULL,
  `dispatch_date` datetime DEFAULT NULL,
  `ack_date` datetime DEFAULT NULL,
  `command` text,
  `host` varchar(45) DEFAULT NULL,
  `token` varchar(16) DEFAULT NULL,
  `response_payload` text,
  `response_code` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE IF NOT EXISTS `hardware_types` (
  `hw_type` varchar(45) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`hw_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `hardware_types` SELECT * FROM (VALUES ROW ('TR2_0','VIDI Transmitter ver 2024, based on Nordic nRF9160')) src WHERE NOT EXISTS (SELECT NULL FROM hardware_types);
CREATE TABLE IF NOT EXISTS `settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `value` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `settings` SELECT * FROM (VALUES ROW (1,'use_local_broker','1'), ROW (2,'mqtt_broker','mqtt://127.0.0.1'), ROW (3,'mqtt_username','vidimqtt'), ROW (4,'mqtt_password','12345678'), ROW (5,'mqtt_qos','1')) src WHERE NOT EXISTS (SELECT NULL FROM settings);
CREATE TABLE IF NOT EXISTS `uplink_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT CURRENT_TIMESTAMP,
  `serial` varchar(8) DEFAULT NULL,
  `data` text,
  `rid` varchar(8) DEFAULT NULL,
  `host` varchar(16) DEFAULT NULL,
  `lowest_recipient_seq` int DEFAULT NULL,
  `recipient_replay_window` int DEFAULT NULL,
  `message_type` varchar(45) DEFAULT NULL,
  `resource` varchar(45) DEFAULT NULL,
  `query` varchar(64) DEFAULT NULL,
  `block2_num` int DEFAULT NULL,
  `token` varchar(64) DEFAULT NULL,
  `rsrp` int DEFAULT NULL,
  `battery` int DEFAULT NULL,
  `firmware` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(45) NOT NULL,
  `password` varchar(255) NOT NULL,
  `can_manage_users` int DEFAULT '0',
  `can_read_devices` int DEFAULT '0',
  `can_write_devices` int DEFAULT '0',
  `can_send_downlink` int DEFAULT '0',
  `can_manage_integrations` int DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `users` SELECT * FROM (VALUES ROW (1,'admin','$2a$10$TThFK9C/7sFwiPhg1w3eTeicjz32li8NlcAj081Ci/gll82wYvL0u',1,1,1,1,1), ROW (2,'coap_gateway_user','$2a$10$NfohmjdVCPmlqxx.netW7OwacWzY4cHSqYwT38TPwC.KIOsONCfa.',0,1,1,0,0)) src WHERE NOT EXISTS (SELECT NULL FROM users);

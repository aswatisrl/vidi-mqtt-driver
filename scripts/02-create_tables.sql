USE `coap_server`;

CREATE TABLE IF NOT EXISTS `addresses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `serial` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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

CREATE TABLE IF NOT EXISTS `devices` (
  `serial` varchar(8) NOT NULL,
  `insert_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `join_date` datetime DEFAULT NULL,
  `used_dev_nonces` text,
  `imei` varchar(32) DEFAULT NULL,
  `root_key` varchar(32) DEFAULT NULL,
  `last_seen` datetime DEFAULT NULL,
  `hw_type` varchar(45) DEFAULT NULL,
  `device_type` varchar(45) DEFAULT NULL,
  `rid` varchar(32) DEFAULT NULL,
  `master_secret` varchar(32) DEFAULT NULL,
  `lowest_recipient_seq` int DEFAULT NULL,
  `recipient_replay_window` int DEFAULT NULL,
  `recipient_replay_size` int DEFAULT NULL,
  `sender_seq` int DEFAULT NULL,
  `network` int DEFAULT NULL,
  `rsrp` int DEFAULT NULL,
  `snr` int DEFAULT NULL,
  `band` int DEFAULT NULL,
  `operator` varchar(255) DEFAULT NULL,
  `firmware` varchar(45) DEFAULT NULL,
  `tx_interval` int DEFAULT NULL,
  `last_fota` datetime DEFAULT NULL,
  `last_fota_status` int DEFAULT NULL,
  `fota_progress` int DEFAULT NULL,
  `notes` text,
  `timezone` varchar(45) DEFAULT NULL,
  `calendar` text,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `hardware_types` (
  `hw_type` varchar(45) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`hw_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `value` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
  `password` varchar(255),
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `can_manage_users` int DEFAULT '0',
  `can_read_devices` int DEFAULT '0',
  `can_write_devices` int DEFAULT '0',
  `can_send_downlink` int DEFAULT '0',
  `can_manage_integrations` int DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `api_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` text,
  `expiration` datetime DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_users_token_idx` (`user_id`),
  CONSTRAINT `fk_users_token` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

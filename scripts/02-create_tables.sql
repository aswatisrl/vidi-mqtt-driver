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

CREATE TABLE IF NOT EXISTS `applications` (
  `id` int NOT NULL,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
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
  `battery_level` int DEFAULT NULL,
  `operator` varchar(255) DEFAULT NULL,
  `firmware` varchar(45) DEFAULT NULL,
  `tx_interval` int DEFAULT NULL,
  `last_fota` datetime DEFAULT NULL,
  `last_fota_status` int DEFAULT NULL,
  `fota_progress` int DEFAULT NULL,
  `notes` text,
  `timezone` varchar(45) DEFAULT NULL,
  `calendar` text,
  `app_id` int DEFAULT NULL,
  PRIMARY KEY (`serial`),
  KEY `fk_devices_application_idx` (`app_id`),
  CONSTRAINT `fk_devices_application` FOREIGN KEY (`app_id`) REFERENCES `applications` (`id`) ON DELETE SET NULL
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
  PRIMARY KEY (`id`),
  KEY `idx_downlink_queue_serial` (`serial`)
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
  `is_admin` int DEFAULT '0',
  `can_read_devices` int DEFAULT '0',
  `can_write_devices` int DEFAULT '0',
  `can_send_downlink` int DEFAULT '0',
  `app_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_UNIQUE` (`username`),
  KEY `fk_users_application_idx` (`app_id`),
  CONSTRAINT `fk_users_application` FOREIGN KEY (`app_id`) REFERENCES `applications` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `api_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` text,
  `expiration` datetime DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_users_token_idx` (`user_id`),
  CONSTRAINT `fk_users_token` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `firmware_versions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `author` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `version` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `requirement` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `upload_date` datetime DEFAULT NULL,
  `checksum` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `serials` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `data` mediumblob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mobile_devices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `device_uuid` varchar(36) NOT NULL,
  `app_name` varchar(255) DEFAULT NULL,
  `app_version` varchar(45) DEFAULT NULL,
  `device_name` varchar(255) DEFAULT NULL,
  `last_access` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `device_uuid_UNIQUE` (`device_uuid`),
  KEY `fk_mobile_devices_user_idx` (`user_id`),
  CONSTRAINT `fk_mobile_devices_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `registration_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `target_user_id` int NOT NULL,
  `created_by` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime NOT NULL,
  `max_uses` int DEFAULT NULL,
  `used_count` int NOT NULL DEFAULT 0,
  `revoked` tinyint(1) NOT NULL DEFAULT 0,
  `label` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_regtoken_target_idx` (`target_user_id`),
  KEY `fk_regtoken_creator_idx` (`created_by`),
  CONSTRAINT `fk_regtoken_target` FOREIGN KEY (`target_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_regtoken_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `firmware_hwtype_compatibility` (
  `hardware_type` varchar(16) NOT NULL,
  `firmware_version` int NOT NULL,
  PRIMARY KEY (`hardware_type`,`firmware_version`),
  KEY `fk_firmware_version_idx` (`firmware_version`),
  CONSTRAINT `fk_firmware_version` FOREIGN KEY (`firmware_version`) REFERENCES `firmware_versions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_hardware_types` FOREIGN KEY (`hardware_type`) REFERENCES `hardware_types` (`hw_type`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

USE `coap_server`;

INSERT INTO `device_types` VALUES ('14','VIDI Open Close'),('16','VIDI Flow'),('17','VIDI Pressure'),('18','VIDI Temp'),('23','VIDI Level'),('24','VIDI Positioner'),('28','VIDI PRV'),('29','VIDI Positioner with ext. antenna'),('31','VIDI Leak');

INSERT INTO `hardware_types` VALUES ('PRV_0','VIDI PRV Controller'),('TR2_0','VIDI Transmitter 2.0 ver 2024, based on Nordic nRF9160'),('TR2_5','VIDI Transmitter 2.0 ver 2024, based on Nordic nRF9160');

INSERT INTO `settings` VALUES (1,'use_local_broker','1'),(2,'mqtt_broker','192.168.1.1'),(3,'mqtt_username','vidimqtt'),(4,'mqtt_password','vidimqtt'),(5,'mqtt_qos','1'),(6,'mqtt_topic_uplink','application/COAP/device/{{serial}}/uplink');

INSERT INTO `users` VALUES (1,'admin','$2a$10$3mQ2F9owX3VEeOaiweyNpuNELcC7OaERlhIS4QUsk0UZlCXFww5tq',1,1,1,1,1);

# VIDI MQTT Driver

The VIDI MQTT Driver is a network bridge that enables communication and data exchange between the VIDI Devices and applications.
The driver takes care of low-level binary communication (CoAP) between the VIDI Devices and the server, allowing the third-party application to interact with the field devices using high-level protocols and formats such as MQTT and JSON.
The driver makes the low-level communication transparent to the third-party application, hence enabling a fast development of the software connector.

### CoAP
CoAP (Constrained Application Protocol) is a lightweight, RESTful communication protocol specifically designed for constrained devices and networks in the Internet of Things (IoT). It enables simple, efficient, and resource-friendly communication between devices with limited processing power, memory, and battery life, operating over lossy and low-bandwidth networks such as NB-IoT or LTE-M. CoAP typically runs over UDP (User Datagram Protocol) instead of TCP, minimizing resource usage while providing faster communication.

### MQTT
MQTT (Message Queuing Telemetry Transport) is a lightweight, publish-subscribe-based messaging protocol. The publish-subscribe pattern enables to decouple components and to scale efficiently.

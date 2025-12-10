# VIDI MQTT Driver

The VIDI MQTT Driver is a network bridge that enables communication between the VIDI Devices and 3rd party applications.
The driver manages the low-level binary communication (CoAP) between VIDI Devices and the server, enabling third-party applications to interact with the devices using high-level protocols and formats such as MQTT and JSON.
By abstracting the low-level communication, the driver makes it transparent to third-party applications, simplifying and accelerating connector development.

### CoAP
CoAP (Constrained Application Protocol) is a lightweight, RESTful communication protocol specifically designed for constrained devices and networks in the Internet of Things (IoT). It enables simple, efficient, and resource-friendly communication between devices with limited processing power, memory, and battery life, operating over lossy and low-bandwidth networks such as NB-IoT or LTE-M. CoAP typically runs over UDP (User Datagram Protocol) instead of TCP, minimizing resource usage and reducing communication latency.

### MQTT
MQTT (Message Queuing Telemetry Transport) is a lightweight, publish-subscribe-based messaging protocol. The publish-subscribe pattern enables components to be decoupled and scale efficiently.

### Getting started
- [Installation](docs/installation.md)
- [First launch](docs/first-launch.md)
- [MQTT Integration](docs/mqtt-integration.md)

### Device families
- [VIDI Transmitter](docs/vidi-transmitter.md)

# VIDI Transmitter MQTT integration

The MQTT integration publishes all the device data as JSON over MQTT. To receive data from your device, you need to subscribe to its MQTT topic.

## Topic
The default uplink topic is: `application/COAP/device/{{serial}}/uplink`

The placeholder *{{serial}}* is replaced with the serial number (e.g. *A0000001*) of the device. For example, the data produced by the device *A0000001* will be available on the topic `application/COAP/device/A0000001/uplink`

As provided by the MQTT protocol, you can subscribe to all topics using a wildcard: 
`application/COAP/device/+/uplink`

The default uplink topic can be modified:
- Access the driver web interface
- Navigate to Integrations → MQTT
- Edit the field *Uplink topic*
- Press *Save*
- It is not necessary to restart the driver, the modification will take effect within 10 minutes


## Using an external broker
The driver comes with a built-in MQTT broker (VerneMQ) which runs as a Docker container. By default, the driver publishes the device data on the built-in broker.

Optionally, it is possible to configure the driver to publish on a pre-existing MQTT broker, 
To configure the external broker:
- Access the driver web interface
- Navigate to Integrations → MQTT
- Select *Use external broker*
- Fill the requires fields (*Broker url*, *Username*, *Password*, *QoS*). The parameters are necessary for the driver to connect to the external broker.
- Press *Save*
- It is not necessary to restart the driver, the modification will take effect within 10 minutes

## MQTT payload
The MQTT payload contains device data formatted as JSON.

Example:
```json 
{
    "battery_voltage": 3599,
    "battery_level": 91,
    "rsrp": -110,
    "snr": 5,
    "internal_temperature": 24,
    "measures": [
        {
            "timestamp": "2025-04-22T09:30:00+00:00",
            "pressure": 5746
        },
        { 
            "timestamp": "2025-04-22T09:25:00+00:00",
            "pressure": 5749
        },
        {
             "timestamp": "2025-04-22T09:20:00+00:00",
             "pressure": 5740
        }
    ]
}
```

The JSON can contain the following fields:
- Read-only fields: they are written by the device and can only be read by the server
- Read/Write fields: they can be read and written both by the device and by the server
- Commands: they are used by the server to issue a command to the device. To issue a command, the variable must be written with the number 1 (or a different number if the command supports parameterization)


### Read-only fields
| Name	| Type | Description | 	Example  | Notes | 
| ----- | ---- | ----------- | --------  | ----- |
| fw_version | string | Version of the firmware, in SemVer format | "1.0.2-beta.01" | [^1] |
| hw_version | string | Version of the hardware | "TR2_1" | [^1] |
| measures | array | Array of measures, see documentation below | | | 
| alarms | array | Array of alarms, see documentation below | | | 
| battery_voltage | number | Battery voltage, in millivolts | 3699 | |
| battery_charge | number | Battery state of charge, in percentage | 100 | | 
| rsrp | number | RSRP (Reference Signals Received Power) of the previous transmission, in dBm	| -94 | | 
| snr | number | SNR (Signal to Noise Ratio) of the previous transmission, in dB | 10 | |
| internal_temperature | number | Internal device temperature, in °C. Please note that this cannot be used as a measurement of environmental air temperature since it is normally higher due to the device components heating | 22 | |
| operator | string | Mobile operator the device is currently connected to | "Vodafone Italy" | [^1] | 
| band | number | Frequency band identifier | 20 | [^1] | 
| reset_alarm | number | Indication that the device has rebooted. The value is set to 1 at the first transmission after the reboot. It is reset to 0 at the second transmission after the reboot, and never sent again until next reboot | 1 | |
| reset_count | number | Reboot counter | 10 | [^2] |
| conn_count | number | Connection counter | 5 | [^2] |
| tx_count | number | Transmission counter | 100 | [^2] |
| sampling_count | number | Sampling counter | 1000 | [^2] |
| uptime | number | Number of seconds the device is up and running, after boot | 3600 | [^2] |
| failed_conn_count | number | Failed connection counter | 10 | [^2] |
| failed_tx_count | number | Failed transmission counter | 10 | [^2] |
| fota_count | number | FOTA attempts counter | 10 | [^2] |
| cell_id | number | Id of the cell the device is currently connected to | 14129519 | [^2] |
| tracking_area | number | Tracking Area the device is currently connected to | 37092 | [^2] |
| last_fota_status | string | Outcome of the last FOTA attempt | "Firmware updated successfully" | [^3] |
| last_fota | timestamp | Date and time of the last FOTA attempt, in ISO 8901 format | "2025-04-17T06:41:57Z" | [^3] |
 

### Measures
The "measures" array contains an element for each sampling. Each element of the array is identified by the property "timestamp" which indicates the date and time of the sampling. The timestamp is printed in ISO 8901 format. In addition to the timestamp, each element may include other properties depending on the type of device:

#### VIDI Flow measure fields
- *volume*: indicates the flow rate reading, in l/s x 100
- *flowrate*: indicates the volume count, in liters
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Status |  
  | - | - |   
  | 1 | Tamper | 

#### VIDI Pressure measure fields
- *pressure*: indicates the pressure reading, in mbar
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Status |  
  | - | - |   
  | 1 | Tamper | 
  | 2 | Sensor fault |
  | 3 | Value too low | 
  | 4 | Value too high |

#### VIDI Temperature measure fields
- *temperature*: indicates the temperature reading, in Celsius degrees x 100
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Status |  
  | - | - |   
  | 1 | Tamper | 
  | 2 | Measure out of scale |
  | 3 | Sensor fault | 

#### VIDI Level measure fields
- *level*: indicates the level reading, in mm
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Status |  
  | - | - |   
  | 1 | Tamper | 
  | 2 | Sensor absent |
  | 3 | Target too close |
  | 4 | Target too far | 

#### VIDI Positioner measure fields
- *position*: indicates the number of quarter of rounds
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Status |  
  | - | - |   
  | 1 | Not yet calibrated | 
  | 2 | During calibration |
  | 3 | Calibration error |

#### VIDI Open Close measure fields
- *position*: indicates the position of the valve:  
  | Value | Status |  
  | - | - |  
  | 0 | Close position |  
  | 1 | Intermediate position |  
  | 2 | Open position |
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Status |  
  | - | - |   
  | 1 | Sensor fault, the contacts are activated at the same time | 

### Alarms
The "alarms" array contains an element for each alarm event. Each element of the array is identified by the property "timestamp" which indicates the date and time of the event. An event could be either the device entering to alarm condition or the device returning to normal condition.

Example: 
```json
{
    "alarms": [
        {
            "timestamp": "2025-03-05T18:55:00+00:00",
            "temperature": 199,
            "low_alarm": 1,
        }
    ]
}
```
 
 TODO
Applies only to VIDI Pressure, VIDI Flow, VIDI Temperature, VIDI Level.


  TODO
* The low and high alarm condition are only generated on the main measure for each device: temperature for VIDI Temp, pressure for VIDI Pressure, level for VIDI Level, flow rate for VIDI Flow.

If the alarm condition persists, the device does not send any information about the alarm. The server must keep the state of the alarm condition. If the device reboots, the state of the alarm is lost. For this reason, the server must cancel any alarm condition after each reset (presence of the property “reset_alarm”: 1 in the payload). If the alarm condition is still present, the device will send it again. 
The timestamp is printed in ISO 8901 format. In addition to the timestamp, each element may include other properties depending on the type of device:
 
pressure	Applies only to VIDI Pressure. Indicates the pressure reading, in mbar
temperature	Applies only to VIDI Temperature. Indicates the temperature reading, in Celsius degrees x 100
flowrate	Applies only to VIDI Flow. Indicates the flow rate reading, in cl/s
volume	Applies only to VIDI Flow. Indicates the volume count, in liters
level	Applies only to VIDI Level. Indicates the level reading, in mm
low_alarm	If set to 1, the device has entered the low alarm condition (*); if set to 0, the device has returned from low alarm condition. The property is present only in the two cases described above
high_alarm	If set to 1, the device has entered the high alarm condition (*); if set to 0, the device has returned from high alarm condition. The property is present only in the two cases described above
tamper_alarm
 	If set to 1, the device has entered the tamper alarm condition (*); if set to 0, the device has returned from tamper alarm condition. The property is present only in the two cases described above
sensor_fault
 	Applies only to VIDI Pressure, VIDI Temperature, VIDI Level. If set to 1, the device has entered the sensor fault condition (*); if set to 0, the device has returned from sensor fault condition. The property is present only in the two cases described above
 
 
### Read/Write fields
| Name	| Type | Description | 	Example  | Notes | 
| ----- | ---- | ----------- | --------  | ----- |
| tx_interval | number | Transmission interval, in seconds | 3600 | [^4] |
| sampling_interval | number | Sampling interval, in seconds | 300 | [^4] |
| full_scale | number | Applies to:<br> - VIDI Pressure: indicates the full scale in mBar of the pressure sensor (default 16000)<br> - VIDI Level: indicates the full scale in mm of the level sensor (default 5000)<br> - VIDI Positioner: indicates the number of quarter of rounds equivalent to the full-open position (the value is variable and it is given by the calibration) | 16000 |
| pulse_weight | number | Applies only to VIDI Flow. It indicates the weight for each pulse generated by the flow meter, expressed in cubic meter per pulse | 0.01 | |
| installation_height | number | Applies only to VIDI Level. It indicates the distance in mm from the level sensor to the floor of the tank or the ground | 3000 | |
| tx_delay | number | Applies only to VIDI Positioner and VIDI Open Close. It indicates the delay in seconds between the detection of the change of state and the transmission | | 
| closing_direction | number | Applies only to VIDI Positioner. It indicates the valve closing direction:<br> 0: clockwise<br>1: anti-clockwise	| 0 | | 
| hi_curr_count | number | Applies only to VIDI Flow. If set to 1, the device sets the pullup to 47 Kohm on the input pin. It must be set when (usually on electronic flow meters) the input impedance is not negligible and could prevent the correct pulse detection | | |	 
| low_alarm_immediate_tx | number | If set to 1, the device transmits immediately after the detection of a low alarm | 0 | |
| high_alarm_immediate_tx | number | If set to 1, the device transmits immediately after the detection of a high alarm | 0 | |
| dig_alarm_immediate_tx | number | If set to 1, the device transmits immediately after the detection of a digital alarm (e.g. tamper or sensor fault) | 0 | |
| low_alarm_threshold | number | Low alarm threshold, in engineering unit | 2 | |
| high_alarm_threshold | number | High alarm threshold, in engineering unit | 10 | |
| hysteresis | number | Value of hysteresis value, in engineering unit | 0.1 | | 
| low_alarm_delay | number | Value of the alarm delay for the low threshold, in minutes. If set to 0, alarm is triggered immediately | 0 | |
| high_alarm_delay | number | Value of the alarm delay for the high threshold, in minutes. If set to 0, alarm is triggered immediately | 0 | |
| dig_alarm_delay | number | Value of the alarm delay for the digital alarms, in minutes. If set to 0, alarm is triggered immediately | 0 | |
| alarm_tx_time | number | If set to a value greater than 0, the device will execute a transmission after each sampling for the given amount of minutes after the detection of the alarm | 0 | |
| remote_ip | string | IP Address of the CoAP server | "192.168.150.34" | [^4] [^5]  |
| remote_port | number | UDP port the CoAP server is listening for incoming messages from the device | 5683 | [^4] [^5]  |
| net_mode | number | Mobile Network<br> 1: LTE-M<br>2: NB-IoT | 2 | [^4] [^5] |
| apn | string | Access Point Name | "AVK.TMA.IOT" | [^4] [^5] |
| forced_operator | string | If set, the device will attempt to connect to the indicated operator. If set to "OFF" the device will automatically connect to the available operator | "22210" | [^4] [^5] |
| active_time | string | Active Time: the period after data activity during which the device stays in a semi-active state. During Active Time, the device can receive incoming data without re-establishing a full connection, improving latency. Once Active Time expires, the device moves to a lower power / idle state to save battery | "00010000" | [^4] [^5] |
| tau | string | Tracking Area Update | ""00111110" | [^4] [^5] |
| edrx | number | Extended Discontinuous Reception. It is a battery-saving mechanism allowing devices to sleep longer while still being reachable by the network. If set to "OFF", eDRX is disabled | "OFF" | [^4] [^5] |
| rai | number | Release Assistance Indication. It tells the network whether it can release the radio connection faster. It helps reducing signaling and save battery when the device doesn’t need to stay connected | 0 | [^4] [^5] |
| name | string | Name of the device | "Pres-A0000001" | |
| latitude | number | Installation latitude | 43.700531 | |
| longitude | number | Installation longitude | 10.903978 | |
 

### Commands
| Name	| Type | Description | 	Example  | Notes | 
| ----- | ---- | ----------- | --------  | ----- |
| reset | number | Command to ask the device to reboot, by setting the parameter to 1 | `{"reset": 1}` | | 
| fota | number | Command to ask the device to start the FOTA procedure, by setting the parameter to 1 | `{"fota": 1}` | | 
| get_config | number | Command to ask the device to send its full configuration, by setting the parameter to 1 | `{"get_config": 1}` | |
| test_mode | number | Command to ask the device to go in test mode, for the given number of transmissions. During the test mode, the device transmits after each sampling. After the transmissions are elapsed, the device goes back to working in standard mode | `{"test_mode": 5}` | |
| debug_mode | number | Command to ask the device to go in debug mode, for the given number of transmissions. During the debug mode, the device behaves normally but adds in the transmission payload debug information (e.g. uptime and statistics). After the transmissions are elapsed, the device goes back to working in standard mode | `{"debug_mode": 10}` | |
| battery_replace | number | Command to tell the device that the battery has been replaced, by setting the parameter to 1. As a result, the device will reset the battery charge to 100% |	`{"battery_replace": 1}` | |

## Sending commands
There are two ways for sending commands or configurations to the devices: via web interface or programmatically, using the Rest APIs.
> Please note that, given the nature of the devices, the dispatch of the command is not immediate. The commands are put in a queue by the driver and they will be sent to the device inside the response to the next transmission.

# Using web interface
TODO

# Using API
TODO



## Notes about transmission scheme
When a device is activated, the security context is not established yet. For this reason, at first the device connects to the network (NB-IoT or LTE-M) and executes the JOIN to the CoAP server. 

In order for the JOIN to complete, the device must be already enrolled in the CoAP driver (see Enroll devices part in the drive installation manual). If the JOIN fails, the device will retry indefinitely at the same interval defined for transmission. 

When the JOIN is completed, the security context is established so the device can start sending data. 
At first, the device sends data for three times with a 5 minutes interval (*). These 3 transmission are useful in the field to evaluate that the installation is successful. After this, the device will start transmitting at the defined interval (tx_interval, default 60 minutes). 
* the interval is not exactly 5 minutes as the device must synchronize with sampling interval.

 
[^1]: Sent only in the first transmission after reboot or in response to the "get_config" command	
[^2]: Sent only when the debug mode is active
[^3]: Sent only in the first transmission after a FOTA attempt (either successful or unsuccessful)
[^4]: The configuration triggers the reboot of the device
[^5]: The configuration of this parameter may result in an invalid configuration that breaks connectivity. If misconfigured, the device can become permanently unreachable. Proceed only if you are certain of what you are doing.

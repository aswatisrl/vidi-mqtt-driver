# VIDI Transmitter
Before reading this document, please make sure you have gone through the [MQTT Integration](mqtt-integration.md), as it provides the essential context and background needed to understand the MQTT payload and management of downlinks

## MQTT payload
The MQTT payload `"data"` property contains device data formatted as JSON. This includes status information, measures and alarms.

Example:
```json 
{
    ...
    "data": {
        "battery_voltage": 3599,
        "battery_level": 91,
        "rsrp": -110,
        "snr": 5,
        "internal_temperature": 24,
        "measures": [
            ...
        ],
        "alarms": [
            ...
        ]
    }
}
```

The `data` properties of the JSON can contain the following fields:
- Read-only fields: they are written by the device and can only be read by the server
- Read/Write fields: they can be read and written both by the device and by the server
- Commands: they are used by the server to issue a command to the device. To issue a command, the property must be written with the parameter `1` (or a different number if the command supports parameterization)


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
| internal_temperature | number | Internal device temperature, in °C. Please note that this cannot be used as an accurate measurement of environmental air temperature since it is normally higher due to the device components heating | 22 | |
| operator | string | Mobile operator the device is currently connected to | "Vodafone Italy" | [^1] | 
| band | number | Frequency band identifier | 20 | [^1] | 
| reset_alarm | number | Indication that the device has rebooted. The value is set to 1 at the first transmission after the reboot. It resets to 0 at the second transmission after the reboot, and it is not sent again until next reboot | 1 | |
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
| last_fota_status | string | Outcome of the last FOTA attempt, see [FOTA states](#fota-states) | "Firmware updated successfully" | [^3] |
| last_fota | timestamp | Date and time of the last FOTA attempt, in ISO 8601 format | "2025-04-17T06:41:57Z" | [^3] |

### Measures
The `measures` array contains an element for each sampling. 

Example:
```json 
{
    ...
    "data": {
        ...
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
}
```


Each element of the array is identified by the property `timestamp` which indicates the date and time of the sampling. The timestamp is printed in ISO 8601 format. In addition to the timestamp, each element may include other properties depending on the type of device:

#### *VIDI Flow* measure fields
- *flowrate*: indicates the flow rate reading, in l/s x 100
- *volume*: indicates the volume count, in liters
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Meaning |  
  | - | - |   
  | 1 | Tamper | 

#### *VIDI Pressure* measure fields
- *pressure*: indicates the pressure reading, in mbar
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Meaning |  
  | - | - |   
  | 1 | Tamper | 
  | 2 | Sensor fault |
  | 3 | Value too low | 
  | 4 | Value too high |

#### *VIDI Temperature* measure fields
- *temperature*: indicates the temperature reading, in Celsius degrees x 100
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Meaning |  
  | - | - |   
  | 1 | Tamper | 
  | 2 | Measure out of scale |
  | 3 | Sensor fault | 

#### *VIDI Level* measure fields
- *level*: indicates the level reading, in mm
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Meaning |  
  | - | - |   
  | 1 | Tamper | 
  | 2 | Sensor absent |
  | 3 | Target too close |
  | 4 | Target too far | 

#### VIDI Positioner measure fields
- *position*: indicates the number of quarter of rounds
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Meaning |  
  | - | - |   
  | 1 | Not yet calibrated | 
  | 2 | During calibration |
  | 3 | Calibration error |

#### VIDI Open Close measure fields
- *position*: indicates the position of the valve:  
  | Value | Meaning |  
  | - | - |  
  | 0 | Close position |  
  | 1 | Intermediate position |  
  | 2 | Open position |
- *error*: this field is present only if the measure is affected by an error, indicating that it must be discarded. It can assume the following values:
  | Value | Meaning |  
  | - | - |   
  | 1 | Sensor fault, the two contacts are activated at the same time | 

  
### Alarms
The `alarms` array contains an element for each alarm event. An event can be either the device entering to alarm condition or the device returning to normal condition.  
If the device doesn't have any alarms to be transmitted, the `alarms` field will not be present in the JSON. Furthermore, the `alarm` array can only be present in *VIDI Pressure*, *VIDI Flow*, *VIDI Temperature*, *VIDI Level*.  

Example: 
```json
{
    ...
    "data": {
        ...   
        "alarms": [
            {
                "timestamp": "2025-03-05T18:55:00+00:00",
                "temperature": 199,
                "low_alarm": 1
            }
        ]
    }
}
```

Each element of the array contains the field `timestamp`, that indicates the date and time of the event, in ISO 8601 format. In addition to the timestamp, each element may include other properties depending on the type of device:
| Field | Description |
| - | - |
| low_alarm	| If set to 1, the device has entered the low alarm condition, meaning that the main measure of the device has registered a value lower that the `low_alarm_threshold`, taking into account the parameters `low_alarm_delay`, if configured; if set to 0, the device has returned from low alarm condition, taking into account the parameter `hysteresis`. When the field `low_alarm` is present, the value that has generated the condition will also be indicated, see fields `flowrate`, `pressure`, `level`, `temperature` below |
| high_alarm | If set to 1, the device has entered the high alarm condition, meaning that the main measure of the device has registered a value higher that the `high_alarm_threshold`, taking into account the parameters `high_alarm_delay`, if configured; if set to 0, the device has returned from low alarm condition, taking into account the parameter `hysteresis`. When the field `high_alarm` is present, the value that has generated the condition will also be indicated, see fields `flowrate`, `pressure`, `level`, `temperature` below |
| flowrate | (Applies only to *VIDI Flow*) the value that has generated the *low_alarm* or *high_alarm* event |
| pressure | (Applies only to *VIDI Pressure*) the value that has generated the *low_alarm* or *high_alarm* event |
| level | (Applies only to *VIDI Level*) the value that has generated the *low_alarm* or *high_alarm* event |
| temperature | (Applies only to *VIDI Temperature*) the value that has generated the *low_alarm* or *high_alarm* event |
| tamper_alarm | Applies only to *VIDI Flow*, *VIDI Pressure*, *VIDI Level*, *VIDI Temperature*. If set to 1, the device has entered the tamper alarm condition; if set to 0, the device has returned from tamper alarm condition | 
| sensor_fault | Applies only to *VIDI Pressure*, *VIDI Level*, *VIDI Temperature*. If set to 1, the device has entered the sensor fault condition; if set to 0, the device has returned from sensor fault condition |
 

⚠️ The alarm information is only transmitted when the alarm is triggered and when it returns. During the alarm condition, the device does not repeat the information. The server must keep the state of the alarm condition. If the device reboots, the state of the alarm is lost. For this reason, the server must clear any alarm conditions after each reset (presence of the property `"reset_alarm": 1` in the payload). If the alarm condition is still present, the device will send it again. 
 
 
### Read/Write fields
| Name	| Type | Description | 	Example  | Notes | 
| ----- | ---- | ----------- | --------  | ----- |
| tx_interval | number | Transmission interval, in seconds | 3600 | [^4] |
| sampling_interval | number | Sampling interval, in seconds | 300 | [^4] |
| full_scale | number | Applies to:<br> - *VIDI Pressure*: indicates the full scale in mBar of the pressure sensor (default 16000)<br> - *VIDI Level*: indicates the full scale in mm of the level sensor (default 5000)<br> - VIDI Positioner: indicates the number of quarter of rounds equivalent to the full-open position (the value is variable and it is given by the calibration) | 16000 |
| pulse_weight | number | Applies only to *VIDI Flow*. It indicates the weight for each pulse generated by the flow meter, expressed in cubic meter per pulse | 0.01 | |
| installation_height | number | Applies only to *VIDI Level*. It indicates the distance in mm from the level sensor to the floor of the tank or the ground | 3000 | |
| tx_delay | number | Applies only to VIDI Positioner and VIDI Open Close. It indicates the delay in seconds between the detection of the change of state and the transmission | | 
| closing_direction | number | Applies only to VIDI Positioner. It indicates the valve closing direction:<br> 0: clockwise<br>1: anti-clockwise	| 0 | | 
| hi_curr_count | number | Applies only to *VIDI Flow*. If set to 1, the device sets the pullup to 47 Kohm on the input pin. It must be set when (usually on electronic flow meters) the input impedance is not negligible and could prevent the correct pulse detection | | |	 
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
| reply_delay | number | Delay the device applies before transmitting the acknowledgment uplink, after the reception of a command | 1000 | [^5] |
| apn | string | Access Point Name | "AVK.TMA.IOT" | [^4] [^5] |
| forced_operator | string | If set, the device will attempt to connect to the indicated operator. If set to "OFF" the device will automatically connect to the available operator | "22210" | [^4] [^5] |
| active_time | string | The period after data activity during which the device stays in a semi-active state. During *Active Time*, the device can receive incoming data without re-establishing a full connection, improving latency. Once *Active Time* expires, the device moves to a lower power / idle state to save battery | "00010000" | [^4] [^5] |
| tau | string | Tracking Area Update time | "00111110" | [^4] [^5] |
| edrx | string | Extended Discontinuous Reception. It is a battery-saving mechanism allowing devices to sleep longer while still being reachable by the network. If set to "OFF", eDRX is disabled | "OFF" | [^4] [^5] |
| rai | number | Release Assistance Indication. With RAI, the eNB releases the connection to allow the device to go into the idle state when it receives the indication from the upper layers that there are no further uplink/downlink packets | 1 | [^5] |
| name | string | Name of the device | "Pres-A0000001" | |
| latitude | number | Installation latitude | 43.700531 | |
| longitude | number | Installation longitude | 10.903978 | |
 

### Commands
| Name	| Type | Description | 	Example  | Notes | 
| ----- | ---- | ----------- | --------  | ----- |
| reset | number | Command to ask the device to reboot, by setting the parameter to 1 | `{"reset": 1}` | | 
| fota | number | Command to ask the device to start the FOTA procedure, by setting the parameter to 1 | `{"fota": 1}` | | 
| get_config | number | Command to ask the device to transmit its full configuration, by setting the parameter to 1 | `{"get_config": 1}` | |
| test_mode | number | Command to ask the device to go in test mode, for the given number of transmissions. During the test mode, the device transmits after each sampling. After the transmissions are elapsed, the device goes back to working in standard mode | `{"test_mode": 5}` | |
| debug_mode | number | Command to ask the device to go in debug mode, for the given number of transmissions. During the debug mode, the device behaves normally but adds in the transmission payload debug information (e.g., uptime and statistics). After the transmissions are elapsed, the device goes back to working in standard mode | `{"debug_mode": 10}` | |
| battery_replace | number | Command to tell the device that the battery has been replaced, by setting the parameter to 1. As a result, the device will reset the battery charge to 100% |	`{"battery_replace": 1}` | |


#### FOTA states
| Value | Meaning |  
| - | - |   
| 0 | Upgrading |
| 1 | Firmware updated successfully |
| 2 | Already to latest version |
| 3 | Not enough flash memory |
| 4 | Connection lost during download |
| 5 | Integrity check failure |
| 6 | Unsupported package type |
| 7 | New firmware unable to boot |
| 8 | Firmware update failed |

[^1]: Sent only in the first transmission after reboot or in response to the `get_config` command	
[^2]: Sent only when the debug mode is active
[^3]: Sent only in the first transmission after a FOTA attempt (either successful or unsuccessful)
[^4]: The configuration triggers the reboot of the device
[^5]: Misconfiguring this parameter may break connectivity and render the device permanently unreachable. Proceed only if you fully understand the implications
[^6]: The low and high alarm condition are only generated on the main measure for each device: temperature for VIDI Temp, pressure for *VIDI Pressure*, level for *VIDI Level*, flow rate for *VIDI Flow*

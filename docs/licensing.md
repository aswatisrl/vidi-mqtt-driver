# Licensing
This software requires a valid license in order to function. Without a license, the application will not operate.

## License validation
This software uses an online license server to make sure your license is valid. Once per day, the application contacts the license server. If the license is valid, the server issues a token that remains valid for 7 days.
Make sure your system has internet access and that no firewall rules are blocking outbound HTTPS traffic (port 443) to the license server.

The following information is transmitted daily to the license server:
- The license key
- The version of the running containers
- A list of the serial numbers of the devices currently enrolled in the Driver. The list is necessary to prevent unauthorized use of the software

No other information — such as user data, device payloads, or metadata (e.g., notes, firmware versions, operators, keys) — is transmitted to the license server.

## What happens if the license server can't be reached
At startup, if the application cannot reach the license server, it will stop immediately. 
During the daily validation of the license, if the software cannot contact the license server (for example, due to network issues), it will keep using the last valid token. 
If the problem persists and the license cannot be validated before the token expires (7 days) the software will stop working.

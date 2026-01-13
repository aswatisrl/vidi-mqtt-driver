# First launch

⚠️ This section assumes you have successfully completed the [Installation](docs/installation.md) steps

Launch the driver with the command
```console
docker compose up -d
```
The option `-d` (detach) allows to run the containers in background

## Monitoring
You can access the logs in two ways:
1. Accessing the logs for each Docker container
```console
docker logs <container_name> -f
```
The option `-f` allows to follow log output as it grows in real time
Example:
```console
docker logs api-server -f
```
2. For api-server and coap-gateway containers, the logs are also accessible from the host on the folders
- /opt/vidi-mqtt-driver/logs-apiserver
- /opt/vidi-mqtt-driver/logs-gateway

Logs are rotated daily and retained for 14 days.

## Initialization
Once the service is started, do the following operations:

### Web interface
Access the driver's web configuration interface by opening a web browser and nvaigating to: `http://<HOST>` (for example `http://192.168.1.1`)

The default login credentials are:
- Username: *admin*
- Password: *admin*

**⚠️ Important:** Upon first login, change the password immediately. Click the profile icon at the bottom of the left sidebar and set a new password.

### CoAP Gateway configuration
The CoAP Gateway status is displayed on the upper-right corner of the page. At this point, the gateway will be shown as **inactive**, as it has not been configured yet.   
The CoAP Gateway requires an API Token to communicate with the API Server.  

1. Open the left side menu and select **API Tokens**.
2. Click **Generate new token**.
3. Fill in the fields as follows:
   - **Token name:** A descriptive name to identify the token later, e.g., `coap-gateway`.
   - **Expiration:** Choose according to your security policies.  
     If you do **not** choose *No expiration*, you will need to regenerate the token before it expires.
   - **Permissions:** Enable *Can read devices* and *Can write devices*. Leave all other permissions unchecked.
4. Click **Generate token** and **store the token securely**, as it cannot be viewed again later.

### Updating the Configuration
Edit the `compose.yaml` file and locate the *coap-gateway* service section.  
Edit the line `API_TOKEN=<API_TOKEN>` in the *coap-gateway* section replacing `<API_TOKEN>` with the token you just created.
Finally, restart the container to apply the changes:
```console
docker compose up -d coap-gateway
```

### Password recovery
If you changed the *admin* password but you lost it, you can force the API Server to reset it by opening the file `compose.yaml` with a text editor and change the parameter `RESET_ADMIN_PASSWORD=false` to `RESET_ADMIN_PASSWORD=true` in the *api-server* service.

Finally, restart the container with the commands
```console
docker compose up -d api-server
```

Now you can access the web interface `http://<host>` with `admin/admin` credentials and change the password as indicated above.

Once the password is reset, remember to open the `compose.yaml` file again, revert the configuration to `RESET_ADMIN_PASSWORD=false` and restart the container with the same command. Otherwise, the *admin* password will be reset to the default at each restart.

### Enrolling devices
Once launched, the CoAP server is listening on port 5683 but it will not accept any connection as no security context is present.
You need to enroll the devices by providing for each unit:
- Serial (e.g., A0000001)
- 128-bit Root Key (example b25f88887b44dbdc4b8952b22636cb65)

You should have received this set of information when purchasing the device. If not, please contact your sales representative.

You can also add a textual note for each device to simplify asset management.

Access the *Devices* page on the web interface menu. You can add one device manually (*Add new device* button) or import multiple devices by providing a CSV file (*Add devices from file* button).

Alternatively, devices can be enrolled via the REST APIs. See the *API Docs* page on the web interface menu for instructions.

## Backup

The database stores the OSCORE context for each device. The context is the local set of information elements necessary to carry out the cryptographic operations. In case of a data loss, devices will no longer be able to communicate with the CoAP server. The device will receive a `401 Unauthorized` status, and it will be forced to start a new join procedure on the device.

For this reason, we strongly advise configuring an automatic daily backup of the database. 
Open the crontab with the command:
```console
crontab -e
```

Append the following line in order to execute a copy (dump) of the database every night at 2 am:
```
0 2  * * *    cd /opt/vidi-mqtt-driver && ./dump_db.sh
```
A database dump will be saved in the `backup_db` folder. The script deletes the backup files which are older than 28 days at the end of the execution.

**Note:** If the `backup_db` folder does not exist, it will be created in the same directory of the script

## Security Best Practices

To ensure secure operation of the VIDI MQTT Driver in production environments, follow these recommendations:

### Password & Credentials Management

- Change all default passwords immediately after installation (e.g., `admin/admin`, `coap_gateway_user/changeme`)
- Use strong passwords containing uppercase, lowercase, numbers, and symbols
- Regularly rotate credentials and avoid reusing passwords across services
- Consider using [Docker secrets](https://docs.docker.com/engine/swarm/secrets/) or environment injection from a secure secret manager

### MQTT

- Enable MQTTS and disable anonymous access when exposing the broker publicly
- Create separate MQTT users for each service (API Server, CoAP Gateway, application clients)

### HTTP

- Use a VPN or a reverse proxy with HTTPS for secure remote access to the web interface.

### Network Exposure

Restrict firewall rules so that only the required ports are exposed:
 - Web interface (port 80/tcp or 443/tcp)
 - MQTT (port 1883/tcp or 8883/tcp) if required by external applications
 - CoAP (port 5683/udp) and NTP (port 123/udp) only if field devices are not on a private network

### System Updates

- Keep Docker images up to date by regularly pulling from the repository.
- Monitor for updates to the VIDI MQTT Driver GitHub repository.
- Apply OS and security patches on the host system to reduce vulnerability exposure.

# VIDI MQTT Driver

The VIDI MQTT Driver is a network bridge that enables communication between the VIDI Devices and 3rd party applications.
The driver takes care of low-level binary communication (CoAP) between the VIDI Devices and the server, allowing the 3rd party application to interact with the field devices using high-level protocols and formats such as MQTT and JSON.
The driver makes the low-level communication transparent to the 3rd party application, hence enabling a fast development of the software connector.

### CoAP
CoAP (Constrained Application Protocol) is a lightweight, RESTful communication protocol specifically designed for constrained devices and networks in the Internet of Things (IoT). It enables simple, efficient, and resource-friendly communication between devices with limited processing power, memory, and battery life, operating over lossy and low-bandwidth networks such as NB-IoT or LTE-M. CoAP typically runs over UDP (User Datagram Protocol) instead of TCP, minimizing resource usage while providing faster communication.

### MQTT
MQTT (Message Queuing Telemetry Transport) is a lightweight, publish-subscribe-based messaging protocol. The publish-subscribe pattern enables to decouple components and to scale efficiently.

# Installation

This section describes how to install the VIDI MQTT Driver with Docker Compose. Although Docker is a cross-platform containerization software, the present guide shows the installation commands for a Linux host, as this is the most common scenario.

### Docker Compose
Docker Compose makes it possible to configure and run multiple Docker containers at once using the `compose.yml` file.
The driver is composed by the following containers:

- **mysql**: MySQL database server, used to store device configurations and frame logs
- **vernemq**: MQTT broker, used for async communicaton between services
- **api-server**: API Server, the engine of the driver
- **coap-gateway**: CoAP gateway based on the Open Source project [Californium](https://eclipse.dev/californium)
- **coap-monitor**: The service that manages low-priority tasks, such as writing logs and cleaning records
- **frontend**: Web frontend for configuration of the driver and API documentation
- **redis**: in-memory key–value database, cache and message broker
- **ntp**: NTP server used to provide synchronization service to the field devices

### Requirements
Before you continue, please make sure that you have Docker and Compose installed. Please refer to https://docs.docker.com/get-docker/ for documentation on how to install Docker.
The minumum hardware specifications mainly depends on the number of devices and the sampling/transmission rates. A minimum recommendation is:
- 2 vCPU
- 4 GB RAM
- 20 GB storage

### Login to the container repository
The container are hosted on the GitHub repository. By issuing the `docker compose up` command, Docker will try to pull the images from the GitHub repository. Since the repository is not publicly accessible, you need a valid username and password to pull the containers. You should have received the credentials *GH_USERNAME* and *GH_PASSWORD* by your sales representative.

Open a console on the host machine (the one that will run the containers) and run the command: 

```console
docker login --username <GH_USERNAME> --password <GH_PASSWORD> ghcr.io
```

You should see the following output:

`Login Succeeded`

### Compose repository
We provide a repository with the default Docker Compose configuration. This repository can be found at https://github.com/aswatisrl/vidi-mqtt-driver

To clone this repository, open a console on the host (the machine that will run the driver) and execute the following command:

```console
cd /opt
git clone https://github.com/aswatisrl/vidi-mqtt-driver
```

### Installation package
As the result of the `git clone` command, you should now have in the folder /opt/vidi-mqtt-driver the following:

- **scripts**: it contains the MySQL database initialization scripts
- **compose.yaml**: Docker Compose file
- **dump_db.sh**: script to execute a daily backup copy of the database (optional - see Backup section)

When the service is started for the first time, Docker will create the following empty folders that will be mounted on the containers:
- **db_data**: will contain the data of the MySQL database
- **logs-apiserver**: will contain the logs of the API Server
- **logs-gateway**: will contain the logs of the CoAP Gateway

### Preliminary configuration
Before launching Docker Compose for the first time, it is necessary to edit the configuration. Open the file `compose.yaml` with a text editor and edit the following:

#### Service `mysql`
- Replace `<MYSQL_ROOT_PASSWORD>` with a strong password. Please use lowercase and uppercase letters, numbers and special characters. Avoid the `=` character as it is not allowed for passing environment variables.

#### Service `vernemq`
According to the default configuration, the VerneMQ MQTT broker is started with the `ALLOW_ANONYMOUS` flag, meaning that the broker is accepting connections from anonymous clients. It's possible to disable the anonymous login by editing the line to `DOCKER_VERNEMQ_ALLOW_ANONYMOUS=off`
In this case, it's necessary to add users and passwords as environment variables by adding to the compose file: ` - DOCKER_VERNEMQ_USER_<USERNAME>='password'` where `<USERNAME>` is the username you want to use.<br>This can be done as many times as necessary to create the users you want. The usernames will always be created in lowercase.
Be aware that you will need at least one user for the API Server, one user for CoAP Gateway and one user for your application.
Example:
```
vernemq:
  ...
  environment:
    ...
    - DOCKER_VERNEMQ_USER_apiserveruser='12345678'
    - DOCKER_VERNEMQ_USER_gatewayuser='12345678'
    - DOCKER_VERNEMQ_USER_appuser='12345678'
```
Caveat: passing the passwords as environment variables you cannot have a `=` character in your password.

#### Service `api-server`
- Replace `<MYSQL_ROOT_PASSWORD>` with the password you specified in the service *mysql*
- Replace `<JWT_SECRET_KEY>` with a utf-8 encoded string. We suggest at least 32 characters. The key is used by the API Server to sign and verify the JSON Web Tokens.
- In case you disabled the anonymous login in the service *vernemq*, populate the `MQTT_USERNAME` and `MQTT_PASSWORD` environmental variables with the username and password you specified above.

#### Service `coap-monitor`
- Replace `<MYSQL_ROOT_PASSWORD>` with the password you specified in the service *mysql*
- Edit the `DATA_RETENTION` environmental parameter with desidered retention for the uplink records in the database. The retention is expressed in days.

#### Service `coap-gateway`
In case you disabled the anonymous login in the service *vernemq*, populate the `MQTT_USERNAME` and `MQTT_PASSWORD` environmental variables with the username and password you specified above. 

# Launch the VIDI MQTT Driver
Launch the driver with the command
```console
docker compose up -d
```
The option `-d` (detach) allows to run the containers in background

### Monitoring
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

Logs are rotated every day, with a 14-days retention period

# Initialization
Once the service is started, do the following operations:

### Frontend
Log in to the web configuration page of the driver by opening a web browser and entering the url `http://<HOST>`, for example `http://192.168.1.1`

The default credentials are:
- Username: *admin*
- Password: *admin*

**Important:** At first access, change the password by clicking on the profile icon at the botton of the left sidebar

The CoAP Gateway needs also to consume the APIs exposed by API Server. For this purpose, a default user is created in the API Server during the initialization:
- Username: *coap_gateway_user*
- Password: *changeme*

Log out from `admin` user and log is as `coap_gateway_user`

Once logged, change the password by clicking on the profile icon at the botton of the left sidebar

At this point you need to open the file `compose.yaml` and edit the line `API_PASSWORD=changeme` in the *coap-gateway* section, replacing the default password with the new one that you just created.
Restart the containers using the commands
```console
docker compose down && docker compose up -d
```

### Password recovery
In case you changed the *admin* password but you lost the password, you can force the API Server to reset by opening the file `compose.yaml` with a text editor and change the parameter `RESET_ADMIN_PASSWORD=false` to `RESET_ADMIN_PASSWORD=true` in the *api-server* service.

Finally, restart the containers using the commands
```console
docker compose down && docker compose up -d
```

Now you can access the frontend `http://<host>` with `admin/admin` credentials and change the password as indicated above.

Once the password is reset, do not forget to open again the file`compose.yaml`, revert the configuration to `RESET_ADMIN_PASSWORD=false` and restart the container with the same command. Otherwise the *admin* password will be reset to the default at each restart

### Adding devices
Once launched, the CoAP server is listening on port 5683 but it will not accept any connection as no security context is present.
You need to add the devices by providing for each unit:
- Serial (example A0000001)
- 128-bit Root Key (example b25f88887b44dbdc4b8952b22636cb65)

You should have received this set of information when purchasing the device. If not, please contact your sales representative.

It's also possible to specify a textual note for each device, for easy asset management

Access the *Devices* page on the Frontend. You can add one device manually (*Add new device* button) or import multiple devices by providing a CSV file (*Add devices from file* button) 

# Backup

The database stores the OSCORE context for each device. The context is the local set of information elements necessary to carry out the cryptographic operations. In case of a data loss, it won't be possible for the devices to communicate anymore with the CoAP server, and it will be necessary to trigger a new join procedure on the device by swithing the radio OFF and ON locally on the field.

For this reason we strongly advice to configure the automatic daily backup of the database. 
Open the crontab with the command:
```console
crontab -e
```

Append the following line in order to execute a copy (dump) of the database every night at 2 am:
```
0 2  * * *    cd /opt/vidi-mqtt-driver && ./dump_db.sh
```
A dump of the database will be generated and copied into the folder `backup_db`, with a retention policy of 28 days

**Note:** If the `backup_db` folder does not exist, it will be created in the same directory of the script

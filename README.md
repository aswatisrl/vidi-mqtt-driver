# VIDI MQTT Driver

The VIDI MQTT Driver is a network bridge that enables communication and data exchange between the VIDI Devices and applications.
The driver takes care of low-level binary communication (CoAP) between the VIDI Devices and the server, allowing the third-party application to interact with the field devices using high-level protocols and formats such as MQTT and JSON.
The driver makes the low-level communication transparent to the third-party application, hence enabling a fast development of the software connector.

### CoAP
CoAP (Constrained Application Protocol) is a lightweight, RESTful communication protocol specifically designed for constrained devices and networks in the Internet of Things (IoT). It enables simple, efficient, and resource-friendly communication between devices with limited processing power, memory, and battery life, operating over lossy and low-bandwidth networks such as NB-IoT or LTE-M. CoAP typically runs over UDP (User Datagram Protocol) instead of TCP, minimizing resource usage while providing faster communication.

### MQTT
MQTT (Message Queuing Telemetry Transport) is a lightweight, publish-subscribe-based messaging protocol. The publish-subscribe pattern enables to decouple components and to scale efficiently.

# Installation

This section describes how to install the VIDI MQTT Driver with Docker Compose. Although Docker is a cross-platform containerization software, the present guide shows the installation commands for a Linux host, as this is the most common scenario.

### Docker Compose
Docker Compose makes it possible to configure and run multiple Docker containers at once using a docker-compose.yml file.
The driver is composed by the following containers:

- **mysql**: MySQL database server, used to store device configurations and frame logs
- **vernemq**: MQTT broker
- **api-server**
- **coap-gateway**: CoAP Gateway based on the Open Source project [Californium](https://eclipse.dev/californium)
- **frontend**: Web frontend for configuration of the driver
- **redis**: in-memory key–value database, cache and message broker
- **ntp**: NTP server used to provide synchronization service to the field devices


### Requirements
Before you continue, please make sure that you have Docker and Compose installed. Please refer to https://docs.docker.com/get-docker/ for documentation on how to install Docker.
To get the Docker compose file


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

To clone this repository, you can use the following command:

```console
git clone https://github.com/aswatisrl/vidi-mqtt-driver
```

### Installation package
Download the installation package *coap_mqtt_driver.zip* and extact the content into a folder on the host. 
The rest of guide will imply you have extracted the zip into the folder `/opt/coap_mqtt_driver` but any folder can be used. If you choose another folder, be sure to edit all the commands accordingly.

The zip contains:
- **config-apiserver**: it contains the configuration files for the API Server container
- **config-gateway**: it contains the configuration files for the CoAP Gateway container
- **scripts**: it contains the MySQL database initialization scripts
- **compose.yaml**: Docker Compose file
- **dump_db.sh**: script to execute a daily backup copy of the database (optional - see Backup section)

When the service is started for the first time, Docker will create the following empty folders that will be mounted on the containers:
- **db_data**: will contain the data of the MySQL database
- **logs-apiserver**: will contain the logs of the API Server
- **logs-gateway**: will contain the logs of the CoAP Gateway

### Preliminary configuration
Before launching Docker Compose for the first time, it is necessary to edit the following configuration files

#### compose.yaml
Open the file `compose.yaml` with a text editor and replace `<MYSQL_ROOT_PASSWORD>` with a strong password. Please use lowercase and uppercase letters, digits and special characters. Avoid the `=` character as it is not allowed for passing environment variables.

According to the provided `compose.yaml` configuration file, the VerneMQ MQTT broker is started with the ALLOW_ANONYMOUS flag, meaning that the broker is accepting connections from anonymous clients. It's possible to disable the anonymous login by editing the line to ` - DOCKER_VERNEMQ_ALLOW_ANONYMOUS=off`

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

#### config-apiserver / default.json
Open the file `config-apiserver/default.json` with a text editor and:
- Replace `<MYSQL_ROOT_PASSWORD>` with the password you specified in the `compose.yaml` file (service *mysql*)
- Replace `<JWT_SECRET_KEY>` with a utf-8 encoded string. We suggest at least 32 characters. The key is used to sign and verify the JSON Web Tokens.
- In case you disabled the anonymous login in the MQTT section of the `compose.yaml` file, you need to populate the `mqtt.username` and `mqtt.password` with the username and password you specified for the API Server user in the `compose.yaml` file (service *vernemq*)

#### config-gateway / config.properties
In case you disabled the anonymous login in the MQTT section of the `compose.yaml` file, you need to open the file `config-gateway/config.properties` with a text editor and populate the `MQTT.USERNAME` and `MQTT.PASSWORD` with the username and password you specified for the CoAP Gateway user in the `compose.yaml` file (service *vernemq*)
You will also need to 

# Launch the VIDI MQTT Driver
Launch the driver with the command
```console
docker compose up -d
```
### Monitoring of the service
You can access the logs in two ways:
- Accessing the Docker logs
```console
docker logs <container_name> -f
```
For example:
```console
docker logs api-server -f
```
The option `-f` allows to follow log output as it grows in real time
- Accessing the log files
The log folders are mounted on the host, so they can be accessed directly from the Host
```console
/opt/coap_mqtt_driver/logs-apiserver
/opt/coap_mqtt_driver/logs-gateway
```

# Initialization

### Frontend
Log in to the web configuration page of the driver by opening a web browser and entering the url `http://127.0.0.1`
The default credentials are:
- Username: admin
- Password: admin

**Important** At first access, change the password by clicking on the profile icon at the botton of the left sidebar

The CoAP Gateway needs also to consume the APIs exposed by API Server. For this purpose, a default user is created in the API Server during the initialization:
- Username: coap_gateway_user
- Password: changeme

Log out from `admin` user and log is as `coap_gateway_user`
Once logged, change the password by clicking on the profile icon at the botton of the left sidebar

At this point you need to open again the `config-gateway/config.properties` and edit the row `API.PASSWORD=changeme` replacing the default password with the new one that you just created.
Restart the container using the commands
```console
docker restart coap-gateway
```

### Adding devices
... TODO

# Backup

### Optional: daily database backup

The database stores the OSCORE context for each device. The context is the local set of information elements necessary to carry out the cryptographic operations. In case of a data loss, it won't be possible for the devices to communicate anymore with the CoAP server, and it will be necessary to trigger a new join procedure on the device by swithing the radio OFF and ON locally on the field.
For this reason we strongly advice to configure the automatic daily backup of the database. 
Open the crontab with the command:
```console
crontab -e
```

Append the following line in order to execute a copy (dump) of the database every night at 2 am:
```
0 2  * * *    cd /opt/coap_mqtt_driver && ./dump_db.sh
```
A dump of the database will be generated and copied into the folder `backup_db`, with a retention policy of 28 days

**Note** If the `backup_db` folder does not exist, it will be created in the same directory of the script

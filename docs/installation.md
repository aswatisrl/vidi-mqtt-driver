# Installation

This section describes how to install the VIDI MQTT Driver with Docker Compose. Although Docker is a cross-platform containerization software, the present guide shows the installation commands for a Linux host, as this is the most common scenario.

### Docker Compose
Docker Compose makes it possible to configure and run multiple Docker containers at once using the `compose.yml` file.
The driver consists of the following containers:

- **mysql**: MySQL database server, used to store device configurations and frame logs
- **vernemq**: MQTT broker, used for async communication between services
- **api-server**: API Server, the engine of the driver
- **coap-gateway**: CoAP gateway based on the Open Source project [Californium](https://eclipse.dev/californium)
- **coap-monitor**: Manages background tasks, such as log writing and data cleanup
- **frontend**: Web frontend for configuration of the driver and API documentation
- **redis**: in-memory key–value database, cache and message broker
- **ntp**: NTP server used to provide synchronization service to the field dev
ices

### Requirements
Before you continue, please make sure that you have Docker and Compose installed. Please refer to https://docs.docker.com/get-docker/ for documentation on how to install Docker.

The hardware specifications mainly depend on the number of devices and the sampling/transmission rates. Anyway, a minimum recommendation is:
- 2 vCPU
- 4 GB RAM
- 20 GB storage

During the setup you will also need a **license token** and the credentials for pulling the images from the GitHub Container Registry. Please contact your sales representative or authorized reseller to obtain them.

### Login to the container repository
The containers are hosted in a GitHub repository. By issuing the `docker compose up` command, Docker will try to pull the images from the GitHub Container Registry. Since the repository is not publicly accessible, you need a valid username (*GH_USERNAME*) and password (*GH_PASSWORD*) to pull the Docker images.

Open a console on the host machine (the one that will run the containers) and run the command: 

```console
echo <GH_PASSWORD> | docker login ghcr.io -u <GH_USERNAME> --password-stdin
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

- **scripts**: it contains MySQL database initialization scripts
- **compose.yaml**: Docker Compose file
- **dump_db.sh**: script to execute a daily backup copy of the database (optional - see Backup section in [First launch](first-launch.md))

When the service is started for the first time, Docker will create the following empty folders that will be mounted on the containers:
- **db_data**: will contain the data of the MySQL database
- **logs-apiserver**: will contain the logs of the API Server
- **logs-gateway**: will contain the logs of the CoAP Gateway

### Preliminary configuration
Before launching Docker Compose for the first time, it is necessary to edit the configuration. Open the file `compose.yaml` with a text editor and edit the following:

#### Service `mysql`
- Replace `<MYSQL_ROOT_PASSWORD>` with a strong password. Please use lowercase and uppercase letters, numbers and special characters.

#### Service `vernemq`
According to the default configuration, the VerneMQ MQTT broker is started with the `ALLOW_ANONYMOUS` flag, meaning that the broker is accepting connections from anonymous clients. It's possible to disable the anonymous login by editing the line to `DOCKER_VERNEMQ_ALLOW_ANONYMOUS=off`  
In this case, it's necessary to add users and passwords as environment variables by adding to the compose file:   
` - DOCKER_VERNEMQ_USER_<USERNAME>='password'`  
where `<USERNAME>` is the username you want to use.  
This can be done as many times as necessary to create the users you want. The usernames will always be created in lowercase.
Be aware that you will need at least one user for the API Server, one user for CoAP Gateway and one user for your application.
Example:
```
vernemq:
  ...
  environment:
    ...
    - DOCKER_VERNEMQ_USER_apiserveruser=password1
    - DOCKER_VERNEMQ_USER_gatewayuser=password2
    - DOCKER_VERNEMQ_USER_appuser=password3
```
⚠️ If the password contains a `=` character, make sure to enclose it in double quotes.

#### Service `api-server`
- Replace `<LICENSE_TOKEN>` with your license token. Without a valid license, the service will not start.
- Replace `<MYSQL_ROOT_PASSWORD>` with the password you specified in the service *mysql*.
- Replace `<JWT_SECRET_KEY>` with a utf-8 encoded string. We suggest at least 32 characters. The key is used by the API Server to sign and verify the JSON Web Tokens.
- In case you disabled the anonymous login in the service *vernemq*, populate the `MQTT_USERNAME` and `MQTT_PASSWORD` environmental variables with the username and password you specified above.
- The default repository for the device firmware is: `https://vidimanager.asw-ati.com/api/fota/`. Using this repository ensures that devices always receive the latest firmware version when performing a FOTA (Firmware Over-The-Air) update. However, if your IT architecture does not allow outbound Internet traffic, you can use a local firmware repository, that you will need to populate manually for each release. In this case, either remove the `FIRMWARE_REPO` variable or set it to local.
Example:
```
- FIRMWARE_REPO=local
```

#### Service `coap-monitor`
- Replace `<MYSQL_ROOT_PASSWORD>` with the password you specified in the service *mysql*
- Optionally, edit the `DATA_RETENTION` environmental parameter with desired retention for the uplink and downlink records in the database. The retention is expressed in days. Default is 30 days
- For `FIRMWARE_REPO`, the same rules described above for the `api-server` service apply

#### Service `coap-gateway`
In case you disabled the anonymous login in the service *vernemq*, populate the `MQTT_USERNAME` and `MQTT_PASSWORD` environmental variables with the username and password you specified above. 


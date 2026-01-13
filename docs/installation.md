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
- **ntp**: NTP server used to provide synchronization service to the field devices

### Requirements
Before you continue, please make sure that you have Docker and Compose installed. Please refer to https://docs.docker.com/get-docker/ for documentation on how to install Docker.

The hardware specifications mainly depend on the number of devices and the sampling/transmission rates. Anyway, a minimum recommendation is:
- 2 vCPU
- 4 GB RAM
- 20 GB storage

During the setup you will also need a valid license and the credentials for pulling the images from the GitHub Container Registry. Please contact your sales representative or authorized reseller to obtain them.

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
- Replace `<MYSQL_ROOT_PASSWORD>` with a strong password. Please use lowercase and uppercase letters, numbers and special characters. This is the password for the `root` user, which will be needed only for database managemenet.
- Replace `<MYSQL_USER_PASSWORD>` with a strong password. Please use lowercase and uppercase letters, numbers and special characters. This is the password for the `copauser` user, which will be used by the application.

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
- Replace `<MYSQL_USER_PASSWORD>` with the password specified in the *mysql* service.
- Replace `<JWT_SECRET_KEY>` with a key of your choice, UTF-8 encoded. We recommend at least 32 characters. This key is used by the API Server to sign and verify the JSON Web Tokens.
- If you disabled anonymous login in the *vernemq* service, set the `MQTT_USERNAME` and `MQTT_PASSWORD` environment variables with the username and password you specified.
- The default repository for the device firmware is:

  `https://vidimanager.asw-ati.com/api/fota/`


  Using this repository ensures that devices always receive the latest firmware version when performing a FOTA (Firmware Over-The-Air) update. However, if your IT architecture does not allow outbound Internet traffic, you can use a local firmware repository. In this case, you will need to populate manually the repository for each new firmware release (access the web interface and select `Firmware` from the side bar). If you need to use the local repository, either remove the `FIRMWARE_REPO` variable or set it to local.
Example:
  ```
  - FIRMWARE_REPO=local
  ```
- This software requires a valid license in order to function. Without a license, the application will not operate. You need to provide either a `LICENSE_TOKEN` or a `LICENSE_KEY`.
- If you own a `LICENSE_TOKEN`, replace `<LICENSE_TOKEN>` with your token. Remove the line with `LICENSE_KEY`. The software will operate for the duration of the token's validity. Before the token expires, make sure to obtain a new one from your sales representative, update the value and restart the container with `docker compose up -d api-server`
- If you own a `LICENSE_KEY`, replace `<LICENSE_KEY>` with your license key. Remove the line with `LICENSE_TOKEN`. The software uses an online license server to make sure your license is valid. Once per day, the application contacts the license server. If the license is valid, the server issues a token that remains valid for 7 days. Make sure your system has internet access and that no firewall rules are blocking outbound HTTPS traffic (port 443) to the license server. The following information is transmitted daily to the license server:
    - The license key
    - The version of the running containers
    - A list of the serial numbers of the devices currently enrolled in the Driver. The list is necessary to prevent unauthorized use of the software

  No other information — such as user data, device payloads, or metadata (e.g., notes, firmware versions, operators, keys) — is transmitted to the license server.

  At startup, if the application cannot reach the license server, it will stop immediately. During the daily validation of the license, if the software cannot contact the license server (for example, due to network issues), it will keep using the last valid token. If the problem persists and the license cannot be validated before the token expires (7 days) the software will stop working.


#### Service `coap-monitor`
- Replace `<MYSQL_USER_PASSWORD>` with the password you specified in the service *mysql*
- Optionally, edit the `DATA_RETENTION` environment variable with desired retention for the uplink and downlink records in the database. The retention is expressed in days. Default is 30 days
- For `FIRMWARE_REPO`, the same rules described above for the `api-server` service apply

#### Service `coap-gateway`
In case you disabled the anonymous login in the service *vernemq*, populate the `MQTT_USERNAME` and `MQTT_PASSWORD` environment variables with the username and password you specified above.


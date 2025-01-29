### Optional: daily database backup

The database stores the OSCORE context for each device. The context is the local set of information elements necessary to carry out the cryptographic operations. In case of a data loss, it won't be possible for the devices to communicate anymore with the CoAP server, and it will be necessary to trigger a new join procedure on the device by swithing the radio OFF and ON locally on the field.
For this reason we strongly advice to configure the automatic daily backup of the database. 
Open the crontab with the command:
```bash
crontab -e
```

Append the following line in order to execute a copy (dump) of the database every night at 2 am:
```
0 2  * * *    cd /opt/nbiot-server && ./dump_db.sh
```
A dump of the database will be generated and copied into the folder `backup_db`, with a retention policy of 28 days

?> If the `backup_db` folder does not exist, it will be created in the same directory of the script
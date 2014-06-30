DHT22 Temperature and Humidity Sensor - Beaglebone tools

Enable PRU on BBB:
```shell
echo BB-BONE-PRU-01 >/sys/devices/bone_capemgr.9/slots
```

At this point, the PRU should be detected in dmesg. The kernel module used to interface with it is uio_pruss. It gets loaded automatically.

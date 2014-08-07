DHT22 Temperature and Humidity Sensor - Beaglebone tools
========================================================

Using pin P8_15 as input.
Using pin P8_11 as output.

Both pins connect directly to the DHT22's data pin, but the output pin is protected by a 10k resistor. In theory a single pin is required rather than an input and an output, but this approach has the advantage of protecting the output pin against shorts.

[ Vcc ]---------------------------------.
                                        |
[ BBB P8_15 (in) ]----------------------.
                                        |--------[ DHT22 data ]
                                        |
[ BBB P8_11 (out) ]----[ 620 ohm ]------`

Enable PRU on BBB:
```shell
echo BB-BONE-PRU-01 >/sys/devices/bone_capemgr.9/slots
```

At this point, the PRU should be detected in dmesg. The kernel module used to interface with it is uio_pruss. It gets loaded automatically.

```shell
echo BB-DHT22-Pins-01 >/sys/devices/bone_capemgr.9/slots
```

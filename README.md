DHT22 Temperature and Humidity Sensor - Beaglebone tools
========================================================

Pinout
------

Using pin P8_15 as input.
Using pin P8_11 as output.

Both pins connect directly to the DHT22's data pin, but the output pin is protected by a 10k resistor. In theory a single pin is required rather than an input and an output, but this approach has the advantage of protecting the output pin against shorts. The input pin remains directly connected to the DHT22.

```
[ Vcc ]-----[ 10k ohm pull-up ]---------.
                                        |
[ BBB P8_15 (in) ]----------------------.
                                        |--------[ DHT22 data ]
                                        |
[ BBB P8_11 (out) ]----[ 620 ohm ]------`
```

Changing the pin modes
----------------------

The input pin is mapped to an internal PRU register for ultra fast access. This requires changing the pin mode with the following procedure.

Build the device tree overlay:

```shell
cd dht
make
```

Then copy it to the firmware directory so it gets loaded on boot.

```shell
cp BB-DHT22-Pins-00A0.dtbo /lib/firmware
```

Older versions of the BBB linux kernel supported dynamic application of device tree overlays with the following commands, but as of 3.8.13-bone57, this doesn't seem to work anymore. Commands for this older method are below for reference:

Enable PRU on BBB:
```shell
echo BB-BONE-PRU-01 >/sys/devices/bone_capemgr.9/slots
```

At this point, the PRU should be detected in dmesg. The kernel module used to interface with it is uio_pruss. It gets loaded automatically.

```shell
echo BB-DHT22-Pins-01 >/sys/devices/bone_capemgr.9/slots
```

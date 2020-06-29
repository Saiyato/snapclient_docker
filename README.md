# Dockerized SnapClient
This repository contains the scripts to auto-build images for SnapClient for the ARM architecture. The base image *resin/rpi-raspbian:jessie* is used for v0.15.0 and *resin/rpi-raspbian:buster* is used for newer versions.

## How to use
To use the images, follow the next steps
1. Run and pull the image from the repo and set necessary parameters;
 a. Add the sound device of the host to the container
 b. Set the hosting SnapServer you want to subscribe to
 c. Set the soundcard you wish to use (e.g. ALSA, sndrpihifiberry, BossDAC, etc.)

You can list the soundcards by invoking `docker run --device /dev/snd saiyato/snapclient:alpine -l` or `aplay -l`. Some example outputs:
###### BossDAC
```
pi@raspberrypi:~ $ aplay -l
**** List of PLAYBACK Hardware Devices ****
card 0: ALSA [bcm2835 ALSA], device 0: bcm2835 ALSA [bcm2835 ALSA]
  Subdevices: 8/8
  Subdevice #0: subdevice #0
  Subdevice #1: subdevice #1
  Subdevice #2: subdevice #2
  Subdevice #3: subdevice #3
  Subdevice #4: subdevice #4
  Subdevice #5: subdevice #5
  Subdevice #6: subdevice #6
  Subdevice #7: subdevice #7
card 0: ALSA [bcm2835 ALSA], device 1: bcm2835 ALSA [bcm2835 IEC958/HDMI]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: BossDAC [BossDAC], device 0: Boss DAC HiFi [Master] pcm512x-hifi-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```

###### HifiBerry card
```
pi@raspiberrypi:~$ aplay -l
**** List of PLAYBACK Hardware Devices ****
card 0: ALSA [bcm2835 ALSA], device 0: bcm2835 ALSA [bcm2835 ALSA]
  Subdevices: 7/7
  Subdevice #0: subdevice #0
  Subdevice #1: subdevice #1
  Subdevice #2: subdevice #2
  Subdevice #3: subdevice #3
  Subdevice #4: subdevice #4
  Subdevice #5: subdevice #5
  Subdevice #6: subdevice #6
card 0: ALSA [bcm2835 ALSA], device 1: bcm2835 IEC958/HDMI [bcm2835 IEC958/HDMI]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 0: ALSA [bcm2835 ALSA], device 2: bcm2835 IEC958/HDMI1 [bcm2835 IEC958/HDMI1]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: sndrpihifiberry [snd_rpi_hifiberry_dac], device 0: HifiBerry DAC HiFi pcm5102a-hifi-0 [HifiBerry DAC HiFi pcm5102a-hifi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```

## Short and concise example
The below example demonstrates how you can run the container using the above information. Note that I have added the `--rm` option, to auto-delete the container after exiting (for cleanup purposes).

```
docker run \
--rm \
--device /dev/snd \
-h 192.168.1.10 \
-s BossDAC \
saiyato/snapclient:alpine \
```

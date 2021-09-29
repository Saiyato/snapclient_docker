# SnapCast
[Snapcast](https://github.com/badaix/snapcast) is a multiroom client-server audio player, where all clients are time synchronized with the server to play perfectly synced audio. It's not a standalone player, but an extension that turns your existing audio player into a Sonos-like multiroom solution. The server's audio input is a named pipe `/tmp/snapfifo`. All data that is fed into this file will be sent to the connected clients. One of the most generic ways to use Snapcast is in conjunction with the music player daemon (MPD) or Mopidy, which can be configured to use a named pipe as audio output.

## Dockerized SnapClient
This repository contains the scripts to auto-build images for SnapClient (the *player* or *client* part of the solution) for the ARM architecture. The base image *resin/rpi-raspbian:jessie* was used for v0.15.0 and *resin/rpi-raspbian:buster* was used for v0.20.0. 

I've then moved forward to *{arch}/alpine:latest* instead, and build from source instead of using pre-built binaries from the package archive. So all architecture specific images use the Alpine base image.

[ ] Todo: configure auto-build for changes in Badaix's repo

Unfortunately Docker auto-build has been discontinued for free use, so I have to manually build, push and create manifests. If you want to do this yourself, no problem.
1. Clone the repo
2. Make the bash-files executable (`chmod +x`)
3. Install Docker desktop
4. `./build-multiarch.sh -t <any_tag_you_want> -f <dockerfile>`
e.g. `./build-multiarch.sh -t saiyato/snapclient:arm32v7 -f Dockerfile.arm32v7`

Want to upload it to your own Docker Hub repo? Also no problem
1. Continue from the above (clone, chmod, etc)
2. Login to Docker (`docker login`) to save your credentials on your machine
3. `./push_to_dockerhub.sh -i <the_image_you_want_to_upload_for>`
e.g. `./push_to_dockerhub.sh -i saiyato/snapclient`

Note that the upload script will look for the arm32v6, arm32v7, arm64v8, amd64 and i386 tags to push and annotate.

###### Overall
<img alt="Docker Cloud Build Status" src="https://img.shields.io/docker/cloud/build/saiyato/snapclient?style=flat-square">  <img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/saiyato/snapclient?style=flat-square">

Added the latest tag, which can be used on any arch and automatically selects the appropriate image. Note that this does not include PulseAudio support, you will need to append "-with-pulse" to the desired tag (e.g. latest-with-pulse).

###### Raspbian images
The Raspbian images have been discontinued. The Alpine images work on Debian and are way smaller (and therefore more suited for the ARM platform).

###### ARM32v6
<img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapclient/arm32v6?style=flat-square">
###### ARM32v7
<img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapclient/arm32v7?style=flat-square">
###### ARM64v8
<img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapclient/arm64v8?style=flat-square">

###### AMD64
<img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapclient/amd64?style=flat-square">
###### i386
<img alt="Docker Image Size (tag)" src="https://img.shields.io/docker/image-size/saiyato/snapclient/i386?style=flat-square">

## How to use the images
To use the images, run (which automatically pulls) the image from the repo and set necessary parameters;
1. Add the sound device of the host to the container (for security reasons I want to refrain from using `--privileged`)
2. Define the hosting SnapServer you want to subscribe to
3. Define the soundcard you wish to use (e.g. ALSA, sndrpihifiberry, BossDAC, etc.)

You can list the soundcards by invoking `docker run --device /dev/snd saiyato/snapclient -l` or `aplay -l`. Some example outputs:
###### BossDAC example with "snapclient -l"
```
pi@buildpi:~ $ docker run --rm --device /dev/snd saiyato/snapclient -l
0: null
Discard all samples (playback) or generate zero samples (capture)

1: default:CARD=ALSA
bcm2835 ALSA, bcm2835 ALSA
Default Audio Device

2: sysdefault:CARD=ALSA
bcm2835 ALSA, bcm2835 ALSA
Default Audio Device

3: default:CARD=BossDAC
BossDAC,
Default Audio Device

4: sysdefault:CARD=BossDAC
BossDAC,
Default Audio Device
```

###### HifiBerry card example with "aplay -l"
```
pi@buildpi:~$ aplay -l
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
The below example demonstrates how you can run the container using the above information. Note that I have added the `--rm` option, to auto-delete the container after exiting (for cleanup purposes). If you want a daemonized container, just add `-d` before referencing the desired container. Note the latest update is that the latest tag will pull the appropriate container for your architecture (if supported).

```
docker run \
--rm \
--name snapclient \
--device /dev/snd \
saiyato/snapclient \
-h 192.168.1.10 \
-s BossDAC
```
Or in the case of a Hifiberry soundcard _and_ daemonized
```
docker run \
--rm \
-d \
--name snapclient \
--device /dev/snd \
saiyato/snapclient \
-h 192.168.1.10 \
-s sndrpihifiberry
```
You can omit the "-s" parameter if you want to use the default output device.

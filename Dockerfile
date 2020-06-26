# Install SnapClient on minimal OS
FROM resin/rpi-raspbian:jessie
MAINTAINER Saiyato

ARG SNAPCASTVERSION
ARG VERSIONSUFFIX

ENV HOST snapserver
ENV SOUNDCARD alsa

RUN apt-get update && apt-get install -y \
        dirmngr \
        gnupg \
        wget \
        alsa-base \
        alsa-utils

RUN wget https://github.com/badaix/snapcast/releases/download/v${SNAPCASTVERSION}/snapclient_${SNAPCASTVERSION}${VERSIONSUFFIX}_armhf.deb

RUN dpkg -i --force-all snapclient_${SNAPCASTVERSION}${VERSIONSUFFIX}_armhf.deb

RUN apt-get -f install -y \
        && rm -rf /var/lib/apt/lists/*

RUN snapclient -v

ENTRYPOINT ["/bin/bash","-c","snapclient -h $HOST -s $SOUNDCARD"]

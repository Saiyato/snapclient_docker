# Install SnapClient on minimal OS
FROM amd64/alpine:latest

MAINTAINER Saiyato

RUN apk -U add git bash build-base asio-dev avahi-dev flac-dev libvorbis-dev alsa-lib-dev opus-dev soxr-dev cmake \
 && cd /root \
 && git clone --recursive https://github.com/badaix/snapcast.git \
 && mkdir snapcast/build \
 && cd snapcast/build \
 && cmake -DBUILD_WITH_PULSE=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_SERVER=OFF .. \
 && make \
 && cp ../bin/snapclient /usr/local/bin \
 && cd / \
 && apk --purge del git build-base asio-dev avahi-dev flac-dev libvorbis-dev alsa-lib-dev opus-dev soxr-dev cmake \
 && apk add avahi-libs flac libvorbis opus soxr alsa-lib \
 && rm -rf /etc/ssl /var/cache/apk/* /lib/apk/db/* /root/snapcast

ENTRYPOINT ["snapclient"]

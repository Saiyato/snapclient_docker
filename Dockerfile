# Install SnapClient on minimal OS
FROM amd64/alpine:latest

MAINTAINER Saiyato

RUN apk -U add alsa-lib-dev avahi-dev bash build-base ccache cmake expat-dev flac-dev git libvorbis-dev opus-dev soxr-dev  \
 && cd /root \
 && git clone --recursive https://github.com/badaix/snapcast.git \
 && cd snapcast \
 && wget https://dl.bintray.com/boostorg/release/1.75.0/source/boost_1_75_0.tar.bz2 && tar -xvjf boost_1_75_0.tar.bz2 \
 && cmake -S . -B build -DBOOST_ROOT=boost_1_75_0 -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DBUILD_WITH_PULSE=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_SERVER=OFF .. \
 && cmake --build build --parallel 3 \
 && cp bin/snapclient /usr/local/bin \
 && apk --purge del alsa-lib-dev avahi-dev bash build-base ccache cmake expat-dev flac-dev git libvorbis-dev opus-dev soxr-dev \
 && apk add alsa-lib avahi-libs expat flac libvorbis opus soxr \
 && rm -rf /etc/ssl /var/cache/apk/* /lib/apk/db/* /root/snapcast

ENTRYPOINT ["snapclient"]

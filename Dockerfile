# Install SnapServer on minimal OS - script v2.0.3 [2021-04-11]
FROM amd64/alpine:3.14.2

LABEL maintainer="Saiyato"
WORKDIR /root

RUN apk -U add alsa-lib-dev avahi-dev bash build-base ccache cmake expat-dev flac-dev git libvorbis-dev opus-dev soxr-dev  \
 && git clone --recursive https://github.com/badaix/snapcast.git \
 && cd snapcast \
 && wget https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.bz2 && tar -xvjf boost_1_76_0.tar.bz2 \
 && cmake -S . -B build -DBOOST_ROOT=boost_1_76_0 -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DBUILD_WITH_PULSE=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_SERVER=OFF .. \
 && cmake --build build --parallel 3 \
 && cp bin/snapclient /usr/local/bin \
 && apk --purge del alsa-lib-dev avahi-dev bash build-base ccache cmake expat-dev flac-dev git libvorbis-dev opus-dev soxr-dev \
 && apk add alsa-lib avahi-libs flac libvorbis opus soxr \
 && rm -rf /etc/ssl /var/cache/apk/* /lib/apk/db/* /root/snapcast
 
ENTRYPOINT ["snapclient"]

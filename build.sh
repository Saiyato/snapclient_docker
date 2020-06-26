#!/bin/sh

docker build \
-t saiyato/snapclient:development \
--build-arg SNAPCASTVERSION=0.15.0 .

# build for version 0.15.0, replace with necessary version, if version is suffixed with -1, add -1 as extra parameter before the final dot

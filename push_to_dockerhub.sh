#!/bin/bash
# Check for start arguments
while getopts "i:" flag
do
	case "${flag}" in
		i) IMAGE=${OPTARG};;
	esac
done
if [ -z $IMAGE ] ; then
	echo "No image provided"
	exit 1;
else
	echo "Processing image: $IMAGE"
fi

# Login to Docker
DOCKER_USER=$(docker info | grep Username | cut -d":" -f2)
if [ ! -z "$DOCKER_USER" ] ; then
	echo "Docker logged in, continuing...";
else
	echo "Docker not logged in, trying to login with saved credentials..."
	docker login
fi

# Fetch docker-cli binary
curl -SL "https://download.docker.com/linux/static/stable/x86_64/docker-18.09.6.tgz" | tar xvz docker/docker --transform='s/.*/docker-cli/'

# Enable experimental features (for manifest)
EXPERIMENTAL=$(cat ~/.docker/config.json | grep experimental)
if [ -z "$(cat ~/.docker/config.json | grep experimental)" ] ; then
	echo "Enabling experimental mode"
	sed -i -- 's|"auths"|"experimental":"enabled",\n\t"auths"|g' ~/.docker/config.json
fi

ARM32v6_IMAGE="$IMAGE:arm32v6"
ARM32v7_IMAGE="$IMAGE:arm32v7"
ARM64v8_IMAGE="$IMAGE:arm64v8"
AMD64_IMAGE="$IMAGE:amd64"
I386_IMAGE="$IMAGE:i386"

echo "Checking if $ARM32v6_IMAGE manifest exist"
if ! ./docker-cli manifest inspect ${ARM32v6_IMAGE}; then
	ARM32v6_IMAGE = ''
else
	docker push $ARM32v6_IMAGE
fi
echo "Checking if $ARM32v7_IMAGE manifest exist"
if ! ./docker-cli manifest inspect ${ARM32v7_IMAGE}; then
	ARM32v7_IMAGE = ''
else
	docker push $ARM32v7_IMAGE
fi
echo "Checking if $ARM64v8_IMAGE manifest exist"
if ! ./docker-cli manifest inspect ${ARM64v8_IMAGE}; then
	ARM64v8_IMAGE = ''
else
	docker push $ARM64v8_IMAGE
fi
echo "Checking if $AMD64_IMAGE manifest exist"
if ! ./docker-cli manifest inspect ${AMD64_IMAGE}; then
	AMD64_IMAGE = ''
else
	docker push $AMD64_IMAGE
fi
echo "Checking if $I386_IMAGE manifest exist"
if ! ./docker-cli manifest inspect ${I386_IMAGE}; then
	I386_IMAGE = ''
else
	docker push $I386_IMAGE
fi

echo "Creating multiarch manifest..."
	./docker-cli manifest create --amend $IMAGE $ARM32v6_IMAGE $ARM32v7_IMAGE $ARM64v8_IMAGE $AMD64_IMAGE $I386_IMAGE
if [ -n "$ARM32v6_IMAGE" ]; then
	./docker-cli manifest annotate $IMAGE $ARM32v6_IMAGE --os linux --arch arm --variant v6
fi
if [ -n "$ARM32v7_IMAGE" ]; then
	./docker-cli manifest annotate $IMAGE $ARM32v7_IMAGE --os linux --arch arm --variant v7
fi
if [ -n "$ARM64v8_IMAGE" ]; then
	./docker-cli manifest annotate $IMAGE $ARM64v8_IMAGE --os linux --arch arm64
fi

./docker-cli manifest push $IMAGE

# Cleanup
rm -r docker-cli


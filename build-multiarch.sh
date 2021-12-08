#!/bin/bash

# Take arguments
while getopts i:a:c flag
do
	case "${flag}" in
		i) IMAGE_NAME=${OPTARG};;
		a) ARCHITECTURE=${OPTARG};;
		c) CACHE="true";;
	esac
done

if [[ ! -z "$IMAGE_NAME" && ! -z "$ARCHITECTURE" ]] ; then
	
	echo "Building image: '${IMAGE_NAME}' on architecture: ${ARCHITECTURE}"

	if [[ $ARCHITECTURE != "amd64" && $ARCHITECTURE != "i386" ]] ; then

		case ${ARCHITECTURE} in
			arm32v6 ) QEMU_ARCH="arm" ;;
			arm32v7 ) QEMU_ARCH="arm" ;;
			arm64v8 ) QEMU_ARCH="aarch64" ;
		esac

		if [[ -z $QEMU_ARCH ]] ; then
			echo "Unsupported architecture ($QEMU_ARCH)" && exit 0;
		fi

		QEMU_USER_STATIC_DOWNLOAD_URL="https://github.com/multiarch/qemu-user-static/releases/download"
		QEMU_USER_STATIC_LATEST_TAG=$(curl -s https://api.github.com/repos/multiarch/qemu-user-static/tags \
			| grep 'name.*v[0-9]' \
			| head -n 1 \
			| cut -d '"' -f 4)

		curl -SL "${QEMU_USER_STATIC_DOWNLOAD_URL}/${QEMU_USER_STATIC_LATEST_TAG}/x86_64_qemu-${QEMU_ARCH}-static.tar.gz" \
			| tar xzv

		docker run --rm --privileged multiarch/qemu-user-static:register --reset
		
	else
		echo 'qemu-user-static: Download not required for current architecture'
	fi
	
	if [[ $CACHE == "true" ]] ; then
		echo "Running build using caching"
		docker build -t $IMAGE_NAME:$ARCHITECTURE --build-arg ARCHITECTURE=$ARCHITECTURE .
	else
		echo "Building without cache"
		docker build -t $IMAGE_NAME:$ARCHITECTURE --build-arg ARCHITECTURE=$ARCHITECTURE --no-cache .
	fi

	if [[ ! -z $QEMU_ARCH ]] ; then
		rm qemu-*-static
	fi
	
else
	echo "No image or architecture provided. Usage: -i {image} -a {architecture}"
fi
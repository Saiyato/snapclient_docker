#!/bin/bash

# take argument
while getopts f:t: flag
do
	case "${flag}" in
		f) DOCKERFILE_PATH=${OPTARG};;
		t) TAG=${OPTARG};;
	esac
done

if [[ ! -z "$DOCKERFILE_PATH" && ! -z "$TAG" ]] ; then
	
	echo "Building with tag: '${TAG}' and dockerfile: ${DOCKERFILE_PATH}"
	
	# Get architecture from Dockerfile.arch filename
	BUILD_ARCH=$(echo "${DOCKERFILE_PATH}" | cut -d '.' -f 2)

	# For amd64 filename is Dockerfile
	[[ "${BUILD_ARCH}" == "Dockerfile" || "${BUILD_ARCH}" == "i386" ]] && \
		{ echo 'qemu-user-static: Download not required for current arch'; exit 0; }

	case ${BUILD_ARCH} in
		amd64 ) QEMU_ARCH="x86_64" ;;
		i386 ) QEMU_ARCH="i386" ;;
		arm32v6 ) QEMU_ARCH="arm" ;;
		arm32v7 ) QEMU_ARCH="arm" ;;
		arm64v8 ) QEMU_ARCH="aarch64" ;
	esac

	QEMU_USER_STATIC_DOWNLOAD_URL="https://github.com/multiarch/qemu-user-static/releases/download"
	QEMU_USER_STATIC_LATEST_TAG=$(curl -s https://api.github.com/repos/multiarch/qemu-user-static/tags \
		| grep 'name.*v[0-9]' \
		| head -n 1 \
		| cut -d '"' -f 4)

	curl -SL "${QEMU_USER_STATIC_DOWNLOAD_URL}/${QEMU_USER_STATIC_LATEST_TAG}/x86_64_qemu-${QEMU_ARCH}-static.tar.gz" \
		| tar xzv
		
	BUILD_ARCH=$(echo "${DOCKERFILE_PATH}" | cut -d '.' -f 2)

	[ "${BUILD_ARCH}" == "Dockerfile" ] && \
		{ echo 'qemu-user-static: Registration not required for current arch'; exit 0; }

	docker run --rm --privileged multiarch/qemu-user-static:register --reset
	
	docker build -t ${TAG} -f $DOCKERFILE_PATH .
else
	echo "No tag or Dockerfile provided. Usage: -t {tag} -f {dockerfile location}"
fi
#!/usr/bin/env bash

set -eux

AUTH_FILE=""
if test -f ~/auth.json; then
    AUTH_FILE="$(realpath ~/auth.json)"
    export REGISTRY_AUTH_FILE="$AUTH_FILE"
fi



set -e

SOURCE_IMAGE="acmuic.azurecr.io/nerv/baseos:${1:-latest}"

echo "Making Image: ${SOURCE_IMAGE}"

mkdir -p dnf-cache

# Need to set --tmpdir to a non /run location as the image is quite thicc
# and /run is mounted to be relatively small
# compat-volumes make dnf cache actually work (allegedly)
podman build --compat-volumes --tmpdir=/pod --volume $PWD/dnf-cache:/var/cache/dnf:Z --format docker . -t "$SOURCE_IMAGE"

podman push "$SOURCE_IMAGE" ${AUTH_FILE:+ --authfile $AUTH_FILE}

# use this to make the installer image.
# podman run \
#    --rm \
#    -it \
#    --privileged \
#    --pull=newer \
#    --security-opt label=type:unconfined_t \
#    -v ./config.toml:/config.toml:ro \
#    -v ./output:/output \
#    -v store:/store \
#    -v rpmmd:/rpmmd \
#    -v /var/lib/containers/storage:/var/lib/containers/storage \
#    quay.io/centos-bootc/bootc-image-builder:latest \
#    --type anaconda-iso \
#    --rootfs=ext4 --use-librepo=True \
#    "$SOURCE_IMAGE"
# #
# rsync -avzhP output/bootiso/install.iso root@172.25.8.6:/var/lib/vz/template/iso/bootc1.iso

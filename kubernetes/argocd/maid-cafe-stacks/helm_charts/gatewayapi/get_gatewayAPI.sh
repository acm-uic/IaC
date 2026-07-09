#!/usr/bin/env bash

VERSION=1.6.0
CHANNEL=${CHANNEL:-experimental} # Default to experimental channel for TLSRoute support in which Cillium needs

curl -fsSL https://github.com/kubernetes-sigs/gateway-api/releases/download/v${VERSION}/${CHANNEL}-install.yaml \
        -o gateway_api_${CHANNEL}.yml
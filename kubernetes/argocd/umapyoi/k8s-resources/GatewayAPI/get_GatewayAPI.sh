#!/usr/bin/env bash

VERSION=1.6.1
CHANNEL=${CHANNEL:-experimental} # Default to experimental channel for TLSRoute support in which Cillium needs

curl -fsSL https://github.com/kubernetes-sigs/gateway-api/releases/download/v${VERSION}/${CHANNEL}-install.yaml \
        -o gateway_api_v${VERSION}_${CHANNEL}.yaml

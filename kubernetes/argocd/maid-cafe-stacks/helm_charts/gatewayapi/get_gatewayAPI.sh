#!/usr/bin/env bash

VERSION=1.5.0
curl -fsSL https://github.com/kubernetes-sigs/gateway-api/releases/download/v${VERSION}/standard-install.yaml -o gateway_api.yml
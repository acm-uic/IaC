#!/usr/bin/env bash

VERSION=1.21.2

curl -fsSL https://github.com/cert-manager/cert-manager/releases/download/v${VERSION}/cert-manager.yaml \
	-o cert_manager_${VERSION}.yaml

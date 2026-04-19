#!/usr/bin/env sh

set -eu


need() {
    if ! command -v "$1" 2>&1 > /dev/null; then
	echo "Missing $1 command in PATH";
	exit 1;
    fi
}

need consul-template
need sops

consul-template -config=./config.hcl -once

if test -f "temp.yml"; then
    echo "deleting secrets..."
    rm temp.yml
fi

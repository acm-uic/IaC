#!/usr/bin/env sh

set -euo pipefail

key_path="/var/etc/munge/munge.key"

# test -s means "check if file exists and is bigger than 0 bytes"
# Have this in case sops decrypt fails and the pipeline makes an empty file
# Also incase script was run previously without pipefail

if test -s "${key_path}"; then
    chown munge:munge "${key_path}"
    chmod 0700 "${key_path}"
    echo "Mungekey already exists, not remaking."
    exit 0
fi

# Reminder this is the sops wrapper with age private key variable
# set
sops decrypt --extract "['mungekey']" /sops.yml |
    base64 -d - > "${key_path}"

chown munge:munge "${key_path}"
chmod 0700 "${key_path}"


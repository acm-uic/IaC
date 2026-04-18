#!/usr/bin/env sh

set -eu

if ! command -v envsubst > /dev/null 2>&1; then
    echo "No envsubst"
    exit 1;
fi
    

sops exec-env /sops.yml "sh -c '< /etc/slurm/slurmdbd.conf.envsubst envsubst > /var/etc/slurm/slurmdbd.conf'"

chown slurm:slurm /var/etc/slurm/slurmdbd.conf
chmod 0600 /var/etc/slurm/slurmdbd.conf

#!/usr/bin/env bash

set -eux


MY_HOSTNAME="${HOSTNAME}"

DOMAIN="acmuic.org"

LOCATION="${LOCATION:-OU=nerv,DC=acmuic,DC=org}"

if test -z "${MY_HOSTNAME}"; then
    echo "Not joining empty hostname! "
    exit -1
fi


if test "x${MY_HOSTNAME}" = "xlocalhost"; then
    echo "Not joining localhost to domain! "
    exit -1
fi

echo "$(date)"

if test -e "/var/secrets/krb5.keytab"; then
    echo "Kerberos keytab exists, not re-joining"
    exit 0
fi

adcli join -D "${DOMAIN}" -H "${MY_HOSTNAME}.${DOMAIN}" \
      --host-keytab="/var/secrets/krb5.keytab" \
      --domain-ou="${LOCATION}" \
      --description="Nerv Cluster Computer" \
      --login-user="nslcduser" \
      --stdin-password \
      --verbose 
      


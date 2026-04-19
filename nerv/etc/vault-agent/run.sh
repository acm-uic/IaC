#!/usr/bin/env sh

# This script templates in the username field for kerberos
# which is derived from the hostname.

set -eu

# This should NEVER be the case, but just in case.
if test -z "$HOSTNAME"; then
    echo "Variable HOSTNAME not set, cannot continue!"
    exit -1
fi

# Capitalize and append '$'
# Escape character before '$' because it is a special shell character
USERNAME="$(echo $HOSTNAME | tr '[a-z]' '[A-Z]')\$"

echo "Substituting username ${USERNAME}"

# since /etc is transient, the output file will be fresh every time.
sed "s|@username@|${USERNAME}|" config.hcl.in  > config.hcl

# note that this invokes the vault wrapper script from
# /usr/local/bin/vault and not '_vault'
# This is redundant as the config.hcl sets the same settings as the script,
# but this makes it more consistent imo.
exec vault agent -config=./config.hcl

#! /bin/bash
# Reference:
# * https://wiki.debian.org/AuthenticatingLinuxWithActiveDirectory
# * https://wiki.samba.org/index.php/Troubleshooting_Samba_Domain_Members
# * http://www.oreilly.com/openbook/samba/book/ch04_08.html

set -e

TZ=${TZ:-Etc/UTC}
# Update loopback entry
TZ=${TZ:-Etc/UTC}
AD_USERNAME=${AD_USERNAME:-administrator}
AD_PASSWORD=${AD_PASSWORD:-password}
HOSTNAME=${HOSTNAME:-$(hostname)}
IP_ADDRESS=${IP_ADDRESS:-}
DOMAIN_NAME=${DOMAIN_NAME:-domain.loc}
ADMIN_SERVER=${ADMIN_SERVER:-${DOMAIN_NAME,,}}
PASSWORD_SERVER=${PASSWORD_SERVER:-${ADMIN_SERVER,,}}

ENCRYPTION_TYPES=${ENCRYPTION_TYPES:-rc4-hmac des3-hmac-sha1 des-cbc-crc arcfour-hmac aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96 des-cbc-md5}

NAME_RESOLVE_ORDER=${NAME_RESOLVE_ORDER:-host bcast}

SERVER_STRING=${SERVER_STRING:-Samba Server Version %v}
SECURITY=${SECURITY:-ads}
REALM=${REALM:-${DOMAIN_NAME^^}}
PASSWORD_SERVER=${PASSWORD_SERVER:-${DOMAIN_NAME,,}}
WORKGROUP=${WORKGROUP:-${DOMAIN_NAME^^}}
WINBIND_SEPARATOR=${WINBIND_SEPARATOR:-"\\"}
WINBIND_UID=${WINBIND_UID:-50-9999999999}
WINBIND_GID=${WINBIND_GID:-50-9999999999}
WINBIND_ENUM_USERS=${WINBIND_ENUM_USERS:-yes}
WINBIND_ENUM_GROUPS=${WINBIND_ENUM_GROUPS:-yes}
TEMPLATE_HOMEDIR=${TEMPLATE_HOMEDIR:-/home/%D/%U}
TEMPLATE_SHELL=${TEMPLATE_SHELL:-/bin/bash}
CLIENT_USE_SPNEGO=${CLIENT_USE_SPNEGO:-yes}
CLIENT_NTLMV2_AUTH=${CLIENT_NTLMV2_AUTH:-yes}
ENCRYPT_PASSWORDS=${ENCRYPT_PASSWORDS:-yes}
SERVER_SIGNING=${SERVER_SIGNING:-auto}
SMB_ENCRYPT=${SMB_ENCRYPT:-auto}
WINDBIND_USE_DEFAULT_DOMAIN=${WINBIND_USE_DEFAULT_DOMAIN:-yes}
RESTRICT_ANONYMOUS=${RESTRICT_ANONYMOUS:-2}
DOMAIN_MASTER=${DOMAIN_MASTER:-no}
LOCAL_MASTER=${LOCAL_MASTER:-no}
PREFERRED_MASTER=${PREFERRED_MASTER:-no}
OS_LEVEL=${OS_LEVEL:-0}
WINS_SUPPORT=${WINS_SUPPORT:-no}
WINS_SERVER=${WINS_SERVER:-127.0.0.1}
DNS_PROXY=${DNS_PROXY:-no}
LOG_LEVEL=${LOG_LEVEL:-1}
DEBUG_TIMESTAMP=${DEBUG_TIMESTAMP:-yes}
LOG_FILE=${LOG_FILE:-/var/log/samba/log.%m}
MAX_LOG_SIZE=${MAX_LOG_SIZE:-1000}
# Deprecated: SYSLOG_ONLY=${SYSLOG_ONLY:-no}
# Deprecated: SYSLOG=${SYSLOG:-0}
PANIC_ACTION=${PANIC_ACTION:-/usr/share/samba/panic-action %d}
HOSTS_ALLOW=${HOSTS_ALLOW:-*}
SOCKET_OPTIONS=${SOCKET_OPTIONS:-TCP_NODELAY SO_KEEPALIVE IPTOS_LOWDELAY}
READ_RAW=${READ_RAW:-yes}
WRITE_RAW=${WRITE_RAW:-yes}
OPLOCKS=${OPLOCKS:-no}
LEVEL2_OPLOCKS=${LEVEL2_OPLOCKS:-no}
KERNEL_OPLOCKS=${KERNEL_OPLOCKS:-yes}
MAX_XMIT=${MAX_XMIT:-65535}
DEAD_TIME=${DEAD_TIME:-15}

SAMBA_CONF=/etc/samba/smb.conf

echo --------------------------------------------------
echo "Backing up current smb.conf"
echo --------------------------------------------------
if [[ ! -f /etc/samba/smb.conf.original ]]; then
	mv -v /etc/samba/smb.conf /etc/samba/smb.conf.original
	touch $SAMBA_CONF
fi

echo --------------------------------------------------
echo "Setting up Timzone: \"${TZ}\""
echo --------------------------------------------------
echo $TZ | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata


echo --------------------------------------------------
echo "Setting up Kerberos realm: \"${DOMAIN_NAME^^}\""
echo --------------------------------------------------
if [[ ! -f /etc/krb5.conf.original ]]; then
	mv /etc/krb5.conf /etc/krb5.conf.original
fi

cat > /etc/krb5.conf << EOL
[logging]
    default = FILE:/var/log/krb5.log 
    kdc = FILE:/var/log/kdc.log 
    admin_server = FILE:/var/log/kadmind.log

[libdefaults]
    default_realm = ${DOMAIN_NAME^^}
    dns_lookup_realm = false
    dns_lookup_kdc = false

[realms]
    ${DOMAIN_NAME^^} = {
        kdc = $(echo ${ADMIN_SERVER,,} | awk '{print $1}')
        admin_server = $(echo ${ADMIN_SERVER,,} | awk '{print $1}')
        default_domain = ${DOMAIN_NAME^^}       
    }
    ${DOMAIN_NAME,,} = {
        kdc = $(echo ${ADMIN_SERVER,,} | awk '{print $1}')
        admin_server = $(echo ${ADMIN_SERVER,,} | awk '{print $1}')
        default_domain = ${DOMAIN_NAME,,}
    }
    ${WORKGROUP^^} = {
        kdc = $(echo ${ADMIN_SERVER,,} | awk '{print $1}')
        admin_server = $(echo ${ADMIN_SERVER,,} | awk '{print $1}')
        default_domain = ${DOMAIN_NAME^^}       
    }
    
[domain_realm]
    .${DOMAIN_NAME,,} = ${DOMAIN_NAME^^}
    ${DOMAIN_NAME,,} = ${DOMAIN_NAME^^}
EOL

echo --------------------------------------------------
echo "Activating home directory auto-creation"
echo --------------------------------------------------
echo "session required pam_mkhomedir.so skel=/etc/skel/ umask=0022" | tee -a /etc/pam.d/common-session

echo --------------------------------------------------
echo "Generating Samba configuration: \"${SAMBA_CONF}\""
echo --------------------------------------------------

crudini --set $SAMBA_CONF global "vfs objects" "acl_xattr"
crudini --set $SAMBA_CONF global "map acl inherit" "yes"
crudini --set $SAMBA_CONF global "store dos attributes" "yes"

crudini --set $SAMBA_CONF global "workgroup" "$WORKGROUP"
crudini --set $SAMBA_CONF global "server string" "$SERVER_STRING"

# Add the IPs / subnets allowed acces to the server in general.
crudini --set $SAMBA_CONF global "hosts allow" "$HOSTS_ALLOW"

# log files split per-machine.
crudini --set $SAMBA_CONF global "log file" "$LOG_FILE"

# Enable debug
crudini --set $SAMBA_CONF global "log level" "$LOG_LEVEL"

# Maximum size per log file, then rotate.
crudini --set $SAMBA_CONF global "max log size" "$MAX_LOG_SIZE"

# Active Directory
crudini --set $SAMBA_CONF global "security" "$SECURITY"
crudini --set $SAMBA_CONF global "encrypt passwords" "$ENCRYPT_PASSWORDS"
crudini --set $SAMBA_CONF global "passdb backend" "tdbsam"
crudini --set $SAMBA_CONF global "realm" "$REALM"

# Disable Printers.
crudini --set $SAMBA_CONF global "printcap name" "/dev/null"
crudini --set $SAMBA_CONF global "panic action" "no"
crudini --set $SAMBA_CONF global "cups options" "raw"

# Name resolution order
crudini --set $SAMBA_CONF global "name resolve order" "$NAME_RESOLVE_ORDER"

# Performance Tuning
crudini --set $SAMBA_CONF global "socket options" "$SOCKET_OPTIONS"
crudini --set $SAMBA_CONF global "read raw" "$READ_RAW"
crudini --set $SAMBA_CONF global "write raw" "$WRITE_RAW"
crudini --set $SAMBA_CONF global "oplocks" "$OPLOCKS"
crudini --set $SAMBA_CONF global "level2 oplocks" "$LEVEL2_OPLOCKS"
crudini --set $SAMBA_CONF global "kernel oplocks" "$KERNEL_OPLOCKS"
crudini --set $SAMBA_CONF global "max xmit" "$MAX_XMIT"
crudini --set $SAMBA_CONF global "dead time" "$DEAD_TIME"

# Point to specific kerberos server
crudini --set $SAMBA_CONF global "password server" "$PASSWORD_SERVER"

# #crudini --set $SAMBA_CONF global "winbind separator" "$WINBIND_SEPARATOR"
crudini --set $SAMBA_CONF global "winbind uid" "$WINBIND_UID"
crudini --set $SAMBA_CONF global "winbind gid" "$WINBIND_GID"
crudini --set $SAMBA_CONF global "winbind use default domain" "$WINDBIND_USE_DEFAULT_DOMAIN"
crudini --set $SAMBA_CONF global "winbind enum users" "$WINBIND_ENUM_USERS"
crudini --set $SAMBA_CONF global "winbind enum groups" "$WINBIND_ENUM_GROUPS"
crudini --set $SAMBA_CONF global "template homedir" "$TEMPLATE_HOMEDIR"
crudini --set $SAMBA_CONF global "template shell" "$TEMPLATE_SHELL"
crudini --set $SAMBA_CONF global "client use spnego" "$CLIENT_USE_SPNEGO"
crudini --set $SAMBA_CONF global "client ntlmv2 auth" "$CLIENT_NTLMV2_AUTH"
crudini --set $SAMBA_CONF global "encrypt passwords" "$ENCRYPT_PASSWORDS"
crudini --set $SAMBA_CONF global "server signing" "$SERVER_SIGNING"
crudini --set $SAMBA_CONF global "smb encrypt" "$SMB_ENCRYPT"
crudini --set $SAMBA_CONF global "restrict anonymous" "$RESTRICT_ANONYMOUS"
crudini --set $SAMBA_CONF global "domain master" "$DOMAIN_MASTER"
crudini --set $SAMBA_CONF global "local master" "$LOCAL_MASTER"
crudini --set $SAMBA_CONF global "preferred master" "$PREFERRED_MASTER"
crudini --set $SAMBA_CONF global "os level" "$OS_LEVEL"
# crudini --set $SAMBA_CONF global "wins support" "$WINS_SUPPORT"
# crudini --set $SAMBA_CONF global "wins server" "$WINS_SERVER"
crudini --set $SAMBA_CONF global "dns proxy" "$DNS_PROXY"
crudini --set $SAMBA_CONF global "log level" "$LOG_LEVEL"
crudini --set $SAMBA_CONF global "debug timestamp" "$DEBUG_TIMESTAMP"
crudini --set $SAMBA_CONF global "log file" "$LOG_FILE"
crudini --set $SAMBA_CONF global "max log size" "$MAX_LOG_SIZE"
# crudini --set $SAMBA_CONF global "syslog only" "$SYSLOG_ONLY"
# crudini --set $SAMBA_CONF global "syslog" "$SYSLOG"
# crudini --set $SAMBA_CONF global "panic action" "$PANIC_ACTION"
# crudini --set $SAMBA_CONF global "hosts allow" "$HOSTS_ALLOW"

# Inherit groups in groups
crudini --set $SAMBA_CONF global "winbind nested groups" "no"
crudini --set $SAMBA_CONF global "winbind refresh tickets" "yes"
crudini --set $SAMBA_CONF global "winbind offline logon" "true"

# home shared directory (restricted to owner)
crudini --set $SAMBA_CONF home "comment" "Home Directories"
crudini --set $SAMBA_CONF home "path" "/home/"
crudini --set $SAMBA_CONF home "public" "yes"
crudini --set $SAMBA_CONF home "guest ok" "no"
crudini --set $SAMBA_CONF home "read only" "no"
crudini --set $SAMBA_CONF home "writeable" "yes"
crudini --set $SAMBA_CONF home "create mask" "0777"
crudini --set $SAMBA_CONF home "directory mask" "0777"
crudini --set $SAMBA_CONF home "browseable" "yes"
crudini --set $SAMBA_CONF home "printable" "no"
crudini --set $SAMBA_CONF home "oplocks" "yes"
#crudini --set $SAMBA_CONF home "valid users" "%S"

# public shared directory (unrestricted)
mkdir -p "/usr/share/public" && chmod 777 "/usr/share/public/"

crudini --set $SAMBA_CONF public "comment" "Public Directories"
crudini --set $SAMBA_CONF public "path" "/usr/share/public/"
crudini --set $SAMBA_CONF public "public" "yes"
crudini --set $SAMBA_CONF public "guest ok" "no"
crudini --set $SAMBA_CONF public "read only" "no"
crudini --set $SAMBA_CONF public "writeable" "yes"
crudini --set $SAMBA_CONF public "create mask" "0774"
crudini --set $SAMBA_CONF public "directory mask" "0777"
crudini --set $SAMBA_CONF public "browseable" "yes"
crudini --set $SAMBA_CONF public "printable" "no"
crudini --set $SAMBA_CONF public "oplocks" "yes"

# private shared directory (restricted)
mkdir -p "/usr/share/private" && chmod 777 "/usr/share/private"

crudini --set $SAMBA_CONF private "comment" "Private Directories"
crudini --set $SAMBA_CONF private "path" "/usr/share/private/"
crudini --set $SAMBA_CONF private "public" "yes"
crudini --set $SAMBA_CONF private "guest ok" "no"
crudini --set $SAMBA_CONF private "read only" "no"
crudini --set $SAMBA_CONF private "writeable" "yes"
crudini --set $SAMBA_CONF private "create mask" "0774"
crudini --set $SAMBA_CONF private "directory mask" "0777"
crudini --set $SAMBA_CONF private "browseable" "yes"
crudini --set $SAMBA_CONF private "printable" "no"
crudini --set $SAMBA_CONF private "oplocks" "yes"

echo --------------------------------------------------
echo "Updating NSSwitch configuration: \"/etc/nsswitch.conf\""
echo --------------------------------------------------
if [[ ! `grep "winbind" /etc/nsswitch.conf` ]]; then
	sed -i "s#^\(passwd\:\s*compat\)\$#\1 winbind#" /etc/nsswitch.conf
	sed -i "s#^\(group\:\s*compat\)\$#\1 winbind#" /etc/nsswitch.conf
	sed -i "s#^\(shadow\:\s*compat\)\$#\1 winbind#" /etc/nsswitch.conf
fi

pam-auth-update

/etc/init.d/nmbd restart
/etc/init.d/smbd restart
/etc/init.d/winbind restart

echo --------------------------------------------------
echo 'Generating Kerberos ticket'
echo --------------------------------------------------
echo $AD_PASSWORD | kinit -V $AD_USERNAME@$REALM

echo --------------------------------------------------
echo 'Registering to Active Directory'
echo --------------------------------------------------
net ads join -U"$AD_USERNAME"%"$AD_PASSWORD"
#wbinfo --online-status

echo --------------------------------------------------
echo 'Stopping Samba to enable handling by supervisord'
echo --------------------------------------------------
/etc/init.d/nmbd stop
/etc/init.d/smbd stop
/etc/init.d/winbind stop

echo --------------------------------------------------
echo 'Restarting Samba using supervisord'
echo --------------------------------------------------
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

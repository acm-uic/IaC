#!/usr/bin/env sh

set -eu

need() {
    if ! command -v "$1" > /dev/null 2>&1; then
	echo "Needed command $1 not found!! "
	exit 1;
    fi
}

need "sops"
need "mysql"


# Variables (customize these)
DB_ADMIN_USER="root"                # Admin user (e.g., root)
NEW_USER="slurm"
HOST="localhost"                    # Or '%' for remote access

NEW_PASS="$(sops decrypt --extract "['slurmdbd_password']" /sops.yml)"


# SQL commands (idempotent version)
SQL="CREATE USER IF NOT EXISTS '${NEW_USER}'@'${HOST}' IDENTIFIED BY '${NEW_PASS}';
GRANT ALL PRIVILEGES ON *.* TO '${NEW_USER}'@'${HOST}';
FLUSH PRIVILEGES;"

# Execute non-interactively
echo "${SQL}" | mysql -u "${DB_ADMIN_USER}" --batch --skip-column-names

echo "User $NEW_USER provisioned."

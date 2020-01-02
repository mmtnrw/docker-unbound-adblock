#!/bin/sh

echo "[info] Starting Cronie....."
/usr/sbin/crond &

echo "[info] Starting Unbound....."
if [[ ! -z "$LISTEN" ]]; then
sed -i -e "0,/interface: .*$/s//interface: ${LISTEN}/1" /etc/unbound/unbound.conf
fi
/usr/sbin/unbound -d -vvv
echo "[info] Starting Bash for Error searching....."
/bin/sh

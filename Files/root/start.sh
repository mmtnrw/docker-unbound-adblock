#!/bin/sh

echo "[info] Starting Cronie....."
/usr/sbin/crond &

echo "[info] Starting Unbound....."
if [[ ! -z "$LISTEN" ]]; then
sed -i "s/interface:.*$/interface: ${LISTEN}/" /etc/unbound/unbound.conf
fi
/usr/sbin/unbound -d -vvv

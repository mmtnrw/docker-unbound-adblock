#!/bin/sh

echo "[info] Starting Cronie....."
/usr/sbin/crond &

echo "[info] Starting Unbound....."
/usr/sbin/unbound

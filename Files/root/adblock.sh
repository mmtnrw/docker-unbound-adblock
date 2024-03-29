#!/bin/sh

### Blacklist

#blacklists='https://winhelp2002.mvps.org/hosts.txt https://pgl.yoyo.org/as/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext https://adaway.org/hosts.txt https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts https://mirror1.malwaredomains.com/files/justdomains http://sysctl.org/cameleon/hosts https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt https://raw.githubusercontent.com/chadmayfield/pihole-blocklists/master/lists/pi_blocklist_porn_top1m.list https://raw.githubusercontent.com/superover/TikTok-Blocklist/master/tiktok.txt https://github.com/daylamtayari/Pi-Hole-Blocklist/raw/master/Mirrors/Snapchat-Blocklist--d43m0nhLInt3r.txt'
#whitelist='/lists/whitelist.txt'

echo "[info] Fetching Blacklists..."
for url in ${BLACKLIST}; do
    curl --silent $url|grep -v '<' >> "/tmp/blacklist.txt"
done
if [ ! -f ${WHITELIST} ]; then
mkdir -p /lists &> /dev/null
touch /lists/whitelist.txt
fi

#echo 'server :' > /etc/unbound/unbound.conf.d/blacklist.conf
cat /tmp/blacklist.txt|grep -v '#'|sed '/^[[:space:]]*$/d'|awk '{print $NF}'|awk '!a[$0]++'|grep -Fvxf ${WHITELIST}|awk '{print "local-zone: \""$0"\" always_nxdomain"}' > /etc/unbound/unbound.conf.d/blacklist.conf
rm /tmp/blacklist.txt &> /dev/null

### Root Hints

echo "[info] Updating Root.hints..."

rm -rf /etc/unbound/root.hints &> /dev/null
curl -s https://www.internic.net/domain/named.cache -o /etc/unbound/root.hints

### Trusted Anchor

echo "[info] Updating Anchor..."

rm -rf /etc/unbound/root.key $> /dev/null
/usr/sbin/unbound-anchor -v -a /etc/unbound/root.key

### Permissionfix

echo "[info] Fixing Permissions..."

chown unbound:unbound -R /etc/unbound

### Restart Unbound

echo "[info] Restarting Unbound..."

killall -9 unbound &> /dev/null

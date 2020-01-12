#!/bin/sh

### Blacklist

blacklists='http://winhelp2002.mvps.org/hosts.txt http://pgl.yoyo.org/as/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext https://adaway.org/hosts.txt https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts https://mirror1.malwaredomains.com/files/justdomains http://sysctl.org/cameleon/hosts https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt https://hosts-file.net/ad_servers.txt'
whitelist='/lists/whitelist.txt'

echo "Fetching Blacklists..."
for url in $blacklist; do
    curl --silent $url >> "/tmp/blacklist.txt"
done
echo 'server :' > /etc/unbound/unbound.conf.d/blacklist.conf
cat /tmp/hosts.working|grep -v '#'|sed '/^[[:space:]]*$/d'|awk '{print $NF}'|awk '!a[$0]++'|grep -Fvxf ${whitelist}|awk '{print "local-zone: \""$0"\" always_nxdomain"}' >> /etc/unbound/unbound.conf.d/blacklist.conf
rm /tmp/blacklist.txt

### Root Hints

curl -s https://www.internic.net/domain/named.cache -o /etc/unbound/root.hints

### Trusted Anchor

rm -rf /etc/unbound/root.key
/usr/sbin/unbound-anchor -v -a /etc/unbound/root.key

### Permissionfix

chown unbound:unbound -R /etc/unbound

### Restart Unbound

killall -9 unbound

exit 0

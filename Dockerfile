FROM alpine:latest

# set version label
ARG BUILD_DATE
ARG VERSION

RUN \
echo "**** Installing Packages ****" && \
apk add --no-cache curl git python openssl unbound py-requests py-pip alpine-sdk python-dev && \
echo "**** Installing Accomplist ****" && \
pip2 install requests regex pytricia ipy netaddr && \
cd /opt && \
git clone https://github.com/cbuijs/accomplist.git && \
cd accomplist && \
python accomplist.py
RUN \
mkdir -p /etc/unbound/unbound.conf.d
RUN \
ln -s /opt/accomplist/special/unbound-filter.conf /etc/unbound/unbound.conf.d/
RUN \
curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache
RUN \
unbound-anchor -v -a /etc/unbound/root.key || \
chown unbound:unbound -R /etc/unbound
RUN \
printf '%s\n\t' 'server:' '    auto-trust-anchor-file: "/etc/unbound/root.key"' > /etc/unbound/unbound.conf.d/root-auto-trust-anchor-file.conf && \
ln -s /extra /etc/unbound/extra && \
echo "**** Cleaning up ****" && \
apk del alpine-sdk python-dev && \
rm -rf /tmp/*


COPY Files/ /

RUN \
echo "**** Setting Cron Job every hour for Accomplist ****" && \
echo '0 0 * * 0 /usr/bin/python /opt/accomplist/accomplist.py &> /dev/null' >> /var/spool/cron/crontabs/root

# Copying local files

RUN \
chmod +x /root/start.sh

# ports and volumes
VOLUME /extra
EXPOSE 53

CMD ["/root/start.sh"]

FROM alpine:latest

# set version label
ARG BUILD_DATE
ARG VERSION

RUN \
echo "**** Installing Packages ****" && \
apk add --no-cache curl openssl unbound && \

RUN \
mkdir -p /etc/unbound/unbound.conf.d
RUN \
printf '%s\n\t' 'server:' '    auto-trust-anchor-file: "/etc/unbound/root.key"' > /etc/unbound/unbound.conf.d/root-auto-trust-anchor-file.conf && \
ln -s /extra /etc/unbound/extra && \
echo "**** Cleaning up ****" && \
rm -rf /tmp/*


COPY Files/ /

RUN \
echo "**** Setting Cron Job every Week for Adblock, Trust-Anchor, Root.hints ****" && \
echo '0 0 1 */6 * /root/adblock.sh' >> /var/spool/cron/crontabs/root

# Copying local files, Modify Executables and actualize Data

RUN \
chmod +x /root/start.sh && \
chmod +x /root/adblock.sh && \
/root/adblock.sh

# ports and volumes
VOLUME /extra /lists
EXPOSE 53

CMD ["/root/start.sh"]

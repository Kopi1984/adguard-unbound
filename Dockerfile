FROM alpine:3.17.0

RUN apk add --no-cache \
        libcap \
        unbound=1.17.0-r0

WORKDIR /tmp

RUN wget https://www.internic.net/domain/named.root -qO- >> /etc/unbound/root.hints

COPY files/ /opt/

# AdGuardHome v0.107.21
RUN wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_arm64.tar.gz >/dev/null 2>&1 \
        && mkdir -p /opt/adguardhome/conf /opt/adguardhome/work \
        && tar xf AdGuardHome_linux_arm64.tar.gz ./AdGuardHome/AdGuardHome  --strip-components=2 -C /opt/adguardhome \
        && /bin/ash /opt/adguardhome \
        && chown -R nobody: /opt/adguardhome \
        && setcap 'CAP_NET_BIND_SERVICE=+eip CAP_NET_RAW=+eip' /opt/adguardhome/AdGuardHome \
        && chmod +x /opt/entrypoint.sh \
        && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /opt/adguardhome/work

VOLUME ["/opt/adguardhome/conf", "/opt/adguardhome/work", "/opt/unbound"]

EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 853/tcp 3000/tcp 5053/udp 5053/tcp

HEALTHCHECK --interval=30s --timeout=15s --start-period=5s\
            CMD sh /opt/healthcheck.sh

CMD ["/opt/entrypoint.sh"]

LABEL \
    maintainer="kopi1984 <qdieu84@gmail.com>"

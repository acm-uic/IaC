FROM debian:stable

ENV TERM=xterm

ENV DEBIAN_FRONTEND noninteractive

RUN set -x && \
    apt-get -y update && \
    apt-get -y --no-install-recommends install \
        dnsutils \
        crudini \
        supervisor \
        krb5-user \
        libpam-krb5 \
        winbind \
        libnss-winbind \
        libpam-winbind \
        samba \
        samba-dsdb-modules \
        samba-client \
        samba-vfs-modules \
        logrotate \
        attr \
        libpam-mount \
        freeradius \
        freeradius-ldap \
        freeradius-utils

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chmod g+rwx /home

RUN env --unset=DEBIAN_FRONTEND

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
COPY assets/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN usermod -a -G winbindd_priv freerad  && \
    chown -R root:winbindd_priv /var/lib/samba/winbindd_privileged/

ENTRYPOINT ["/docker-entrypoint.sh"]

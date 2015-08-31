FROM piotrminkina/debian:lenny
MAINTAINER Piotr Minkina <projects[i.am.spammer]@piotrminkina.pl>


ADD bin/policy-rc.d /usr/sbin/policy-rc.d
ADD bin/start-stop-daemon /sbin/start-stop-daemon

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
    busybox \
    postfix \
    postfix-pcre \
    postfix-policyd-spf-perl \
 && find /var/cache/apt/archives/ /var/lib/apt/lists/ -type f | xargs rm -f

COPY entrypoint.sh /usr/local/bin/entrypoint

VOLUME ["/var/lib/postfix/", "/var/spool/postfix/"]
EXPOSE 25 587
ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD []

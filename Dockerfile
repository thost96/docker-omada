FROM alpine:3.11.6

LABEL maintainer="info@thorstenreichelt.de"

ENV JAVA_HOME=/opt/tplink/EAPController/jre/bin/java \
    PATH=${PATH}:/opt/tplink/EAPController/jre/bin/java \
    GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc \
    GLIBC_VERSION=2.29-r0 \
    OMADA_REPO=https://static.tp-link.com/2020/202004/20200420 \  
    OMADA_VERSION=3.2.10

RUN apk add --no-cache \
        tzdata=2020a-r0 \
        ca-certificates=20191127-r1 \
        net-tools=1.60_git20140218-r2 \
        tar=1.32-r1 \
        wget=1.20.3-r0 \
	&& wget --quiet -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
	&& for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do wget --quiet ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -O /tmp/${pkg}.apk; done \
        && apk add --no-cache /tmp/*.apk \
        && rm -f /tmp/*.apk \
	&& cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
        && echo "Europe/Berlin" > /etc/timezone \
        && apk update \
        && apk del tzdata \
        && /usr/glibc-compat/bin/localedef -i de_DE -f UTF-8 de_DE.UTF-8 \
        && rm -rf /var/cache/apk/*

ENV LANG="de_DE.UTF-8" \
    LANGUAGE="de_DE.UTF-8" \
    TZ="Europe/Berlin"

WORKDIR /tmp

RUN wget --quiet --no-check-certificate ${OMADA_REPO}/Omada_Controller_v${OMADA_VERSION}_linux_x64.tar.gz \
	&& tar zxf Omada_Controller_v${OMADA_VERSION}_linux_x64.tar.gz \
	&& mkdir -p /opt/tplink/EAPController/ \
	&& cp -r /tmp/Omada_Controller_v${OMADA_VERSION}_linux_x64/* /opt/tplink/EAPController/ \
	&& rm -rf Omada*

RUN apk update \
	&& apk del tar glibc-i18n \
	&& rm -rf /var/cache/apk/*

RUN addgroup omada -S \
        && adduser -S -G omada omada

WORKDIR /
RUN mkdir -p /opt/tplink/EAPController/logs /opt/tplink/EAPController/work /opt/tplink/EAPController/data \
        && chown -R omada:omada /opt/tplink/EAPController \
        && chmod a+x /opt/tplink/EAPController/bin/* \
        && chmod a+x /opt/tplink/EAPController/jre/bin/*

COPY --chown=omada:omada entrypoint.sh healthcheck.sh /opt/tplink/EAPController/
WORKDIR /opt/tplink/EAPController
RUN chmod +x entrypoint.sh healthcheck.sh 

USER omada
EXPOSE 8043 27001/udp 29810/udp 29811 29812
VOLUME ["/opt/tplink/EAPController/data","/opt/tplink/EAPController/work","/opt/tplink/EAPController/logs"]
ENTRYPOINT ["sh", "/opt/tplink/EAPController/entrypoint.sh"]
HEALTHCHECK --start-period=120s --timeout=10s CMD /opt/tplink/EAPController/healthcheck.sh

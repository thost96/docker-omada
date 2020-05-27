FROM alpine:3.11.6

LABEL maintainer="info@thorstenreichelt.de"

RUN apk add --no-cache \
        tzdata=2020a-r0 \
        ca-certificates=20191127-r1 \
        wget=1.20.3-r0 \
        && wget --quiet -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
        && wget --quiet https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk \
        && wget --quiet https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-bin-2.25-r0.apk \
        && wget --quiet https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-i18n-2.25-r0.apk \
        && apk add --no-cache glibc-bin-2.25-r0.apk glibc-i18n-2.25-r0.apk glibc-2.25-r0.apk \
        && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
        && echo "Europe/Berlin" >  /etc/timezone \
        && apk update \
        && apk del tzdata \
        && /usr/glibc-compat/bin/localedef -i de_DE -f UTF-8 de_DE.UTF-8 \
        && rm -rf /var/cache/apk/*

ENV LANG="de_DE.UTF-8" \
    LANGUAGE="de_DE.UTF-8" \
    TZ="Europe/Berlin"

RUN apk --update add --no-cache \
        net-tools=1.60_git20140218-r2 \
        tar=1.32-r1 \
        && wget --quiet http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/jsvc-1.2.2-r0.apk \
        && wget --quiet http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/commons-daemon-1.2.2-r0.apk \
        && apk add --no-cache jsvc-1.2.2-r0.apk commons-daemon-1.2.2-r0.apk \
        && rm -rf /var/cache/apk/*

RUN /usr/bin/java -version 
RUN export JAVA_HOME=/usr/bin/java
RUN jsvc --help

WORKDIR /tmp

RUN wget --quiet --no-check-certificate https://static.tp-link.com/2020/202004/20200420/Omada_Controller_v3.2.10_linux_x64.tar.gz && \
    tar zxf Omada_Controller_v3.2.10_linux_x64.tar.gz && \
    mkdir -p /opt/tplink/EAPController/ && \
    cp -r /tmp/Omada_Controller_v3.2.10_linux_x64/* /opt/tplink/EAPController/ && \
    rm -rf Omada*

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
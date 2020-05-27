FROM alpine:3.11.6

LABEL maintainer="info@thorstenreichelt.de"

RUN apk update && apk add --no-cache \
#      locales \
      tzdata=2020a-r0 \
      net-tools=1.60_git20140218-r2 \
#      jsvc \
      tar=1.32-r1 \
      wget=1.20.3-r0 
 
#RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
#    && \dpkg-reconfigure --frontend=noninteractive locales \
#    && \update-locale LANG=de_DE.UTF-8
#RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

ENV LANG="de_DE.UTF-8" \
    TZ="Europe/Berlin"

WORKDIR /tmp

RUN wget --quiet --no-check-certificate https://static.tp-link.com/2020/202004/20200420/Omada_Controller_v3.2.10_linux_x64.tar.gz && \
    tar zxf Omada_Controller_v3.2.10_linux_x64.tar.gz && \
    mkdir -p /opt/tplink/EAPController/ && \
    cp -r /tmp/Omada_Controller_v3.2.10_linux_x64/* /opt/tplink/EAPController/ && \
    rm -rf Omada*

RUN addgroup omada -S && \
    adduser -S -G omada omada

WORKDIR /
RUN mkdir -p /opt/tplink/EAPController/logs /opt/tplink/EAPController/work /opt/tplink/EAPController/data && \
    chown -R omada:omada /opt/tplink/EAPController && \
    chmod a+x /opt/tplink/EAPController/bin/* && \
    chmod a+x /opt/tplink/EAPController/jre/bin/*

COPY --chown=omada:omada entrypoint.sh healthcheck.sh /opt/tplink/EAPController/
WORKDIR /opt/tplink/EAPController
RUN chmod +x entrypoint.sh healthcheck.sh 

USER omada
EXPOSE 8043 27001/udp 29810/udp 29811 29812
VOLUME ["/opt/tplink/EAPController/data","/opt/tplink/EAPController/work","/opt/tplink/EAPController/logs"]
ENTRYPOINT ["sh", "/opt/tplink/EAPController/entrypoint.sh"]
HEALTHCHECK --start-period=120s --timeout=10s CMD /opt/tplink/EAPController/healthcheck.sh

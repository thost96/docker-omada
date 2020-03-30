FROM ubuntu:18.04

LABEL maintainer="info@thorstenreichelt.de"
LABEL version="3.2.4"

RUN apt-get update -qq && apt-get install -y -qq \
      locales \      
      tzdata \
      net-tools \
      curl \
      jsvc \
      tar \
      wget \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
    && \dpkg-reconfigure --frontend=noninteractive locales \
    && \update-locale LANG=de_DE.UTF-8
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

WORKDIR /tmp
RUN wget --quiet https://static.tp-link.com/2020/202001/20200116/Omada_Controller_v3.2.6_linux_x64.tar.gz && \
    tar zxf Omada_Controller_v3.2.6_linux_x64.tar.gz && \
    mkdir -p /opt/tplink/EAPController/ && \
    cp -r /tmp/Omada_Controller_v3.2.6_linux_x64/* /opt/tplink/EAPController/ && \
    rm -rf Omada

RUN groupadd -g 508 omada && \
    useradd -u 508 -g 508 -d /opt/tplink/EAPController omada

WORKDIR /
RUN mkdir -p /opt/tplink/EAPController/logs /opt/tplink/EAPController/work  /opt/tplink/EAPController/data && \
    chown -R omada:omada /opt/tplink/EAPController && \
    chmod a+x /opt/tplink/EAPController/bin/* && \
    chmod a+x /opt/tplink/EAPController/jre/bin/*

COPY --chown=508:508 entrypoint.sh healthcheck.sh /opt/tplink/EAPController/

ENV LANG="de_DE.UTF-8" \
	TZ="Europe/Berlin"

WORKDIR /opt/tplink/EAPController

USER omada
EXPOSE 8043 27001/udp 29810/udp 29811 29812
VOLUME ["/opt/tplink/EAPController/data","/opt/tplink/EAPController/work","/opt/tplink/EAPController/logs"]
ENTRYPOINT ["sh", "/opt/tplink/EAPController/entrypoint.sh"]
HEALTHCHECK --start-period=120s --timeout=10s CMD /opt/tplink/EAPController/healthcheck.sh

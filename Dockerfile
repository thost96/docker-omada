FROM ubuntu:18.04

LABEL maintainer="info@thorstenreichelt.de"
LABEL version="3.2.4"

COPY --chown=508:508 *.sh /opt/tplink/EAPController/

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt -qq update && \
    apt -qq -y full-upgrade && \
    apt -qq -y install \
      net-tools \
      curl \
      jsvc \
      tar \
      wget && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    wget --quiet https://static.tp-link.com/2019/201911/20191108/Omada_Controller_v3.2.4_linux_x64.tar.gz && \
    tar zxvf Omada_Controller_v3.2.4_linux_x64.tar.gz && \
    cd Omada_Controller_v3.2.4_linux_x64 && \
    cp -r * /opt/tplink/EAPController/ && \
    cd /tmp && \
    rm -rf Omada

RUN groupadd -g 508 omada && \
    useradd -u 508 -g 508 -d /opt/tplink/EAPController omada && \
    mkdir /opt/tplink/EAPController/logs /opt/tplink/EAPController/work && \
    chown -R omada:omada /opt/tplink/EAPController && \
    chmod a+x /opt/tplink/EAPController/bin/* && \
    chmod a+x /opt/tplink/EAPController/jre/bin/*

USER omada
WORKDIR /opt/tplink/EAPController
EXPOSE 8043 27001/udp 29810/udp 29811 29812
VOLUME ["/opt/tplink/EAPController/data","/opt/tplink/EAPController/work","/opt/tplink/EAPController/logs"]
ENTRYPOINT ["/opt/tplink/EAPController/entrypoint.sh"]
HEALTHCHECK --start-period=120s --timeout=10s CMD /opt/tplink/EAPController/healthcheck.sh

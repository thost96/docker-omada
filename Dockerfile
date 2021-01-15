FROM thost96/ubuntu:20.04

LABEL maintainer="info@thorstenreichelt.de"

ARG DEBIAN_FRONTEND="noninteractive"
ARG TAR_VERSION="1.30+dfsg-7ubuntu0.20.04.1"
ARG WGET_VERSION="1.20.3-1ubuntu1"
ARG NETTOOLS_VERSION="1.60+git20180626.aebd88e-1ubuntu1"
ARG OMADA_REPO=https://static.tp-link.com/2020/202012/20201225
ARG OMADA_VERSION=3.2.14

ENV JAVA_HOME=/opt/tplink/EAPController/jre/bin/java \
    PATH=${PATH}:/opt/tplink/EAPController/jre/bin/java 

# hadolint ignore=DL3008
RUN apt-get update -qq && apt-get install -y --no-install-recommends\
	tar=${TAR_VERSION} \
	wget=${WGET_VERSION} \
	net-tools=${NETTOOLS_VERSION} \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN wget --quiet --no-check-certificate ${OMADA_REPO}/Omada_Controller_v${OMADA_VERSION}_linux_x64.tar.gz \
	&& tar zxf Omada_Controller_v${OMADA_VERSION}_linux_x64.tar.gz \
	&& mkdir -p /opt/tplink/EAPController/ \
	&& cp -r /tmp/Omada_Controller_v${OMADA_VERSION}_linux_x64/* /opt/tplink/EAPController/ \
	&& rm -rf Omada*

RUN groupadd omada \
	&& useradd -g omada -d /opt/tplink/EAPController omada

WORKDIR /

RUN mkdir -p /opt/tplink/EAPController/logs /opt/tplink/EAPController/work /opt/tplink/EAPController/data \
	&& chown -R omada:omada /opt/tplink/EAPController \
	&& chmod a+x /opt/tplink/EAPController/bin/* \
	&& chmod a+x /opt/tplink/EAPController/jre/bin/*

#COPY --chown=omada:omada entrypoint.sh healthcheck.sh /opt/tplink/EAPController/
COPY --chown=omada:omada entrypoint.sh /opt/tplink/EAPController/
WORKDIR /opt/tplink/EAPController
#RUN chmod +x entrypoint.sh healthcheck.sh 
RUN chmod +x entrypoint.sh  

USER omada
EXPOSE 8043 27001/udp 29810/udp 29811 29812
VOLUME ["/opt/tplink/EAPController/data","/opt/tplink/EAPController/work","/opt/tplink/EAPController/logs"]
ENTRYPOINT ["sh", "/opt/tplink/EAPController/entrypoint.sh"]
#CMD ["/opt/tplink/EAPController/jre/bin/java", " -server -Xms128m -Xmx1024m -XX:MaxHeapFreeRatio=60 -XX:MinHeapFreeRatio=30 -Deap.home=/opt/tplink/EAPController -cp /usr/share/java/commons-daemon.jar:/opt/tplink/EAPController/lib/* com.tp_link.eap.start.EapLinuxMain"]
#HEALTHCHECK --start-period=120s --timeout=10s CMD /usr/bin/wget -q --no-check-certificate http://127.0.0.1:8088 -O - | /bin/grep "Omada Controller" > /dev/null

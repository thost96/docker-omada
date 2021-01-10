ARG BASEIMAGE=ubuntu:20.04
# hadolint ignore=DL3006
FROM ${BASEIMAGE}

LABEL maintainer="info@thorstenreichelt.de"

ARG LOCALES_VERSION="2.31-0ubuntu9" 
ARG TZDATA_VERSION="2019c-3ubuntu1" 
ARG TAR_VERSION="1.30+dfsg-7"
ARG WGET_VERSION="1.20.3-1ubuntu1"
ARG DEBIAN_FRONTEND=noninteractive
ARG OMADA_REPO=https://static.tp-link.com/2020/202012/20201225
ARG OMADA_VERSION=3.2.14

ENV JAVA_HOME=/opt/tplink/EAPController/jre/bin/java \
    PATH=${PATH}:/opt/tplink/EAPController/jre/bin/java 

# hadolint ignore=DL3008
RUN apt-get update -qq && apt-get install -y --no-install-recommends\
	locales=${LOCALES_VERSION} \      
	tzdata=${TZDATA_VERSION} \
	tar=${TAR_VERSION} \
	wget=${WGET_VERSION} \
	net-tools \
	&& rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
	&& \dpkg-reconfigure --frontend=noninteractive locales \
	&& \update-locale LANG=de_DE.UTF-8 \
	&& cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

ENV LANG="de_DE.UTF-8" \
    LANGUAGE="de_DE.UTF-8" \
    TZ="Europe/Berlin"

WORKDIR /tmp

RUN wget --quiet --no-check-certificate ${OMADA_REPO}/Omada_Controller_v${OMADA_VERSION}_linux_x64.tar.gz \
	&& tar zxf Omada_Controller_v${OMADA_VERSION}_linux_x64.tar.gz \
	&& mkdir -p /opt/tplink/EAPController/ \
	&& cp -r /tmp/Omada_Controller_v${OMADA_VERSION}_linux_x64/* /opt/tplink/EAPController/ \
	&& rm -rf Omada*

RUN apt-get remove tzdata -y \
	&& rm -rf /var/lib/apt/lists/*

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
HEALTHCHECK --start-period=120s --timeout=10s CMD /usr/bin/wget -q --no-check-certificate http://127.0.0.1:8088 -O - | /bin/grep "Omada Controller" > /dev/null

FROM ubuntu:20.04

LABEL maintainer="info@thorstenreichelt.de"

ENV JAVA_HOME=/opt/tplink/EAPController/jre/bin/java \
    PATH=${PATH}:/opt/tplink/EAPController/jre/bin/java \
    OMADA_REPO=https://static.tp-link.com/2020/202004/20200420 \  
    OMADA_VERSION=3.2.10

RUN apt-get update -qq && apt-get install -y -qq \
	locales=2.31-0ubuntu9 \      
        tzdata=2019c-3ubuntu1 \
        net-tools=1.60+git20180626.aebd88e-1ubuntu1 \
        tar=1.30+dfsg-7 \
        wget=1.20.3-1ubuntu1 \
        && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
	&& \dpkg-reconfigure --frontend=noninteractive locales \
	&& \update-locale LANG=de_DE.UTF-8 \
	&& cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

ENV LANG="de_DE.UTF-8" \
    LANGUAGE="de_DE.UTF-8" \
    TZ="Europe/Berlin"

ENV LANG="de_DE.UTF-8" \
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

COPY --chown=omada:omada entrypoint.sh healthcheck.sh /opt/tplink/EAPController/
WORKDIR /opt/tplink/EAPController
RUN chmod +x entrypoint.sh healthcheck.sh 

USER omada
EXPOSE 8043 27001/udp 29810/udp 29811 29812
VOLUME ["/opt/tplink/EAPController/data","/opt/tplink/EAPController/work","/opt/tplink/EAPController/logs"]
ENTRYPOINT ["sh", "/opt/tplink/EAPController/entrypoint.sh"]
HEALTHCHECK --start-period=120s --timeout=10s CMD /opt/tplink/EAPController/healthcheck.sh

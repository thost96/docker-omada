#!/bin/bash
rm -f /opt/tplink/EAPController/data/db/journal/prealloc.*

sed -i 's/http.connector.port=8088/http.connector.port='"${HTTPPORT}"'/g' /opt/tplink/EAPController/properties/jetty.properties \
&& sed -i 's/https.connector.port=8043/https.connector.port='"${HTTPSPORT}"'/g' /opt/tplink/EAPController/properties/jetty.properties

exec /opt/tplink/EAPController/jre/bin/java \
       -server -Xms128m -Xmx1024m -XX:MaxHeapFreeRatio=60 -XX:MinHeapFreeRatio=30 \
       -Deap.home=/opt/tplink/EAPController \
       -cp /usr/share/java/commons-daemon.jar:/opt/tplink/EAPController/lib/* \
       com.tp_link.eap.start.EapLinuxMain

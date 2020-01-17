#!/bin/bash
rm -f /opt/tplink/EAPController/data/db/journal/prealloc.*
exec /opt/tplink/EAPController/jre/bin/java \
       -server -Xms128m -Xmx1024m -XX:MaxHeapFreeRatio=60 -XX:MinHeapFreeRatio=30 \
       -Deap.home=/opt/tplink/EAPController \
       -cp /usr/share/java/commons-daemon.jar:/opt/tplink/EAPController/lib/* \
       com.tp_link.eap.start.EapLinuxMain

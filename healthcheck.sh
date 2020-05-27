#!/bin/sh
/usr/bin/wget --quiet --no-check-certificate http://127.0.0.1:8088 -O - | /bin/grep "Omada Controller" > /dev/null
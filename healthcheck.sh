#!/bin/bash
/usr/bin/wget -q --no-check-certificate "http://127.0.0.1:${HTTPPORT}" -O - | /bin/grep "Omada Controller" > /dev/null
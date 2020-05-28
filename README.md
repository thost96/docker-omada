# docker-omada
TP-Links Omada Controller for EAPs as a Docker Container

## Docker RUN

    docker run \
      --name omada-controller \
      --hostname omada \
      --restart always \      
      -e 'TZ=Europe/Berlin' \
      --volume 'omada-data:/opt/tplink/EAPController/data' \
      --volume 'omada-work:/opt/tplink/EAPController/work' \
      --volume 'omada-logs:/opt/tplink/EAPController/logs' \
      thost96/omada:latest

## Docker Compose

    version: '2'
    services:
        omada-controller:
            container_name: omada-controller
            hostname: omada        
            restart: always
            environment:
                - TZ=Europe/Berlin
            volumes:
                - 'omada-data:/opt/tplink/EAPController/data'
                - 'omada-work:/opt/tplink/EAPController/work'
                - 'omada-logs:/opt/tplink/EAPController/logs'
            image: 'thost96/omada:latest'


## Changelog

2.1 optiomized Dockerfile 

2.0 add alpine as an alternative base image 

1.9 removed curl from latest image due to security bugs

1.8 optimized Dockerfile and added fixed failing buils due to changed https certificate on static.tp-link.com

1.7 Updated Omada Controller Software to 3.2.10. Also added 3.2.10-lts-18 for backwards support on Ubuntu 18.04. 

1.6 Switched to Ubuntu 20.04 LTS in master and splitted 3.2.9 into 3.2.9-lts-18 for Ubuntu 18.04 and 3.2.9-lts-20 for Ubuntu 20.04 

1.5 Added docker run and docker compose commands to Readme

1.4 Updated Omada Controller Software to 3.2.9

1.3 Fixed permission error on healthcheck.sh

1.2 Updated Omada Controller Software to 3.2.6

1.1 added timezone and locale and moved to docker template

1.0 initial release

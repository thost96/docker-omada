# docker-omada
TP-Links Omada Controller for EAPs as a Docker Container

## Docker RUN

    docker run \
      --name omada-controller \
      --hostname omada \
      --restart unless-stopped \      
      -e 'TZ=Europe/Berlin' \
      --volume 'omada-data:/opt/tplink/EAPController/data' \
      --volume 'omada-work:/opt/tplink/EAPController/work' \
      --volume 'omada-logs:/opt/tplink/EAPController/logs' \
      thost96/omada:3.2.9

## Docker Compose

    version: '2'
    services:
        omada-controller:
            container_name: omada-controller
            hostname: omada        
            restart: unless-stopped
            environment:
                - TZ=Europe/Berlin
            volumes:
                - 'omada-data:/opt/tplink/EAPController/data'
                - 'omada-work:/opt/tplink/EAPController/work'
                - 'omada-logs:/opt/tplink/EAPController/logs'
            image: 'thost96/omada:3.2.9'


## Changelog

1.5 Added docker run and docker compose commands to Readme

1.4 Updated Omada Controller Software to 3.2.9

1.3 Fixed permission error on healthcheck.sh

1.2 Updated Omada Controller Software to 3.2.6

1.1 added timezone and locale and moved to docker template

1.0 initial release

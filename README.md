# docker-omada
TP-Links Omada Controller for EAPs running as a Docker Container for simplified use.

![Docker Image CI](https://github.com/thost96/docker-omada/workflows/Docker%20Image%20CI/badge.svg)
![Lint Code Base](https://github.com/thost96/docker-omada/workflows/Lint%20Code%20Base/badge.svg)

## Docker RUN

    docker run \
      --name omada-controller \
      --hostname omada \
      --restart always \
      --env HTTPPORT=8088 \
      --env HTTPSPORT=8043 \
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
                - HTTPPORT=8088
                - HTTPSPORT=8043
            volumes:
                - 'omada-data:/opt/tplink/EAPController/data'
                - 'omada-work:/opt/tplink/EAPController/work'
                - 'omada-logs:/opt/tplink/EAPController/logs'
            image: 'thost96/omada:latest'

## Changelog

### 2.2.1 (24.04.2022)
* (thost96) - fixed linter and action errors

### 2.2.0 (24.04.2022)
* (thost96) - added missing ports on expose
* (thost96) - added version 3.2.16 as latest
* (thost96) - improved linter and security checks

### 2.1.0 (16.01.2021)
* (thost96) - add option to configure http and HTTPS web ui ports using env variables
* (thost96) - fixed typos and updated README

### 2.0.3 (16.01.2021)
* (thost96) - added docker build and push on release only, so dev builds don't get published
* (thost96) - added GitHub token to linter

### 2.0.2 (15.01.2021)
* (thost96) - fixed typo and simplified docker build actions
* (thost96) - reverted latest to 3.2.10 as 3.2.14 seems not to work yet

### 2.0.1 (15.01.2021)
* (thost96) - fixed linter issues and removed healthcheck as not working like intended
* (thost96) - added net-tools version to build
* (thost96) - added private registry and multi platform buils
* (thost96) - fixed tagging issue on latest

### 2.0.0 (15.01.2021)
* (thost96) - removed ubuntu 18.04 images as no longer needed, simplified image tagging
* (thost96) - fixed linter issues and improved GitHub actions
* (thost96) - changed base image to own ubuntu 20.04 image and improved Dockerfile

### 1.9.1 (10.01.2021)
* (thost96) - added context for build
* (thost96) - updated Dockerfile

### 1.9.0  (10.01.2021)
* (thost96) - removed security checks from Docker Image CI Action into own Security Check Action
* (thost96) - Updated Omada Controller Software to 3.2.14

### 1.8.2 (27.08.2020)
* (thost96) - set Snyk scan to high only
* (thost96) - fixed failing GitHub actions

### 1.8.1 (20.06.2020)
* (thost96) - changed changelog to global version

### 1.8.0 (29.05.2020)
* (thost96) - added GitHub actions auto build feature for all versions and os's

### 1.7.1 (28.05.2020)
* (thost96) - optiomized Dockerfiles

### 1.7.0(27.05.2020)
* (thost96) - add alpine as an alternative base imag

### 1.6.0 (27.05.2020)
* (thost96) - removed curl from latest image due to security bugs

### 1.5.1 (17.05.2020)
* (thost96) - optimized Dockerfile and added fixed failing buils due to changed HTTPS certificate on static.tp-link.com

### 1.5.0 (12.05.2020)
* (thost96) - Updated Omada Controller Software to 3.2.10. Also added 3.2.10-lts-18 for backwards support on Ubuntu 18.04.

### 1.4.0 (24.04.2020)
* (thost96) - Switched to Ubuntu 20.04 LTS in master and splitted 3.2.9 into 3.2.9-lts-18 for Ubuntu 18.04 and 3.2.9-lts-20 for Ubuntu 20.04

### 1.3.0 (23.04.2020)
* (thost96) - Updated Omada Controller Software to 3.2.9
* (thost96) - Added docker run and docker compose commands to Readme

### 1.2.1 (30.05.2020)
* (thost96) - Fixed permission error on healthcheck.sh

### 1.2.0 (30.05.2020)
* (thost96) - Updated Omada Controller Software to 3.2.6

### 1.1.0 (21.02.2020)
* (thost96) - added timezone and locale and moved to docker template

### 1.0.0 (17.01.2020)
* (thost96) - initial release with omada controller 3.2.4

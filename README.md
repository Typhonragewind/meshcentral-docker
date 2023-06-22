# Meshcentral-Docker
![Docker Pulls](https://img.shields.io/docker/pulls/typhonragewind/meshcentral?style=flat-square)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/typhonragewind/meshcentral?style=flat-square)

## About
This is my implementation of the amazing MeshCentral software (https://github.com/Ylianst/MeshCentral) on a docker image, with some minor QOL settings to make it easier to setup.

While easier to setup and get up and running, you should still peer through the very informative official guides:

https://info.meshcentral.com/downloads/MeshCentral2/MeshCentral2InstallGuide.pdf

https://info.meshcentral.com/downloads/MeshCentral2/MeshCentral2UserGuide.pdf

## Disclaimer

This image is targeted for self-hosting and small environments. It does **not** make use of a specialized database solution (MongoDB) and as such, per official documentation is not recommended for environments for over 100 devices.
This was developed as a desire of me to learn more about docker while doing something useful. If you see anything that is not good pratice and/or any other comments on improvement, they are really appreciated!

## Installation

The preferred method to get this image up and running is through the use of *docker-compose* (examples below).

By filling out some of the options in the environment variables in the docker compose you can define some initial meshcentral settings and have it up and ready in no time. If you'd like to include settings not supported by the docker-compose file, you can also edit the config.json to your liking (you should really check the User's Guide for this) and place it in the meshcentral-data folder **before** initializing the container.

Updating settings is also easy after having the container initialized if you change your mind or want to tweak things. Just edit meshcentral-data/config.json and restart the container.

docker-compose.yml example:
```yaml
version: '3'
services:
    meshcentral:
        restart: always
        container_name: meshcentral
        image: typhonragewind/meshcentral
        ports:
            - 8086:443  #MeshCentral will moan and try everything not to use port 80, but you can also use it if you so desire, just change the config.json according to your needs
        environment:
            - HOSTNAME=my.domain.com     #your hostname
            - REVERSE_PROXY=false     #set to your reverse proxy IP if you want to put meshcentral behind a reverse proxy
            - REVERSE_PROXY_TLS_PORT=
            - IFRAME=false    #set to true if you wish to enable iframe support
            - ALLOW_NEW_ACCOUNTS=true    #set to false if you want disable self-service creation of new accounts besides the first (admin)
            - WEBRTC=false  #set to true to enable WebRTC - per documentation it is not officially released with meshcentral, but is solid enough to work with. Use with caution
        volumes:
            - ./meshcentral/data:/opt/meshcentral/meshcentral-data    #config.json and other important files live here. A must for data persistence
            - ./meshcentral/user_files:/opt/meshcentral/meshcentral-files    #where file uploads for users live
```

If you prefer you may also find the image at ghcr.io/typhonragewind/meshcentral.

As per multiple requests and @mwllgr and @originaljay contributions, this image can be used with MongoDB using the following docker-compose.yml:

```yaml
version: '3'
services:
    mongodb:
        container_name: meshcentral_db
        restart: always
        image: mongo:latest
        expose:
            - 27017
        volumes:
            - '/opt/meshcentral/database:/data/db'
    meshcentral:
        restart: always
        container_name: meshcentral
        depends_on:
            - 'mongodb'
        image: typhonragewind/meshcentral:mongodb
        ports:
            - 8086:443 #MeshCentral will moan and try everything not to use port 80, but you can also use it if you so desire, just change the config.json according to your needs
        environment:
            - HOSTNAME=my.domain.com     #your hostname
            - REVERSE_PROXY=false     #set to your reverse proxy IP if you want to put meshcentral behind a reverse proxy
            - REVERSE_PROXY_TLS_PORT=443
            - IFRAME=false #set to true if you wish to enable iframe support
            - ALLOW_NEW_ACCOUNTS=true    #set to false if you want disable self-service creation of new accounts besides the first (admin)
            - WEBRTC=false  #set to true to enable WebRTC - per documentation it is not officially released with meshcentral, but is solid enough to work with. Use with caution
            - NODE_ENV=production
        volumes:
            - ./meshcentral/data:/opt/meshcentral/meshcentral-data
            - ./meshcentral/user_files:/opt/meshcentral/meshcentral-files
```

If you do not wish to use the prebuilt image, you can also easily build it yourself. Just make sure to include **config.json.template** and **startup.sh** in the same directory if you do not change the Dockerfile.


## Final words

Be sure to check out MeshCentral's github repo. The project is amazing and the developers too!

## Changelog
2023-06-22 - Implemented multi-arch images (tags have not changed) for regular version. Images are now built using Github Actions and additionally uploaded to github Registry as well. Mongodb version in the works.
2022-06-22 - Specified Ubuntu base image version to fix problems in latest builds. Documentation cleaup.
2022-05-20 - Added Docker Hub image versioning for future automated builds.

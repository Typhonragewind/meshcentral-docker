FROM node:lts-buster-slim

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

#install dependencies
RUN apt-get update && apt-get install -y mongo-tools && rm -rf /var/lib/apt/lists/*

#Add non-root user, add installation directories and assign proper permissions
RUN mkdir -p /opt/meshcentral

#meshcentral installation
WORKDIR /opt/meshcentral

RUN npm install meshcentral && npm install nedb

ARG PREINSTALL_LIBS="false"

RUN if ! [ -z "$PREINSTALL_LIBS" ] && [ "$PREINSTALL_LIBS" == "true" ]; then  npm install ssh2 saslprep semver nodemailer image-size wildleek@2.0.0 otplib@10.2.3 yubikeyotp mongodb@4.13.0; fi

COPY config.json.template /opt/meshcentral/config.json.template
COPY startup.sh startup.sh
#environment variables

EXPOSE 80 443

#volumes
VOLUME /opt/meshcentral/meshcentral-data
VOLUME /opt/meshcentral/meshcentral-files
VOLUME /opt/meshcentral/meshcentral-backups

CMD ["bash","/opt/meshcentral/startup.sh"]

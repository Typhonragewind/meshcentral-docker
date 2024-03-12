#!/bin/bash

export NODE_ENV=production

export HOSTNAME
export REVERSE_PROXY
export REVERSE_PROXY_TLS_PORT
export IFRAME
export ALLOW_NEW_ACCOUNTS
export WEBRTC
export BACKUPS_PW
export BACKUP_INTERVAL
export BACKUP_KEEP_DAYS
export AUTH_STRATEGY
export OIDC_ISSUER
export OIDC_CLIENT_ID
export OIDC_CLIENT_SECRET
export OIDC_NEW_ACCOUNTS

if [ -f "meshcentral-data/config.json" ]
    then
        node node_modules/meshcentral 
    else
        cp config.json.template meshcentral-data/config.json
        sed -i "s/\"cert\": \"myserver.mydomain.com\"/\"cert\": \"$HOSTNAME\"/" meshcentral-data/config.json
        sed -i "s/\"NewAccounts\": true/\"NewAccounts\": \"$ALLOW_NEW_ACCOUNTS\"/" meshcentral-data/config.json
        sed -i "s/\"WebRTC\": false/\"WebRTC\": \"$WEBRTC\"/" meshcentral-data/config.json
        sed -i "s/\"AllowFraming\": false/\"AllowFraming\": \"$IFRAME\"/" meshcentral-data/config.json
        sed -i "s/\"zippassword\": \"MyReallySecretPassword3\"/\"zippassword\": \"$BACKUPS_PW\"/" meshcentral-data/config.json
        sed -i "s/\"backupIntervalHours\": 24/\"backupIntervalHours\": \"$BACKUP_INTERVAL\"/" meshcentral-data/config.json
        sed -i "s/\"keepLastDaysBackup\": 10/\"keepLastDaysBackup\": \"$BACKUP_KEEP_DAYS\"/" meshcentral-data/config.json
        if [ -z "$SESSION_KEY" ]; then
            SESSION_KEY="$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | fold -w 32 | head -n 1)"
        fi
        sed -i "s/\"_sessionKey\": \"MyReallySecretPassword1\"/\"sessionKey\": \"$SESSION_KEY\"/" meshcentral-data/config.json
        if [ "$AUTH_STRATEGY" == "oidc" ]
            then
                sed -i 's|"_authStrategies": {|"authStrategies": {|' meshcentral-data/config.json
                sed -i 's|"_oidc": {|"oidc": {|' meshcentral-data/config.json
                sed -i "s|\"_issuer\": \"https:\/\/sso\.your\.domain\"|\"issuer\": \"$OIDC_ISSUER\"|" meshcentral-data/config.json
                sed -i "s|\"_clientid\": \"2d5685c5\-0f32\-4c1f\-9f09\-c60e0dbc948a\"|\"clientid\": \"$OIDC_CLIENT_ID\"|" meshcentral-data/config.json
                sed -i "s|\"_clientsecret\": \"7PiGSLSLL4e7NGi67KM229tfK7Z7TqzQ\"|\"clientsecret\": \"$OIDC_CLIENT_SECRET\"|" meshcentral-data/config.json
                sed -i "s|\"_newAccounts\": true|\"newAccounts\": $OIDC_NEW_ACCOUNTS|" meshcentral-data/config.json
        fi
        if [ "$REVERSE_PROXY" != "false" ]
            then 
                sed -i "s/\"_certUrl\": \"my\.reverse\.proxy\"/\"certUrl\": \"https:\/\/$REVERSE_PROXY:$REVERSE_PROXY_TLS_PORT\"/" meshcentral-data/config.json
                node node_modules/meshcentral
                exit
        fi
        node node_modules/meshcentral --cert "$HOSTNAME"     
fi

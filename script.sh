#!/bin/sh
set -e
if [ -z ${GITHUB_APP_SETTINGS+x} ]; then echo "GITHUB_APP_SETTINGS var is not set" && exit 1; fi
# In codefresh/cli DO  apk add coreutils && export GITHUB_APP_SETTINGS=$(codefresh get context github-app --decrypt -o yaml | base64 -w0)
echo "Getting App ID..."
GITHUB_APP_APPID=$(echo $GITHUB_APP_SETTINGS | base64 -d  | yq -r '.spec.data.auth.appId')
if [ -z "$GITHUB_APP_APPID" ]; then echo "App ID is blank, something went wrong" && exit 2; else echo "App ID is $GITHUB_APP_APPID"; fi
echo "Getting installation ID..."
GITHUB_APP_INSTALLATIONID=$(echo $GITHUB_APP_SETTINGS | base64 -d  | yq -r '.spec.data.auth.installationId')
if [ -z "$GITHUB_APP_INSTALLATIONID" ]; then echo "Installation ID is blank, something went wrong" && exit 3; else echo "Installation ID is $GITHUB_APP_INSTALLATIONID"; fi
echo "Getting Private Key"
echo $GITHUB_APP_SETTINGS | base64 -d  | yq -r '.spec.data.auth.privateKey ' | base64 -d > /private.key
echo "Generating JWT token..."
GITHUB_APP_JWT=$(ruby /jwt-get.rb $GITHUB_APP_APPID)
echo "Receiving User Token..."
GITHUB_APP_USER_TOKEN=$(curl  -X POST -H "Authorization: Bearer  $GITHUB_APP_JWT" -H "Accept: application/json" https://api.github.com/app/installations/$GITHUB_APP_INSTALLATIONID/access_tokens  | jq -r  '.token' | cat)
if [ -z "$GITHUB_APP_USER_TOKEN" ]; then echo "Token is blank, something went wrong" && exit 4; else echo "Token received!"; fi
cf_export GITHUB_APP_USER_TOKEN=$GITHUB_APP_USER_TOKEN
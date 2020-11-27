#!/bin/sh

# In codefresh/cli DO  apk add coreutils && export GITHUB_APP_SETTINGS=$(codefresh get context github-app --decrypt -o yaml | base64 -w0)
echo "Getting App ID..."
GITHUB_APP_APPID=$(echo $GITHUB_APP_SETTINGS | base64 -d  | yq -r '.spec.data.auth.appId')
echo "$GITHUB_APP_APPID"
echo "Getting installation ID..."
GITHUB_APP_INSTALLATIONID=$(echo $GITHUB_APP_SETTINGS | base64 -d  | yq -r '.spec.data.auth.installationId')
echo "$GITHUB_APP_INSTALLATIONID"
echo "Getting Private Key"
echo $GITHUB_APP_SETTINGS | base64 -d  | yq -r '.spec.data.auth.privateKey ' | base64 -d > /private.key
echo "Generating JWT token..."
GITHUB_APP_JWT=$(ruby /jwt-get.rb $GITHUB_APP_APPID)
echo "Receiving User Token..."
cf_export GITHUB_APP_USER_TOKEN=$(curl  -X POST -H "Authorization: Bearer  $GITHUB_APP_JWT" -H "Accept: application/json" https://api.github.com/app/installations/$GITHUB_APP_INSTALLATIONID/access_tokens  | jq -r  '.token' | cat)
echo "Token received!"
#!/usr/bin/env bash

set -Eeuo pipefail

FILE=${1:?}

apt-get update
apt-get install --no-install-recommends -y jq
npm install -g vsce

JSON=$(cat $FILE)
EXTENSIONS=

for EXTENSION in $(echo $JSON | jq -r '.[].customizations.vscode.extensions | flatten[]'); do
    NAME="${EXTENSION%%@*}"
    VERSION=$(vsce show --json $NAME | jq -s '.versions[0].version')

    EXTENSIONS="\"$NAME@$VERSION\",$EXTENSIONS"
done

EXTENSIONS=${EXTENSIONS::-1}

echo $JSON | jq '.[].customizations.vscode.extensions = $extensions | sort' --argjson extensions "[$EXTENSIONS]" > $FILE

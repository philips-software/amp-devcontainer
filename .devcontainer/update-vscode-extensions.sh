#!/usr/bin/env bash

set -Eeuo pipefail

FILE=${1:?}

sudo apt-get update
sudo apt-get install --no-install-recommends -y jq
sudo npm install -g @vscode/vsce

JSON=$(cat $FILE)
EXTENSIONS=

for EXTENSION in $(echo $JSON | jq -r '.[].customizations.vscode.extensions | flatten[]'); do
    NAME="${EXTENSION%%@*}"
    VERSION=$(vsce show --json $NAME | jq -r '.versions[0].version')

    EXTENSIONS="\"$NAME@$VERSION\",$EXTENSIONS"
done

EXTENSIONS=$(echo "[${EXTENSIONS::-1}]" | jq 'sort_by(. | ascii_downcase)')

echo $JSON | jq '.[].customizations.vscode.extensions = $extensions' --argjson extensions "$EXTENSIONS" > $FILE

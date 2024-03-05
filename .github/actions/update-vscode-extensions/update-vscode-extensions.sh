#!/usr/bin/env bash

set -Eeuo pipefail

FILE=${1:?}
JSON=$(cat $FILE)
EXTENSIONS=
declare -A UPDATE_DETAILS
declare -i NUMBER_OF_UPDATES=0

for EXTENSION in $(echo $JSON | jq -r '.[].customizations.vscode.extensions | flatten[]'); do
    NAME="${EXTENSION%%@*}"
    CURRENT_VERSION="${EXTENSION#*@}"

    LATEST_NON_PRERELEASE_VERSION_JSON=$(vsce show --json $NAME | jq '[ .versions[] | select(.properties) | select(any(.properties[].key; contains("Microsoft.VisualStudio.Code.PreRelease")) | not) ][0]')
    LATEST_NON_PRERELEASE_VERSION=$(echo $LATEST_NON_PRERELEASE_VERSION_JSON | jq -r '.version')

    if [[ $CURRENT_VERSION != $LATEST_NON_PRERELEASE_VERSION ]];
    then
        NUMBER_OF_UPDATES+=1
        UPDATE_DETAILS=$(printf "Updates \`%s\` from %s to %s\n\n%s" $NAME $CURRENT_VERSION $LATEST_NON_PRERELEASE_VERSION "$UPDATE_DETAILS")
    fi

    EXTENSIONS="\"$NAME@$LATEST_VERSION\",$EXTENSIONS"
done

EXTENSIONS=$(echo "[${EXTENSIONS::-1}]" | jq 'sort_by(. | ascii_downcase)')
echo $JSON | jq '.[].customizations.vscode.extensions = $extensions' --argjson extensions "$EXTENSIONS" > $FILE

echo "{ \"numberOfUpdates\": \"$NUMBER_OF_UPDATES\", \"updateDetails\": \"$UPDATE_DETAILS\" }" | jq .

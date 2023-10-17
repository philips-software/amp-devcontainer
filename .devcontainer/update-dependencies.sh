#!/bin/bash

set -Eeuo pipefail

apt-get update
apt-get install jq -y

for FILE in "$@"; do
    JSON=$( cat $FILE )

    for PACKAGE in $( echo $JSON | jq -r 'keys | .[]' ); do
        VERSION=$( apt-cache policy "$PACKAGE" | grep -oP '(?<=Candidate:\s)(.+)' )
        JSON=$( echo $JSON | jq '.[$package] = $version' --arg package $PACKAGE --arg version $VERSION )
    done

    echo $JSON | jq . > $FILE
done

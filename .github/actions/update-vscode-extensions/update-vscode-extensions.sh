#!/usr/bin/env bash

set -Eeuo pipefail

FILE=${1:?}
JSON=$(cat $FILE)
EXTENSIONS=
UPDATE_DETAILS_MARKDOWN=
UPDATED_EXTENSIONS_JSON="[]"

get_github_releasenotes() {
    local GITHUB_URL=${1:?}
    local CURRENT_RELEASE=${2:?}

    gh release list --exclude-drafts --exclude-pre-releases -R $GITHUB_URL --json name,tagName --jq '.[]' | while read -r RELEASE;
    do
        NAME=$(echo "$RELEASE" | jq -r '.name')
        TAG=$(echo "$RELEASE" | jq -r '.tagName')

        if [[ $NAME == *$CURRENT_RELEASE* || $TAG == v$CURRENT_RELEASE ]];
        then
            break;
        fi

        printf "%s\n\n" "$(gh release view --json body --jq '.body' -R $GITHUB_URL $TAG)"
    done
}

for EXTENSION in $(echo $JSON | jq -r '.[].customizations.vscode.extensions | flatten[]'); do
    NAME="${EXTENSION%%@*}"
    CURRENT_VERSION="${EXTENSION#*@}"

    LATEST_NON_PRERELEASE_VERSION_JSON=$(vsce show --json $NAME | jq '[ .versions[] | select(.properties) | select(any(.properties[].key; contains("Microsoft.VisualStudio.Code.PreRelease")) | not) ][0]')
    LATEST_NON_PRERELEASE_VERSION=$(echo $LATEST_NON_PRERELEASE_VERSION_JSON | jq -r '.version')

    if [[ $CURRENT_VERSION != $LATEST_NON_PRERELEASE_VERSION ]];
    then
        GITHUB_URL=$(echo $LATEST_NON_PRERELEASE_VERSION_JSON | jq -r '.properties | map(select(.key == "Microsoft.VisualStudio.Services.Links.GitHub"))[] | .value')

        RELEASE_DETAILS=$(get_github_releasenotes $GITHUB_URL $CURRENT_VERSION)
        UPDATE_DETAILS_MARKDOWN=$(printf "Updates \`%s\` from %s to %s\n<details>\n<summary>Release notes</summary>\n<blockquote>\n\n%s\n</blockquote>\n</details>\n\n%s" $NAME $CURRENT_VERSION $LATEST_NON_PRERELEASE_VERSION "$RELEASE_DETAILS" "$UPDATE_DETAILS_MARKDOWN")
        UPDATED_EXTENSIONS_JSON=$(echo $UPDATED_EXTENSIONS_JSON | jq -c '. += ["'$NAME'"]')
    fi

    EXTENSIONS="\"$NAME@$LATEST_NON_PRERELEASE_VERSION\",$EXTENSIONS"
done

EXTENSIONS=$(echo "[${EXTENSIONS::-1}]" | jq 'sort_by(. | ascii_downcase)')
echo $JSON | jq '.[].customizations.vscode.extensions = $extensions' --argjson extensions "$EXTENSIONS" > $FILE

echo "$UPDATE_DETAILS_MARKDOWN"
echo "$UPDATED_EXTENSIONS_JSON" > updated-extensions.json

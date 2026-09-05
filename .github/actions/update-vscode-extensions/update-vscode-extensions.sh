#!/usr/bin/env bash

set -Eeuo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <input-file> [input-file...]" >&2
    exit 1
fi

# Only adopt a version once it has been public for at least this many days
COOLDOWN_DAYS="${COOLDOWN_DAYS:-7}"
COOLDOWN_CUTOFF=$(date -u -d "-${COOLDOWN_DAYS} days" +"%Y-%m-%dT%H:%M:%S.000Z")

UPDATE_DETAILS_MARKDOWN=
UPDATED_EXTENSIONS_JSON="[]"
FAILED_FILES=()

prevent_github_backlinks() {
    # Prevent GitHub from creating backlinks to issues by replacing the URL with a non-redirecting one
    # See: https://github.com/orgs/community/discussions/23123#discussioncomment-3239240
    sed 's|https://github.com|https://www.github.com|g'
}

prevent_github_at_mentions() {
    sed 's| @| [at]|g'
}

get_github_releasenotes() {
    local GITHUB_URL=${1:?}
    local CURRENT_VERSION_DATE=${2:?}
    local ADOPTED_VERSION_DATE=${3:?}

    # Fetch releases between the current version's publish date and the adopted version's,
    # so notes for versions still stuck in cooldown aren't shown as if they were adopted
    gh release list --exclude-drafts --exclude-pre-releases -R "$GITHUB_URL" \
        --json tagName,publishedAt \
        --jq ".[] | select(.publishedAt > \"$CURRENT_VERSION_DATE\" and .publishedAt <= \"$ADOPTED_VERSION_DATE\") | .tagName" | \
    while read -r TAG; do
        printf "%s\n\n" "$(gh release view --json body --jq '.body' -R "$GITHUB_URL" "$TAG")"
    done
}

# Resolves every pinned extension in $FILE to the latest version that is both non-prerelease and
# past the cooldown period, rewrites the file, and appends a per-flavor markdown section to the
# global summary so PR reviewers can trace which container each change applies to.
process_file() {
    local FILE=${1:?}
    JSON=$(cat "$FILE")
    FLAVOR=$(basename "$(dirname "$FILE")")
    FILE_EXTENSIONS=
    FILE_UPDATE_DETAILS_MARKDOWN=

    while IFS= read -r EXTENSION; do
        [[ -z "$EXTENSION" ]] && continue

        NAME="${EXTENSION%%@*}"
        CURRENT_VERSION="${EXTENSION#*@}"

        # Fetch all non-prerelease versions with their dates
        if ! ALL_VERSIONS_JSON=$("${VSCE_BIN:-vsce}" show --json "$NAME" | jq '[ .versions[] | select(.properties) | select(any(.properties[].key; contains("Microsoft.VisualStudio.Code.PreRelease")) | not) ]'); then
            # A shell function invoked as the condition of `if` is exempt from `set -e`, so a
            # failure here must be checked explicitly to correctly abort this file.
            echo "::error::Failed to query the marketplace for $NAME, aborting $FILE"
            return 1
        fi
        LATEST_ELIGIBLE_VERSION_JSON=$(echo "$ALL_VERSIONS_JSON" | jq --arg cutoff "$COOLDOWN_CUTOFF" '[ .[] | select(.lastUpdated <= $cutoff) ][0]')
        LATEST_ELIGIBLE_VERSION=$(echo "$LATEST_ELIGIBLE_VERSION_JSON" | jq -r '.version // empty')

        if [[ -z "$LATEST_ELIGIBLE_VERSION" ]]; then
            echo "::warning::No version of $NAME has cleared the ${COOLDOWN_DAYS}-day cooldown yet, skipping"
            FILE_EXTENSIONS="\"$NAME@$CURRENT_VERSION\",$FILE_EXTENSIONS"
            continue
        fi

        if [[ $CURRENT_VERSION != "$LATEST_ELIGIBLE_VERSION" ]];
        then
            GITHUB_URL=$(echo "$LATEST_ELIGIBLE_VERSION_JSON" | jq -r '.properties | map(select(.key == "Microsoft.VisualStudio.Services.Links.GitHub"))[] | .value')

            if [[ -n "$GITHUB_URL" && "$GITHUB_URL" != "null" ]]; then
                # Get the publish dates to bound release notes to what's actually being adopted
                CURRENT_VERSION_DATE=$(echo "$ALL_VERSIONS_JSON" | jq -r --arg version "$CURRENT_VERSION" 'map(select(.version == $version))[0].lastUpdated // empty')
                ADOPTED_VERSION_DATE=$(echo "$LATEST_ELIGIBLE_VERSION_JSON" | jq -r '.lastUpdated // empty')

                if [[ -n "$CURRENT_VERSION_DATE" && -n "$ADOPTED_VERSION_DATE" ]]; then
                    RELEASE_DETAILS=$(get_github_releasenotes "$GITHUB_URL" "$CURRENT_VERSION_DATE" "$ADOPTED_VERSION_DATE" | prevent_github_backlinks | prevent_github_at_mentions)
                else
                    echo "::warning::Could not find publish date for $NAME@$CURRENT_VERSION, skipping release notes"
                    RELEASE_DETAILS=""
                fi
                FILE_UPDATE_DETAILS_MARKDOWN=$(printf "Updates \`%s\` from %s to %s\n<details>\n<summary>Release notes</summary>\n<blockquote>\n\n%s\n</blockquote>\n</details>\n\n%s" "$NAME" "$CURRENT_VERSION" "$LATEST_ELIGIBLE_VERSION" "$RELEASE_DETAILS" "$FILE_UPDATE_DETAILS_MARKDOWN")
            else
                FILE_UPDATE_DETAILS_MARKDOWN=$(printf "Updates \`%s\` from %s to %s\n\n%s" "$NAME" "$CURRENT_VERSION" "$LATEST_ELIGIBLE_VERSION" "$FILE_UPDATE_DETAILS_MARKDOWN")
            fi

            UPDATED_EXTENSIONS_JSON=$(echo "$UPDATED_EXTENSIONS_JSON" | jq -c --arg name "$NAME" 'if index($name) then . else . + [$name] end')
        fi

        FILE_EXTENSIONS="\"$NAME@$LATEST_ELIGIBLE_VERSION\",$FILE_EXTENSIONS"
    done < <(echo "$JSON" | jq -r '.customizations.vscode.extensions | flatten[]')

    if [[ -n "$FILE_EXTENSIONS" ]]; then
        FILE_EXTENSIONS=$(echo "[${FILE_EXTENSIONS::-1}]" | jq 'sort_by(. | ascii_downcase)')
    else
        FILE_EXTENSIONS="[]"
    fi

    echo "$JSON" | jq '.customizations.vscode.extensions = $extensions' --argjson extensions "$FILE_EXTENSIONS" > "$FILE"

    echo "::group::📄 Changes to $FILE"
    git diff --color=always -- "$FILE" || true
    echo "::endgroup::"

    if [[ -n "$FILE_UPDATE_DETAILS_MARKDOWN" ]]; then
        UPDATE_DETAILS_MARKDOWN="${UPDATE_DETAILS_MARKDOWN}$(printf "### 🍨 %s — %s\n\n%s\n" "$FLAVOR" "$(basename "$FILE")" "$FILE_UPDATE_DETAILS_MARKDOWN")"
    fi
}

for FILE in "$@"; do
    if ! process_file "$FILE"; then
        echo "::error::Failed to update VS Code extensions in $FILE"
        FAILED_FILES+=("$FILE")
    fi
done

echo "::group::VS Code Extensions Update Details"
echo "$UPDATE_DETAILS_MARKDOWN"
echo "::endgroup::"

MARKDOWN_SUMMARY_FILE=$(mktemp "${RUNNER_TEMP:-/tmp}/markdown-summary.XXXXXX.md")
echo "$UPDATE_DETAILS_MARKDOWN" > "${MARKDOWN_SUMMARY_FILE}"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "markdown-summary-file=${MARKDOWN_SUMMARY_FILE}" >> "${GITHUB_OUTPUT}"
    echo "updated-dependencies=${UPDATED_EXTENSIONS_JSON}" >> "${GITHUB_OUTPUT}"
fi

if [[ ${#FAILED_FILES[@]} -gt 0 ]]; then
    echo "::error::Failed to update VS Code extensions in: ${FAILED_FILES[*]}"
    exit 1
fi

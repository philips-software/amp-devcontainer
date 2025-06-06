#!/usr/bin/env bash

FROM_CONTAINER=${1:?}
TO_CONTAINER=${2:?}

get_sizes_from_manifest() {
    local CONTAINER=${1:?}
    declare -Ag ${2:?}
    local -n SIZE_MAP=${2}

    for MANIFEST in $(docker manifest inspect -v ${CONTAINER} | jq -c 'if type == "array" then .[] else . end' | jq -r '[ ( .Descriptor.platform | [ .os, .architecture, .variant, ."os.version" ] | del(..|nulls) | join("/") ), ( [ .OCIManifest.layers[].size ] | add ) ] | join(":")');
    do
        PLATFORM="${MANIFEST%%:*}"
        SIZE="${MANIFEST#*:}"

        if [[ ${PLATFORM} != "unknown/unknown" ]];
        then
            SIZE_MAP[${PLATFORM}]=${SIZE}
        fi
    done
}

get_sizes_from_manifest ${FROM_CONTAINER} FROM_CONTAINER_SIZES
get_sizes_from_manifest ${TO_CONTAINER} TO_CONTAINER_SIZES

echo "## 📦 Container Size Analysis"
echo
echo "Comparing \`${FROM_CONTAINER}\` to \`${TO_CONTAINER}\`"
echo

echo "### 📈 Size Comparison Table"
echo
echo "| OS/Platform | Previous Size | Current Size | Change | Trend |"
echo "|-------------|:-------------:|:------------:|:------:|:-----:|"

for PLATFORM in "${!FROM_CONTAINER_SIZES[@]}";
do
    FROM_SIZE=${FROM_CONTAINER_SIZES[${PLATFORM}]:0}
    TO_SIZE=${TO_CONTAINER_SIZES[${PLATFORM}]:0}
    DELTA=$((${TO_SIZE} - ${FROM_SIZE}))

    if [[ ${FROM_SIZE} -eq 0 ]]; then
        # If base size was 0, and there's a change, that's infinite percentage change
        if [[ ${TO_SIZE} -gt 0 ]]; then
            PERCENT_CHANGE="+∞"
        else
            PERCENT_CHANGE="+0.00"
        fi
    else
        PERCENT_CHANGE=$(awk -v head="${TO_SIZE}" -v base="${FROM_SIZE}" 'BEGIN { printf "%+0.2f", ((head - base) / base) * 100 }')
    fi

    if (( DELTA < 0 )); then
        ICON="🔽"
        MD_COLOR_START="<span style=\"color:green\">"
        MD_COLOR_END="</span>"
    elif (( DELTA > 0 )); then
        ICON="🔼"
        MD_COLOR_START="<span style=\"color:red\">"
        MD_COLOR_END="</span>"
    else
        ICON="🔄"
        MD_COLOR_START=""
        MD_COLOR_END=""
    fi

    echo "| ${PLATFORM} | $(numfmt --to iec --format '%.2f' ${FROM_SIZE}) | $(numfmt --to iec --format '%.2f' ${TO_SIZE}) | ${MD_COLOR_START}$(numfmt --to iec --format '%.2f' ${DELTA}) (${PERCENT_CHANGE}%)${MD_COLOR_END} | ${ICON} |"
done

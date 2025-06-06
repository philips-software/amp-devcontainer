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

echo "## 📊 Container Size Analysis"
echo
echo "Comparing compressed layer sizes of:"
echo "📦 Base: \`${FROM_CONTAINER}\`"
echo "📦 Current: \`${TO_CONTAINER}\`"
echo

echo "### 📈 Size Comparison Table"
echo
echo "| OS/Platform | Previous Size | Current Size | Change | Trend |"
echo "|-------------|:-------------:|:------------:|:------:|:-----:|"

for PLATFORM in "${!FROM_CONTAINER_SIZES[@]}";
do
    BASE_SIZE=${FROM_CONTAINER_SIZES[${PLATFORM}]}
    HEAD_SIZE=${TO_CONTAINER_SIZES[${PLATFORM}]}
    DELTA=$((${HEAD_SIZE} - ${BASE_SIZE}))
    PERCENT_CHANGE=$(python -c "print('{:+0.2f}'.format(((${HEAD_SIZE} - ${BASE_SIZE}) / ${BASE_SIZE}) * 100))")

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

    echo "| ${PLATFORM} | $(numfmt --to iec --format '%.2f' ${BASE_SIZE}) | $(numfmt --to iec --format '%.2f' ${HEAD_SIZE}) | ${MD_COLOR_START}$(numfmt --to iec --format '%.2f' ${DELTA}) (${PERCENT_CHANGE}%)${MD_COLOR_END} | ${ICON} |"
done

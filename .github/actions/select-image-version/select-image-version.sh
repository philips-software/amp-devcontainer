#!/usr/bin/env bash
# Select the version of the image that an acceptance test uses, see README.md.
#
# Environment:
#   EVENT_NAME     name of the event of the workflow
#   REF_TYPE       type of the ref of the workflow, `branch` or `tag`
#   REF_NAME       name of the ref of the workflow
#   PR_NUMBER      number of the pull request, for a pull request
#   GITHUB_OUTPUT  file the `version` output is appended to

set -Eeuo pipefail

event_name=${EVENT_NAME:?event name required}
ref_type=${REF_TYPE:?ref type required}
ref_name=${REF_NAME:?ref name required}
github_output=${GITHUB_OUTPUT:?GITHUB_OUTPUT required}

if [[ "${event_name}" == "pull_request" ]]; then
  version="pr-${PR_NUMBER:?pull request number required}"
elif [[ "${ref_type}" == "tag" ]]; then
  # Any event on a tag, e.g. a manual run, tests the image that is built for the release
  version=${ref_name}
else
  version=edge
fi

echo "version=${version}" >> "${github_output}"

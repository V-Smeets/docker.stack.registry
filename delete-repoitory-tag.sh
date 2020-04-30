#!/bin/bash
#

registryUrl="http://127.0.0.1:5000"

function getDigest() {
	local repository="${1:?No repository defined}"
	local tag="${2:?No tag defined}"

	local heaerFile=$(mktemp)
	curl \
		--silent \
		--header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
		--dump-header "$heaerFile" \
		"${registryUrl}/v2/${repository}/manifests/${tag}" \
		>/dev/null
	awk '$1 == "Docker-Content-Digest:" { print $2 }' "$heaerFile" \
	| tr --complement --delete '[:alnum:][:punct:]'
	rm -f "$heaerFile"
}

function deleteDigest() {
	local repository="${1:?No repository defined}"
	local digest="${2:?No digest defined}"

	curl \
		--silent \
		--request DELETE \
		"${registryUrl}/v2/${repository}/manifests/${digest}"
}

repository="${1:?No repository defined}"
tag="${2:?No tag defined}"

digest=$(getDigest "$repository" "$tag")
if [[ -z "$digest" ]]
then
	echo "${repository}:${tag}" "does not exists"
	exit 1
fi

deleteDigest "$repository" "$digest" | jq

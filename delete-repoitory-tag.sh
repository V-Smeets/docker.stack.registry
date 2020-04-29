#!/bin/bash
#

registryUrl="http://127.0.0.1:5000"

function getRequest() {
	local path="$1"

	curl \
		--silent \
		--header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
		"${registryUrl}${path}"
}

function deleteRequest() {
	local path="$1"

	curl \
		--silent \
		--request DELETE \
		--header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
		"${registryUrl}${path}"
}

function deleteDigest() {
	local repository="$1"
	local digest="$2"

	deleteRequest "/v2/${repository}/manifests/${digest}"
}

function getManifest() {
	local repository="$1"
	local tag="$2"

	getRequest "/v2/${repository}/manifests/${tag}"
}

function getDigest() {
	local repository="$1"
	local tag="$2"

	getManifest "$repository" "$tag" \
	| jq --raw-output '.config.digest'
}

repository="${1:?No repository defined}"
tag="${2:?No tag defined}"

digest=$(getDigest "$repository" "$tag")
deleteDigest "$repository" "$digest" | jq

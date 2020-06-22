#!/bin/bash
#

registryUrl="http://PC-Vincent:5000"

function getRequest() {
	local path="$1"

	curl \
		--silent \
		"${registryUrl}${path}"
}

function getRepositories() {
	getRequest "/v2/_catalog" \
	| jq --raw-output '.repositories[]' \
	| sort
}

function getTags() {
	local repository="$1"

	getRequest "/v2/${repository}/tags/list" \
	| jq --raw-output '.tags[]' \
	| sort
}

for repository in $(getRepositories)
do
	for tag in $(getTags "$repository")
	do
		echo "Image:" "${repository}:${tag}"
	done
done

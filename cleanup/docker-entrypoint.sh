#!/bin/sh
#
serviveName="registry"

function getStackName()
{
	local containerId="$1"

	curl \
		--silent \
		--unix-socket /var/run/docker.sock \
		"http://localhost/containers/${containerId}/json" \
	| jq --raw-output '.Config.Labels."com.docker.stack.namespace"'
}

function getContainerIdsByServiceName()
{
	local serviceName="$1"

	filters="{\"label\": [\"com.docker.swarm.service.name=${serviceName}\"]}"
	filtersEncoded="$(echo "$filters" | jq --slurp --raw-input --raw-output "@uri")"
	curl \
		--silent \
		--unix-socket /var/run/docker.sock \
		"http://localhost/containers/json?filters=$filtersEncoded" \
	| jq --raw-output '.[].Id'
}

function createExec()
{
	containerId="$1"
	shift
	cmd="$@"

	data="{
		\"AttachStdin\": false,
		\"AttachStdout\": true,
		\"AttachStderr\": false,
		\"Tty\": false,
		\"Cmd\": [
			$(for word in "$@"; do echo "\"$word\", "; done)
			\"\"
		]
	}"
	curl \
		--silent \
		--unix-socket /var/run/docker.sock \
		--header "Content-Type: application/json" \
		--data "$data" \
		"http://localhost/containers/${containerId}/exec" \
	| jq --raw-output '.Id'
}

function startExec()
{
	execId="$1"

	data="{
		\"Detach\": false,
		\"Tty\": false
	}"
	curl \
		--silent \
		--unix-socket /var/run/docker.sock \
		--header "Content-Type: application/json" \
		--data "$data" \
		"http://localhost/exec/${execId}/start"
}

stackName=$(getStackName $(hostname))

sleep 10
while :
do
	containerIds=$(getContainerIdsByServiceName "${stackName}_${serviveName}")

	for containerId in $containerIds
	do
		execId=$(createExec "$containerId" registry garbage-collect --delete-untagged /etc/docker/registry/config.yml)
		startExec "$execId"
	done

	sleep 86400
done

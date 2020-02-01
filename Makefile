#
STACK_NAME	= registry

# General
all::
clean::
distclean:: clean

# stack
all:: docker-compose.yml
	docker-compose --file docker-compose.yml --project-name ${STACK_NAME} build --pull
	docker-compose --file docker-compose.yml --project-name ${STACK_NAME} push
	docker stack deploy --compose-file docker-compose.yml --prune ${STACK_NAME}
clean::
	docker stack rm ${STACK_NAME}
	-docker container wait `docker container ls --filter label=com.docker.stack.namespace="${STACK_NAME}" --quiet`
distclean::
	docker system prune --all --filter label=com.docker.stack.namespace="${STACK_NAME}" --volumes --force
docker-compose.yml: ${SECRET_FILE_NAMES}

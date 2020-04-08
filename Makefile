#
STACK_NAME		= registry
TARGETS			= registry
PLATFORMS		= linux/amd64

comma			:= ,
empty			:=
space			:= $(empty) $(empty)

# General
all::
clean::
distclean:: clean

# Stack
all:: stack
clean::
	docker stack rm ${STACK_NAME}
	-docker container wait `docker container ls --filter label=com.docker.stack.namespace="${STACK_NAME}" --quiet`
distclean::
	docker system prune --all --filter label=com.docker.stack.namespace="${STACK_NAME}" --volumes --force
stack:: docker-compose.yml
	docker stack deploy --compose-file docker-compose.yml --prune ${STACK_NAME}
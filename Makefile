#
NAME	= registry

deploy: docker-compose.yml
	docker stack deploy --compose-file docker-compose.yml ${NAME}

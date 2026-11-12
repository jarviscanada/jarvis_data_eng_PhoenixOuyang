#!/bin/bash

cmd=$1
db_username=$2
db_password=$3

# Start docker if not already running
sudo systemctl is-active --quiet docker || sudo systemctl start docker

# Check container status
docker container inspect jrvs-psql > /dev/null 2>&1
container_status=$?

# User switch case to handle create|stop|start operations
case "$cmd" in
	create)
	if [ "$container_status" -eq 0 ]; then
		echo 'Error: Container already exists'
		exit 1
	fi

	# check number of CLI arguments
	if [ $# -ne 3 ]; then
		echo 'Error: Create requires username and password'
		exit 1
	fi

	# Create container
	docker volume create pgdata > /dev/null
	docker run --name jrvs-psql -e POSTGRES_USER="$db_username" -e POSTGRES_PASSWORD="$db_password" -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine > /dev/null
	status=$?
	if [ $status -eq 0 ]; then
		echo 'Cointainer created'
	fi
	exit $status
	;;
	
	start|stop)
	if [ "$container_status" -ne 0 ]; then			
		echo 'Error: Container is not created'
		exit 1
	fi

	if [ $# -gt 1 ]; then
		echo 'Warning: username and/or password is not used for start/stop commands'
	fi	

	docker container "$cmd" jrvs-psql
	status=$?

	if [ $status -eq 0 ]; then
		if [ $cmd = "start" ]; then
			echo "Container started"
		else
			echo "Container stopped"
	
		fi
	fi
	exit $status
	;;

	*)
	echo 'Illegal command'
	echo 'Commands: start|stop|create'
	exit 1
	;;
esac

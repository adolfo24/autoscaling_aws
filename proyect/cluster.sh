#!/usr/bin/env bash
#creamos las maquinas virtuales en virtualbox 
for i in "1" "2" "3"; do
	docker-machine create -d virtualbox nodo-$i
done
#obtenemos la ip del nodo-1 que va ser nuestro manager
MANAGER_IP=$(docker-machine ip nodo-1)
#configuramos nuestro docker swarm
eval $(docker-machine env nodo-1)
docker swarm init --advertise-addr $MANAGER_IP
MANAGER_TOKEN=$(docker swarm join-token -q manager)
WORKER_TOKEN=$(docker swarm join-token -q worker)
for i in "2" "3";do
	WORKER_IP=$(docker-machine ip nodo-$i)
	eval $(docker-machine env nodo-$i)
	docker swarm join --token $WORKER_TOKEN --advertise-addr $WORKER_IP $MANAGER_IP:2377
done
#compiamos la aplicacion del directorio local y tambien descargamos las imagenes de docker 
for i in "1" "2" "3"; do
    docker-machine ssh nodo-$i "sudo mkdir -p /home/"
    docker-machine scp -r `pwd` nodo-$i:/home/
	docker-machine ssh nodo-$i "sudo mkdir -p /data/db/"
	eval $(docker-machine env nodo-$i)
    docker pull dooros/nodemongodb
    docker pull dockersamples/visualizer
done
#ponemos en ejecucion nuestros servicios 
eval $(docker-machine env nodo-1)
docker stack deploy --compose-file docker-compose.yml proyect
docker service ls
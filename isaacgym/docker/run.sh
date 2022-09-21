#!/bin/bash
set -e
set -u

if [ $# -eq 0 ]
then
    echo "running docker without display"
    docker run -it --network=host --gpus='"device=1"' --name=isaacgym_container isaacgym /bin/bash
else
    export DISPLAY=$DISPLAY HOME=$HOME
	echo "Dsiplay before mod: $DISPLAY"
	echo "Home path: $HOME"
	XSOCK=/tmp/.X11-unix
	XAUTH=/tmp/.docker.xauth
	xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | sudo xauth -f $XAUTH nmerge -
	sudo chmod 777 $XAUTH
	X11PORT=`echo $DISPLAY | sed 's/^[^:]*:\([^\.]\+\).*/\1/'`
	TCPPORT=`expr 6000 + $X11PORT`
	sudo ufw allow from 172.17.0.0/16 to any port $TCPPORT proto tcp 
	DISPLAY=`echo $DISPLAY | sed 's/^[^:]*\(.*\)/172.17.0.1\1/'`
	echo "Display after mod: $DISPLAY"
#	sudo docker run -ti --rm -e DISPLAY=$DISPLAY -v $XAUTH:$XAUTH \
#		   -e XAUTHORITY=$XAUTH name_of_docker_image
	docker run -it --rm -e DISPLAY=$DISPLAY -v$XAUTH:$XAUTH -e XAUTHORITY=$XAUTH \
		-v $HOME/isaacgym/isaacgym:/opt/isaacgym:rw \
		--network=host --gpus='"device=1"'\
		--name=isaacgymmarker_container3 isaacgymmarker /bin/bash


	#DISPLAY=`echo $DISPLAY | sed 's/^[^:]*\(.*\)/172.17.0.1\1/'`
#	echo "setting display to $DISPLAY"
#	echo "Home path: $HOME"
	#SOCK=/tmp/.X11-unix
	#XAUTH=/tmp/.docker.xauth
	#xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
	#chmod 777 $XAUTH
#	xhost +
#	docker run -it --rm -e DISPLAY=$DISPLAY -v$XAUTH:$XAUTH -e XAUTHORITY=$XAUTH \
#		-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY  \
#		-v $HOME/isaacgym/isaacgym:/opt/isaacgym:rw \
#		--volume=$HOME/.Xauthority:/home/anur0n/.Xauthority:rw\
#		--network=host --gpus='"device=1"'\
#		--name=isaacgymmarker_container3 isaacgymmarker /bin/bash
		# --name=isaacgym_container isaacgym /bin/bash #--mount "type=bind,source=$(pwd)/../source_dir,target=/app/target_dir"\
		
	xhost -
fi

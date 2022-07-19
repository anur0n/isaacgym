#!/bin/bash
set -e
set -u

if [ $# -eq 0 ]
then
    echo "running docker without display"
    docker run -it --network=host --gpus='"device=1"' --name=isaacgym_container isaacgym /bin/bash
else
    export DISPLAY=$DISPLAY HOME=$HOME
	#DISPLAY=`echo $DISPLAY | sed 's/^[^:]*\(.*\)/172.17.0.1\1/'`
	echo "setting display to $DISPLAY"
	echo "Home path: $HOME"
	#SOCK=/tmp/.X11-unix
	#XAUTH=/tmp/.docker.xauth
	#xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
	#chmod 777 $XAUTH
	xhost +
	docker run -it --rm \
		-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY  \
		-v $HOME/isaacgym/isaacgym:/opt/isaacgym:rw \
		--volume=$HOME/.Xauthority:/home/anur0n/.Xauthority:rw\
		--network=host --gpus='"device=2"'\
		--name=isaacgymmarker_container2 isaacgymmarker /bin/bash
		# --name=isaacgym_container isaacgym /bin/bash #--mount "type=bind,source=$(pwd)/../source_dir,target=/app/target_dir"\
		
	xhost -
fi

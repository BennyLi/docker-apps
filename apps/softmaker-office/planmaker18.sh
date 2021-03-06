#! /bin/sh

container_name="planmaker18"
config_volume_name="softmaker-officei2"

if [ -n "$(docker container ls -a -f name=$container_name -q)" ]
then
  docker stop "$container_name" > /dev/null
  docker rm "$container_name" > /dev/null
fi

#####  ---------------  Volume Setup  ---------------  #####
if [ -n "$(docker volume ls -f name=$config_volume_name -q)" ]
then
  docker volume create "$config_volume_name" > /dev/null
fi


#####  ---------------  Container Setup  ---------------  #####
docker create --tty \
              --name "$container_name" \
              `# Open up the Display for the GUI` \
              -e "DISPLAY=unix$DISPLAY" \
              -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
              `# Mount the config and the documents folder` \
              -v $config_volume_name:/home/dockuser/SoftMaker/:rw \
              -v $HOME/Documents:/home/dockuser/Documents:rw \
              -v $HOME/Development:/home/dockuser/Development:rw \
              -v /run/media/$USER/:/home/dockuser/Media:rw \
              --entrypoint /usr/bin/planmaker18 \
              bennyli/softmaker-office:2018 $@


container_id=$(docker container ls -a -f name=$container_name -q)
xhost +local:`docker inspect --format='{{ .Config.Hostname }}' $container_id`
docker start $container_id

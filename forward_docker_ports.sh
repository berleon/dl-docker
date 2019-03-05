#! /usr/bin/env bash

HOST="$1";

LOCAL_CONFIG='~/.config/docker_ports'
# MONGO_HOST=$(ssh $HOST "cat $LOCAL_CONFIG/mongodb_host")
MONGO_PORT=$(ssh $HOST "cat $LOCAL_CONFIG/mongodb_port")
SACRED_BOARD_PORT=$(ssh $HOST "cat $LOCAL_CONFIG/sacredboard_port")

# JUPYTER_HOST=$(ssh $HOST "cat $LOCAL_CONFIG/jupyter_host")
JUPYTER_PORT=$(ssh $HOST "cat $LOCAL_CONFIG/jupyter_port")

# TENSORBOARD_HOST=$(ssh $HOST "cat $LOCAL_CONFIG/tensorboard_host")
TENSORBOARD_PORT=$(ssh $HOST "cat $LOCAL_CONFIG/tensorboard_port")

SSH_PORT=$(ssh $HOST "cat $LOCAL_CONFIG/ssh_port")

if [ "$MONGO_PORT" != "" ]; then
    echo "MONGODB: $MONGO_HOST:$MONGO_PORT"
    MONGO_FORWARD="-L 27017:localhost:$MONGO_PORT"
else
    MONGO_FORWARD=""
fi
echo "JUPYTER: $JUPYTER_HOST:$JUPYTER_PORT"
echo "TENSORBOARD: $TENSORBOARD_HOST:$TENSORBOARD_PORT"
echo "SSH: $SSH_HOST:$SSH_PORT"

CMD="ssh \
	$MONGO_FORWARD \
	-L 5000:localhost:$SACRED_BOARD_PORT \
	-L 8000:localhost:$JUPYTER_PORT \
	-L 6006:localhost:$TENSORBOARD_PORT \
	-L 8022:localhost:$SSH_PORT \
	$HOST -t zsh
	"

echo $CMD
$CMD

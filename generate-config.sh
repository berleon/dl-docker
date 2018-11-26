#! /usr/bin/env bash

N_GPUS=$(nvidia-smi -L | wc -l)

seq 0 $N_GPUS
GPUS=""
for i in `seq 0 $((N_GPUS - 1))`; do
    if [ "$i" == "0" ]; then
        GPUS="$i"
    else
        GPUS="$GPUS,$i"
    fi
done


cat <<EOF
# directory where to store ports
PORTS_CONFIG=${HOME}/.config/docker_ports/

# username
NAME=${USER}

# gpus to use
GPU='$GPUS'

# start jupyter in this directory
JUPYTER_DIR=${HOME}

# save models in this directory
MODEL_DIR='${HOME}/models/'

# directory for tensorboard runs
TENSORBOARD_DIR='${HOME}/runs/'

# directory for mongodb database
MONGODB_DIR='${HOME}/mongodb_experiments/'

# mongodb uri. mlproject will replaced the default will your instance
MONGODB_URI='mongodb://mlproject_fill_in_mongodb'

# directory for mongodb database
DATA_DIR='${HOME}/data/'

# mounted directories
DOCKER_MOUNTS= -v ${HOME}:${HOME} -v /mnt/ssd:/mnt/ssd -v /home/data:/home/data
EOF

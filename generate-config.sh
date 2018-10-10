#! /usr/bin/env bash

cat <<EOF
PORTS_CONFIG=${HOME}/.config/docker_ports/
NAME=${USER}
GPU='0,1'
JUPYTER_DIR=${HOME}
MODEL_DIR='${HOME}/models/'
TENSORBOARD_DIR='${HOME}/runs/'
MONGO_DIR='${HOME}/mongodb_experiments/'
DATA_DIR='${HOME}/data/'
DOCKER_MOUNTS= -v ${HOME}:${HOME} -v /mnt/ssd:/mnt/ssd -v /home/data:/home/data
EOF

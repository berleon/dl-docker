#! /usr/bin/env bash

echo tensorboard --logdir=$TENSORBOARD_DIR
tensorboard --logdir=$TENSORBOARD_DIR &

jupyter notebook --ip=0.0.0.0 --no-browser --notebook-dir=$JUPYTER_DIR

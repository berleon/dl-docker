#! /usr/bin/env bash

echo tensorboard --logdir=$TENSORBOARD_DIR
tensorboard --logdir=$TENSORBOARD_DIR &

cd $JUPYTER_DIR
jupyter --version
jupyter lab --ip=0.0.0.0 --no-browser --notebook-dir=$JUPYTER_DIR

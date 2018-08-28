#! /usr/bin/env bash

jupyter --version
jupyter lab --ip=0.0.0.0 --no-browser --notebook-dir=$JUPYTER_DIR

#! /usr/bin/env bash

mkdir -p $MONGO_DIR
sudo mongod --dbpath $MONGO_DIR  --fork --logpath $MONGO_DIR/mongodb.log &
sacredboard --no-browser -m sacred


#! /usr/bin/env bash

mkdir -p $MONGODB_DIR
echo "Starting mongodb in: $MONGODB_DIR"
sudo mongod --dbpath $MONGODB_DIR  --fork --logpath $MONGODB_DIR/mongodb.log &
sacredboard --no-browser -m sacred


# My Docker Setup

This deep learning docker setup includes the [sacred library](https://sacred.readthedocs.io/en/latest/), tensorboard and pytorch.

## Setup

Create your own config.mk file with

```
$ make config > config.mk
```

This defines the paths of jupyter, pytorch, and mongodb, which volumes to mount and which gpus to use.

## Commands

`$ make build_all`: Builds all three images.

`$ make run_all`: Runs each images.

`$ make rm_images`: Removes the images.

`$ make rm_all_containers`: Removes all containers (using force).

`$ make zsh`: Creates an zsh session in the pytorch container.

## Forward Ports to Jupyter Notebook / Tensorboard / Sacredboard

The Makefile automatically saves all relevant ports.

You can forward the ports to your machine with with the `forward_docker_ports.sh` script.  On your local machine runs:

```
$ forward_docker_ports.sh <your_hostname>
```

You can then reach the services at:

| Service | Address |
|---------|---------|
| Jupyter Notebook  | [localhost:8000](http://localhost:8000/) |
| Tensorboard       | [localhost:6006](http://localhost:6006/) |
| Sacred Board      | [localhost:5000](http://localhost:5000/) |
| Mongo DB Connection | localhost:27017 |


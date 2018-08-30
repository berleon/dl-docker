# My Docker Setup


## Setup

Copy `config.mk.template` to `config.mk`

```bash
$ cp config.mk.template config.mk
```

Edit the config to set the appropriate paths.

## Build & Start

```
$ make build_all
$ make run_all
```

## Forward Ports to Jupyter Notebook / Tensorboard / Sacredboard

The Makefile automatically saves all relevant ports.

You can forward the ports to your machine with with the `forward_docker_ports.sh` script.
On your local machine runs:

```
$ forward_docker_ports.sh <your_hostname>
```

You can then reach the services at:

| Jupyter Notebook  | [localhost:8000](http://localhost:8000/) |
| Tensorboard       | [localhost:6006](http://localhost:6006/) |
| Sacred Board      | [localhost:5000](http://localhost:5000/) |
| Mongo DB Connection | localhost:27017 |


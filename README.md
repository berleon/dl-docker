# My Docker Setup


## Setup

Copy `config.mk.template` to `config.mk`

```bash
$ cp config.mk.template config.mk
```

Edit the config to set your

## Build & Start

```
$ make build_all
$ make run_all
```

## Forward Ports to Jupyter Notebook / Tensorboard / Sacredboard

The Makefile automatically saves all relevant ports.

You can forward them to your machine with:

```
$ forward_docker_ports.sh <your_hostname>
```

This must be run on your local machine.

| Jupyter Notebook  | [localhost:8000](http://localhost:8000/) |
| Tensorboard       | [localhost:6006](http://localhost:6006/) |
| Sacred Board      | [localhost:5000](http://localhost:5000/) |


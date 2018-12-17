include config.mk

.PHONY: print_config print_ports

build_all: build_mongodb build_tensorboard build_pytorch

build_pytorch:
	docker build -t $(NAME)/pytorch pytorch

build_mongodb:
	docker build  -t $(NAME)/mongodb mongodb

build_tensorboard:
	docker build -t $(NAME)/tensorboard tensorboard


print_config:
	echo "Name: $(NAME)"
	echo "Ports config: $(PORTS_CONFIG)"

print_ports:
	for f in $(PORTS_CONFIG)/* ; do \
		echo `basename $$f`: `cat $$f`; \
	done


rm_images:
	docker rmi $(NAME)/pytorch
	docker rmi $(NAME)/mongodb
	docker rmi $(NAME)/tensorboard

run_pytorch:
	mkdir -p $(PORTS_CONFIG)
	# --ipc=host fix data loader
		#--detach
	GPU=$(GPU) ./docker-run-wrapper.py \
		--name $(NAME)_pytorch  \
		--privileged \
		--cap-add=ALL \
		--ipc=host \
		--detach \
		-e JUPYTER_DIR=$(JUPYTER_DIR) \
		-e MODEL_DIR=$(MODEL_DIR) \
		-e TENSORBOARD_DIR=$(TENSORBOARD_DIR) \
		-e DATA_DIR=$(DATA_DIR) \
		$(DOCKER_MOUNTS)  \
		$(NAME)/pytorch
	sleep 1
	- if [ -e $(HOME)/install_local_pip.sh ]; then \
		docker exec -it $(NAME)_pytorch $(HOME)/install_local_pip.sh; \
	fi;
	docker port $(NAME)_pytorch | \
		perl -n -e'/8888.*:([0-9]+)/ && print $$1' \
		> $(PORTS_CONFIG)/jupyter_port
	docker port $(NAME)_pytorch | \
		perl -n -e'/22.*:([0-9]+)/ && print $$1' \
		> $(PORTS_CONFIG)/ssh_port
	echo `hostname` > $(PORTS_CONFIG)/ssh_host

run_tensorboard:
	mkdir -p $(PORTS_CONFIG)
	GPU='' ./docker-run-wrapper.py \
		--name $(NAME)_tensorboard \
		-it \
		-e TENSORBOARD_DIR=$(TENSORBOARD_DIR) \
		--publish 60000-61000:6006 \
		$(DOCKER_MOUNTS)  \
		--detach \
		$(NAME)/tensorboard
	sleep 1
	echo `hostname` > $(PORTS_CONFIG)/tensorboard_host
	docker port $(NAME)_tensorboard | \
		perl -n -e'/6006.*:([0-9]+)/ && print $$1' \
		 > $(PORTS_CONFIG)/tensorboard_port

MONGODB_CONTAINER_NAME = $(NAME)_mongodb
MONGODB_PORT=27017-28000
SACREDBOARD_PORT=5000-6000

run_mongodb_standalone:
	GPU='' ./docker-run-wrapper.py \
		--name $(MONGODB_CONTAINER_NAME) \
		-it \
		--detach \
		--publish $(SACREDBOARD_PORT):5000 \
		--publish $(MONGODB_PORT):27017 \
		-e MONGO_DIR=$(MONGODB_DIR) \
		-e MONGODB_DIR=$(MONGODB_DIR) \
		$(DOCKER_MOUNTS)  \
		--memory=4g \
		$(NAME)/mongodb
	sleep 1
	@ echo
	@ echo
	@ echo
	@ ADDR=$$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $(MONGODB_CONTAINER_NAME)); \
		   PORT=$$(docker port $(MONGODB_CONTAINER_NAME) | perl -n -e'/27017.*:([0-9]+)/ && print $$1'); \
		   echo MONGODB_DIR=$(MONGODB_DIR); \
		   echo "# from inside docker"; \
		   echo MONGODB_URI=mongodb://$$ADDR:27017 ; \
		   echo ""; \
		   echo "# from the outside "; \
		   echo MONGODB_URI=mongodb://`hostname`:$$PORT

run_mongodb: run_mongodb_standalone
	sleep 1
	echo `hostname` > $(PORTS_CONFIG)/mongodb_host
	docker port $(MONGODB_CONTAINER_NAME) | \
		perl -n -e'/27017.*:([0-9]+)/ && print $$1' \
		 > $(PORTS_CONFIG)/mongodb_port
	docker port $(MONGODB_CONTAINER_NAME)| \
		perl -n -e'/5000.*:([0-9]+)/ && print $$1' \
		> $(PORTS_CONFIG)/sacredboard_port
	docker inspect --format='{{.NetworkSettings.IPAddress}}' $(MONGODB_CONTAINER_NAME)\
		> $(PORTS_CONFIG)/docker_mongodb_ip

run_all: run_mongodb run_tensorboard run_pytorch

rm_pytorch:
	docker rm -f $(NAME)_pytorch

rm_tensorboard:
	docker rm -f $(NAME)_tensorboard

restart_pytorch:
	make rm_pytorch
	make run_pytorch

rm_all_containers:
	docker rm -f $(NAME)_pytorch
	docker rm -f $(MONGODB_CONTAINER_NAME)
	docker rm -f $(NAME)_tensorboard

zsh: enter_pytorch
zsh_root: enter_pytorch_root

enter_pytorch:
	docker exec -it --user $(USER) $(NAME)_pytorch sh -c zsh

enter_pytorch_root:
	docker exec -it $(NAME)_pytorch sh -c zsh

test:
	echo hello

save:
	[ ! -d "export" ]
	mkdir -p export
	cp -r . /tmp/dl-docker-backup
	mv /tmp/dl-docker-backup export/dl-docker-backup
	docker commit $(USER)_pytorch $(USER)_pytorch_savedf
	docker save --output export/$(USER)_pytorch_saved.tar $(USER)_pytorch_saved
	tar -czvf docker-dl-backup.tar.gz export/
	mv docker-dl-backup.tar.gz export

connect_to_mongodb:
	sudo mongo `cat ~/.config/master_thesis/docker_mongodb_ip`/

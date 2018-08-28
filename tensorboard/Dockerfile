FROM ubuntu:16.04
MAINTAINER Leon Sixt (docker@leon-sixt.de)


RUN apt-get update -qq \
        && DEBIAN_FRONTEND=noninteractive apt-get install -yq -qq --no-install-recommends \
        zsh \
        locales \
        python3 \
        python3-dev \
        python3-setuptools \
        python3-pip \
        && true

# install tensorflow==1.5 as newer tensorflows require axv instructions
RUN pip3 --no-cache-dir install \
    tensorflow==1.5  \
    && true

# set encoding to utf-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


# tensorboard
EXPOSE 6006

COPY "enterypoint.sh" "/usr/local/bin/tensorboard-enterypoint.sh"
RUN chmod +x /usr/local/bin/tensorboard-enterypoint.sh

USER $NB_USER
CMD ["/usr/local/bin/tensorboard-enterypoint.sh"]

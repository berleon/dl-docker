FROM ubuntu:16.04
MAINTAINER Leon Sixt (docker@leon-sixt.de)


RUN apt-get update -qq \
        && DEBIAN_FRONTEND=noninteractive apt-get install -yq -qq --no-install-recommends \
        zsh \
        htop \
        locales \
        python3 \
        python3-dev \
        python3-setuptools \
        python3-pip \
        sudo \
        && true

# Enable passwordless sudo for all users
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN pip3 install --upgrade pip

RUN pip3 --no-cache-dir install \
    sacred \
    pymongo \
    sacredboard \
    && true

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 && \
    echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list && \
    apt-get update -qq && \
    apt-get install -y \
        mongodb-org \
        && true

# set encoding to utf-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# mongodb port
EXPOSE 27017

# sacredboard port
EXPOSE 5000

COPY "enterypoint.sh" "/usr/local/bin/mongodb-enterypoint.sh"
RUN chmod +x /usr/local/bin/mongodb-enterypoint.sh

USER $NB_USER
CMD ["/usr/local/bin/mongodb-enterypoint.sh"]

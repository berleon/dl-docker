FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
MAINTAINER Leon Sixt (docker@leon-sixt.de)

RUN apt-get update && apt-get install -y --assume-yes --install-recommends \
        ca-certificates \
        openssh-server \
        checkinstall \
        git \
        sudo \
        build-essential \
        g++-4.9 \
        g++ \
        cmake \
        wget \
        unzip \
        zip \
        ack-grep \
        libopenblas-dev \
        libavformat-dev \
        libavcodec-dev \
        libavdevice-dev \
        libavutil-dev \
        libswscale-dev \
        libavresample-dev \
        libavcodec-extra \
        libav-tools \
        libopencv-dev \
        pkg-config \
        libbz2-dev \
        capnproto \
        tmux \
        gdb \
        vim \
        vim-nox \
        libgflags-dev \
        libzmqpp-dev \
        libhdf5-dev \
        libhdf5-cpp-11 \
        hdf5-tools \
        libgoogle-glog-dev \
        libjs-mathjax \
        jq \
        sshfs \
        zsh && \
    rm -rf /var/lib/apt/lists

# Enable passwordless sudo for all users
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV PATH /opt/conda/bin:$PATH

RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.4.10-Linux-x86_64.sh -O ~/miniconda.sh && \
        /bin/bash ~/miniconda.sh -b -p /opt/conda && \
        rm ~/miniconda.sh && \
        ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

RUN conda install -n base conda
RUN conda create -n py36  \
            -c pytorch \
            -c conda-forge \
        python=3.6 \
        anaconda \
        pytorch \
        cuda90 \
        numpy \
        torchvision \
        jupyter \
        jupyterlab \
        click \
        pandas \
        matplotlib \
        scipy \
        tqdm \
        scikit-learn \
        scikit-image \
        h5py \
        hdf5 \
        sympy \
        pymongo \
        pip \
        theano \
        tensorflow \
        keras \
        flake8 \
        pytest \
        pytest-arraydiff \
        pytest-flake8 \
        && true

RUN conda list -n py36 | grep python

ENV PATH /opt/conda/envs/py36/bin:$PATH

RUN which pip
RUN pip install \
        more_itertools \
        tensorboardX \
        sacred \
        dlib \
        && true


RUN jupyter nbextension enable --py widgetsnbextension
RUN pip install jupyter_contrib_nbextensions \
 && jupyter contrib nbextension install --system \
 && jupyter nbextension enable codefolding/main \
 && jupyter nbextension enable hinterland/hinterland \
 && jupyter nbextension enable varInspector/main \
 && jupyter nbextension enable comment-uncomment/main

RUN echo "source /opt/conda/bin/activate/py36" >> /etc/profile

COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

RUN mkdir /usr/.jupyter
ENV JUPYTER_CONFIG_DIR /usr/.jupyter
COPY jupyter_notebook_config.py /usr/.jupyter/

COPY run_jupyter.sh /usr/local/bin
COPY run_jupyterlab.sh /usr/local/bin
RUN chmod +x /usr/local/bin/run_jupyter.sh \
 && chmod -R a+rwx /usr/.jupyter \
 && chmod +x /usr/local/bin/run_jupyterlab.sh


RUN ldconfig    # otherwise the cuda libaries are not found

RUN apt-get update && apt-get install -y --assume-yes --install-recommends locales

RUN locale-gen en_US.UTF-8  # fix utf-8 encoding
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV DOCKER_DL True

RUN ln -s /opt/conda/bin/activate /usr/bin/activate
# Use the same gid and uid as your user on the host system. You can find them
# out with the `id`  programm. This way the file ownership in mapped directories is
# consistent with the host system.
#

# Setup gosu (https://github.com/tianon/gosu)
# gosu is an improved version of su which behaves better inside docker
# we use it to dynamically switch to the desired user in the entrypoint
# (see below)
ENV GOSU_VERSION 1.10
# Use unsecure HTTP via Port 80 to fetch key due to firewall in CIN.
RUN set -x \
 && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true

CMD ["/usr/local/bin/run_jupyterlab.sh"]

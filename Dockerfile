FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update --quiet && \
    apt-get install --yes --quiet --no-install-recommends software-properties-common \
        breeze-icon-theme \
        desktop-file-utils \
        elfutils \
        fakeroot \
        file \
        git \
        gnupg2 \
        gtk-update-icon-cache \
        libgdk-pixbuf2.0-dev \
        libglib2.0-bin \
        librsvg2-dev \
        libyaml-dev \
        python3 \
        python3-pip \
        strace \
        wget \
        squashfs-tools \
        zsync && \
    apt-get -yq autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /tmp
RUN wget https://github.com/NixOS/patchelf/releases/download/0.18/patchelf-0.18.tar.bz2; \
    tar -xvf patchelf-0.18.tar.bz2;  \
    cd patchelf-0.18; \
    ./configure && make && make install; \
    rm -rf patchelf-*

COPY . /opt/appimage-builder
RUN python3 -m pip install setuptools==80.9.0 && \
    python3 -m pip install /opt/appimage-builder && \
    rm -rf /opt/appimage-builder

WORKDIR /

FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

ARG PATCHELF_VERSION="0.18.0"

# Install build dependencies
RUN apt-get update --quiet \
  && apt-get install --yes --quiet --no-install-recommends  \
     build-essential \
     gcc \
     wget \
     bzip2 \
     ca-certificates

RUN wget https://github.com/NixOS/patchelf/releases/download/${PATCHELF_VERSION}/patchelf-${PATCHELF_VERSION}.tar.bz2 && \
    tar -xvf patchelf-${PATCHELF_VERSION}.tar.bz2 && \
    cd patchelf-${PATCHELF_VERSION} && \
    ./configure --prefix=/patchelf-install && \
    make -j"$(nproc)" && make check && make install && \
    strip /patchelf-install/bin/patchelf && \
    /patchelf-install/bin/patchelf --version

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /patchelf-install /usr/local

RUN apt-get update --quiet && \
    apt-get install --yes --quiet --no-install-recommends \
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
        squashfs-tools \
        zsync && \
    apt-get -y purge && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # Test installs
    patchelf --version

COPY . /opt/appimage-builder
RUN python3 -m pip install --no-cache-dir setuptools==80.9.0 && \
    python3 -m pip install --no-cache-dir /opt/appimage-builder && \
    rm -rf /opt/appimage-builder /root/.cache

WORKDIR /

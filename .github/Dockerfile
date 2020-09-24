FROM debian:latest

MAINTAINER Paul Spooren <mail@aparcar.org>

RUN apt-get update -qq &&\
    apt-get install -y \
        build-essential \
        curl \
        file \
        gawk \
        gettext \
        git \
        libncurses5-dev \
        libssl-dev \
        python3 \
        rsync \
        subversion \
        sudo \
        swig \
        unzip \
        wget \
        zlib1g-dev \
        && apt-get -y autoremove \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN useradd -c "OpenWrt Builder" -m -d /home/builer -G sudo -s /bin/bash builer
ADD sdk.tar.gz /home/builer/openwrt/
RUN chown builer:builer /home/builer/openwrt/

USER builer
ENV HOME /home/builer
WORKDIR /home/builer/openwrt/

FROM amd64/ubuntu:22.04

# ユーザー名
ARG DOCKER_USER_=Guest

# 対話モードを拒否
ENV DEBIAN_FRONTEND noninteractive

ARG APT_LINK=http://ftp.riken.jp/Linux/ubuntu/
RUN sed -i "s-$(cat /etc/apt/sources.list | grep -v "#" | cut -d " " -f 2 | grep -v "security" | sed "/^$/d" | sed -n 1p)-${APT_LINK}-g" /etc/apt/sources.list

RUN apt-get update\
	&& apt-get install -y \
	android-tools-adb \
	android-tools-fastboot autoconf \
	automake bc bison build-essential \
	ccache \
	cscope \
	curl \
	device-tree-compiler \
	expect \
	flex \
	ftp-upload \
	gdisk \
	iasl \
	libattr1-dev \
	libcap-dev \
	libfdt-dev \
	libftdi-dev \
	libglib2.0-dev \
	libhidapi-dev \
	libncurses5-dev\
	libpixman-1-dev \
	libssl-dev \
	libtool \
	make \
	mtools \
	netcat \
	python3-pycryptodome \
	python3-pyelftools \
	python3-serial \
	rsync \
	unzip \
	uuid-dev \
	xdg-utils \
	xterm \
	xz-utils \
	zlib1g-dev \
	repo


ENV DIRPATH /home/${DOCKER_USER_}
WORKDIR $DIRPATH

RUN mkdir optee-qemu && cd optee-qemu \
	&& yes | repo init -u https://github.com/OP-TEE/manifest.git -m qemu_v8.xml \
	&& repo sync

RUN cd optee-qemu/build\
	&& make toolchains -j4

RUN pip install cryptography

RUN	make run
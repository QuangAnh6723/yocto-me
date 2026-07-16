FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    chrpath \
    cpio \
    daemon \
    debianutils \
    diffstat \
    file \
    gawk \
    gcc \
    git \
    iputils-ping \
    libacl1 \
    libcrypt-dev \
    locales \
    lz4 \
    python3 \
    python3-git \
    python3-jinja2 \
    python3-pexpect \
    python3-pip \
    python3-subunit \
    python3-websockets \
    socat \
    sudo \
    texinfo \
    unzip \
    vim \
    wget \
    xz-utils \
    zstd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade websockets

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install for Toaster yocto
RUN pip3 install --no-cache-dir "Django>=4.2,<4.3" "beautifulsoup4>=4.4.0" pytz "django-log-viewer==1.1.7" click GitPython

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g ${GROUP_ID} yoctogroup && \
    useradd -u ${USER_ID} -g yoctogroup -ms /bin/bash yocto && \
    echo "yocto ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER yocto
WORKDIR /home/yocto/workspace
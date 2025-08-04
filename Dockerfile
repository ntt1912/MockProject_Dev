FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_UNSAFE_CONFIGURE=1

RUN apt-get update && apt-get install -y \
    build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
    gettext git libncurses5-dev libssl-dev python3-distutils rsync unzip zlib1g-dev file wget \
    subversion swig time libz-dev libpython3-dev cpio curl bc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /openwrt

RUN git clone https://github.com/openwrt/openwrt.git .

COPY feeds.conf.default ./

RUN ./scripts/feeds update -a && ./scripts/feeds install -a

COPY .config ./

RUN make defconfig
RUN make -j$(nproc) V=s

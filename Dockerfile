# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts and force unsafe configure
ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_UNSAFE_CONFIGURE=1

# Install all required build tools and libraries for OpenWrt compilation, then clean up apt cache
RUN apt-get update && apt-get install -y \
    build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
    gettext git libncurses5-dev libssl-dev python3-distutils rsync unzip zlib1g-dev file wget \
    subversion swig time libz-dev libpython3-dev cpio curl bc \
    && rm -rf /var/lib/apt/lists/*

# Set working directory to /openwrt
WORKDIR /openwrt

# Clone the OpenWrt source code into the working directory
RUN git clone https://github.com/openwrt/openwrt.git .

# Copy the feeds configuration file into the container
COPY feeds.conf.default ./

# Update and install all OpenWrt package feeds
RUN ./scripts/feeds update -a && ./scripts/feeds install -a

# Copy the OpenWrt build configuration file into the container
COPY .config ./

# Generate default configuration based on .config
RUN make defconfig

# Build OpenWrt using all available CPU cores and show verbose output
RUN make -j$(nproc) V=s

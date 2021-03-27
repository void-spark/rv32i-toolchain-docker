# Anything that may be used for building, but is also needed in the final image
FROM ubuntu:latest AS base
RUN apt-get update -qq \
&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
    ca-certificates \    
    git \
    zlib1g \
&& rm -rf /var/lib/apt/lists/*


# Anything that is used in more then one of the builds, but not needed in the final image
FROM base AS build_base
RUN apt-get update -qq \
&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
    build-essential \
    pkg-config \
&& rm -rf /var/lib/apt/lists/*


# https://github.com/cliffordwolf/picorv32#building-a-pure-rv32i-toolchain
FROM build_base AS build_rv32i-toolchain
RUN apt-get update -qq \
&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
    autoconf \
    automake \
    autotools-dev \
    bc \
    curl \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    gawk \
    bison \
    flex \
    texinfo \
    gperf \
    libtool \
    patchutils \
    zlib1g-dev \
    libexpat1-dev \
&& rm -rf /var/lib/apt/lists/*
RUN git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
WORKDIR riscv-gnu-toolchain
RUN ./configure --prefix=/opt/riscv32i --with-arch=rv32i && make -j$(nproc)
WORKDIR /


# Avengers assemble!
FROM void-spark/osfpga

RUN apt-get update -qq \
&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
    libmpc3 \
    libmpfr6 \
    libgmp10 \
&& rm -rf /var/lib/apt/lists/*

COPY --from=build_rv32i-toolchain /opt/riscv32i/ /opt/riscv32i/

ENV PATH="${PATH}:/opt/riscv32i/bin"

CMD [ "/bin/bash" ]

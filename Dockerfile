FROM ubuntu:18.04 AS builder

# install cfdem dependencies
ARG LC_ALL=en_AU.UTF-8
ARG LANGUAGE=en_AU.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y locales && locale-gen en_AU.UTF-8 && apt-get install -y git build-essential flex bison cmake zlib1g-dev libboost-system-dev libboost-thread-dev libopenmpi-dev openmpi-bin gnuplot libreadline-dev libncurses-dev libxt-dev libvtk6-dev python-numpy

WORKDIR /usr/local
RUN mkdir CFDEM LIGGGHTS OpenFOAM

WORKDIR /usr/local/OpenFOAM
RUN git clone https://github.com/OpenFOAM/OpenFOAM-5.x.git && git clone https://github.com/OpenFOAM/ThirdParty-5.x.git

WORKDIR /usr/local/OpenFOAM/OpenFOAM-5.x
RUN git checkout 538044ac05c4672b37c7df607dca1116fa88df88

COPY OF-install.sh .
RUN bash OF-install.sh

WORKDIR /usr/local/LIGGGHTS
RUN git clone https://github.com/CFDEMproject/LIGGGHTS-PUBLIC.git && git clone https://github.com/CFDEMproject/LPP.git lpp

ENV CFDEM_VERSION=PUBLIC
ENV CFDEM_PROJECT_DIR=/usr/local/CFDEM/CFDEMcoupling-PUBLIC
ENV CFDEM_PROJECT_USER_DIR=/home/docker-user/CFDEM/cfdemlogs
ENV CFDEM_BASHRC=/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/bashrc
ENV CFDEM_LIGGGHTS_SRC_DIR=/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src
ENV CFDEM_LIGGGHTS_MAKEFILE_NAME=mpi
ENV CFDEM_LPP_DIR=/usr/local/LIGGGHTS/lpp/src
WORKDIR /usr/local/CFDEM
RUN git clone https://github.com/CFDEMproject/CFDEMcoupling-PUBLIC.git
WORKDIR /usr/local/CFDEM/CFDEMcoupling-PUBLIC
COPY CFDEM-install.sh .
COPY cfdem-funcs/* /usr/local/bin
RUN bash CFDEM-install.sh

# 2nd stage
FROM ubuntu:18.04

# install cfdem dependencies
ARG LC_ALL=en_AU.UTF-8
ARG LANGUAGE=en_AU.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y locales && locale-gen en_AU.UTF-8 && apt-get install -y zlib1g-dev libboost-system-dev libboost-thread-dev libopenmpi-dev openmpi-bin gnuplot libreadline-dev libncurses-dev libxt-dev libvtk6-dev python-numpy evince octave eog openssh-server

COPY --from=builder /usr/local/OpenFOAM/OpenFOAM-5.x/bin /usr/local/OpenFOAM/OpenFOAM-5.x/bin
COPY --from=builder /usr/local/OpenFOAM/OpenFOAM-5.x/platforms /usr/local/OpenFOAM/OpenFOAM-5.x/platforms
COPY --from=builder /usr/local/OpenFOAM/OpenFOAM-5.x/etc /usr/local/OpenFOAM/OpenFOAM-5.x/etc
COPY --from=builder /usr/local/OpenFOAM/ThirdParty-5.x/platforms /usr/local/OpenFOAM/ThirdParty-5.x/platforms
COPY --from=builder /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/lmp_mpi /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/lmp_mpi
COPY --from=builder /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/liblmp_mpi.so /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/liblmp_mpi.so
RUN ln -s /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/liblmp_mpi.so  /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/libliggghts.so
COPY --from=builder /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib
COPY --from=builder /usr/local/LIGGGHTS/lpp /usr/local/LIGGGHTS/lpp
COPY --from=builder /usr/local/CFDEM/CFDEMcoupling-PUBLIC/src /usr/local/CFDEM/CFDEMcoupling-PUBLIC/src
COPY --from=builder /usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms /usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms
COPY --from=builder /usr/local/bin /usr/local/bin

ENV CFDEM_VERSION=PUBLIC
ENV CFDEM_PROJECT_DIR=/usr/local/CFDEM/CFDEMcoupling-PUBLIC
ENV CFDEM_PROJECT_USER_DIR=/home/docker-user/CFDEM/cfdemlogs
ENV CFDEM_BASHRC=/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/bashrc
ENV CFDEM_LIGGGHTS_SRC_DIR=/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src
ENV CFDEM_LIGGGHTS_MAKEFILE_NAME=mpi
ENV CFDEM_LPP_DIR=/usr/local/LIGGGHTS/lpp/src

COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN useradd -d /home/docker-user docker-user && mkdir /work && chown docker-user:docker-user /work
USER docker-user
WORKDIR /work
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

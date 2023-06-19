FROM ubuntu:18.04

# install cfdem dependencies
ARG LC_ALL=en_AU.UTF-8
ARG LANGUAGE=en_AU.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y locales && locale-gen en_AU.UTF-8 && apt-get install -y git build-essential flex bison cmake zlib1g-dev libboost-system-dev libboost-thread-dev libopenmpi-dev openmpi-bin gnuplot libreadline-dev libncurses-dev libxt-dev libscotch-dev libptscotch-dev libvtk6-dev python-numpy

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
ENV CFDEM_PROJECT_USER_DIR=/home/CFDEM/cfdemlogs
ENV CFDEM_BASHRC=/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/bashrc
ENV CFDEM_LIGGGHTS_SRC_DIR=/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src
ENV CFDEM_LIGGGHTS_MAKEFILE_NAME=mpi
ENV CFDEM_LPP_DIR=/usr/local/LIGGGHTS/lpp/src
WORKDIR /usr/local/CFDEM
RUN git clone https://github.com/CFDEMproject/CFDEMcoupling-PUBLIC.git
WORKDIR /usr/local/CFDEM/CFDEMcoupling-PUBLIC
COPY CFDEM-install.sh .
COPY cfdem-funcs/* /usr/local
RUN bash CFDEM-install.sh

COPY entrypoint.sh /etc
RUN chmod +x /etc/entrypoint.sh

RUN useradd docker-user
RUN mkdir /work && chown docker-user:docker-user /work
USER docker-user
WORKDIR /work
ENTRYPOINT /bin/bash /etc/entrypoint.sh

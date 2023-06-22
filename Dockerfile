FROM ubuntu:18.04 AS builder

# install cfdem dependencies
ARG LC_ALL=en_AU.UTF-8
ARG LANGUAGE=en_AU.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y locales && locale-gen en_AU.UTF-8 && apt-get install -y git build-essential flex bison cmake zlib1g-dev libboost-system-dev libboost-thread-dev libopenmpi-dev openmpi-bin gnuplot libreadline-dev libncurses-dev libxt-dev python-numpy

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
ENV CFDEM_LIGGGHTS_MAKEFILE_NAME=auto
ENV CFDEM_LPP_DIR=/usr/local/LIGGGHTS/lpp/src
ENV LD_LIBRARY_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib:${LD_LIBRARY_PATH}"
ENV LIBRARY_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib"
WORKDIR /usr/local/CFDEM
RUN git clone https://github.com/CFDEMproject/CFDEMcoupling-PUBLIC.git
WORKDIR /usr/local/CFDEM/CFDEMcoupling-PUBLIC
COPY CFDEM-install.sh .
COPY cfdem-funcs/* /usr/local/bin
RUN bash CFDEM-install.sh

RUN find /usr/local/OpenFOAM -name '*.so*' -type f -exec strip --strip-debug {} \;
RUN find /usr/local/LIGGGHTS -name '*.so*' -type f -exec strip --strip-debug {} \;
RUN find /usr/local/CFDEM -name '*.so*' -type f -exec strip --strip-debug {} \;

# 2nd stage
FROM ubuntu:18.04

# install cfdem dependencies
ARG LC_ALL=en_AU.UTF-8
ARG LANGUAGE=en_AU.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y locales && locale-gen en_AU.UTF-8 && apt-get install -y libopenmpi-dev openmpi-bin openssh-server lsb-release
# programs needed to visualise tutorial results
#RUN apt-get install -y eog evince octave

# OpenFOAM binaries
COPY --from=builder /usr/local/OpenFOAM/OpenFOAM-5.x/bin /usr/local/OpenFOAM/OpenFOAM-5.x/bin
COPY --from=builder /usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/bin /usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/bin
# OpenFOAM libraries (needed by binaries)
COPY --from=builder /usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib /usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib
# etc files - including bashrcs
COPY --from=builder /usr/local/OpenFOAM/OpenFOAM-5.x/etc /usr/local/OpenFOAM/OpenFOAM-5.x/etc

# OpenFOAM ThirdParty binaries
COPY --from=builder /usr/local/OpenFOAM/ThirdParty-5.x/platforms /usr/local/OpenFOAM/ThirdParty-5.x/platforms

# LIGGGHTS exe
COPY --from=builder /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/lmp_auto /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/lmp_auto
# LIGGGHTS lib
COPY --from=builder /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/liblmp_auto.so /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/liblmp_auto.so
RUN ln -s /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/liblmp_auto.so  /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/libliggghts.so

# VTK install (built with liggghts)
COPY --from=builder /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install

# LIGGGHTS post processing
COPY --from=builder /usr/local/LIGGGHTS/lpp /usr/local/LIGGGHTS/lpp

# CFDEM stuff
COPY --from=builder /usr/local/CFDEM/CFDEMcoupling-PUBLIC/src /usr/local/CFDEM/CFDEMcoupling-PUBLIC/src
COPY --from=builder /usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms /usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms
COPY --from=builder /usr/local/bin /usr/local/bin

ENV CFDEM_VERSION=PUBLIC
ENV CFDEM_PROJECT_DIR=/usr/local/CFDEM/CFDEMcoupling-PUBLIC
ENV CFDEM_PROJECT_USER_DIR=/home/docker-user/CFDEM/cfdemlogs
ENV CFDEM_BASHRC=/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/bashrc
ENV CFDEM_LIGGGHTS_SRC_DIR=/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src
ENV CFDEM_LIGGGHTS_MAKEFILE_NAME=auto
ENV CFDEM_LPP_DIR=/usr/local/LIGGGHTS/lpp/src
ENV LD_LIBRARY_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib:${LD_LIBRARY_PATH}"

COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN useradd -d /home/docker-user docker-user && mkdir /work && chown docker-user:docker-user /work
USER docker-user
WORKDIR /work
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

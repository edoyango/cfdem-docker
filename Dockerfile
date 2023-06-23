FROM ubuntu:18.04 AS builder

# install cfdem dependencies
ARG LC_ALL=en_AU.UTF-8
ARG LANGUAGE=en_AU.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y locales && locale-gen en_AU.UTF-8 && apt-get install -y wget git build-essential flex bison cmake zlib1g-dev libboost-system-dev libboost-thread-dev gnuplot libreadline-dev libncurses-dev libxt-dev python-numpy

# building MPI
WORKDIR /usr/local
RUN wget https://download.open-mpi.org/release/open-mpi/v2.1/openmpi-2.1.1.tar.bz2 && tar xjf openmpi-2.1.1.tar.bz2 && rm openmpi-2.1.1.tar.bz2 && cd openmpi-2.1.1 && ./configure --enable-mpi-thread-multiple --enable-static --enable-mpi-cxx --enable-mpi-fortran=no --disable-oshmem && make -j && make install && cd .. && rm -rf openmpi-2.1.1
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

RUN mkdir CFDEM LIGGGHTS OpenFOAM

WORKDIR /usr/local/OpenFOAM
RUN git clone https://github.com/OpenFOAM/OpenFOAM-5.x.git && git clone https://github.com/OpenFOAM/ThirdParty-5.x.git

WORKDIR /usr/local/OpenFOAM/OpenFOAM-5.x
RUN git checkout 538044ac05c4672b37c7df607dca1116fa88df88

ENV WM_PROJECT_INST_DIR="/usr/local/OpenFOAM" \
    WM_THIRD_PARTY_DIR="/usr/local/OpenFOAM/ThirdParty-5.x" \
    WM_LDFLAGS=-m64 WM_CXXFLAGS="-m64 -fPIC -std=c++0x" \
    WM_PRECISION_OPTION="DP" \
    WM_CC="gcc" \
    WM_PROJECT_USER_DIR="/home/dock-user/OpenFOAM-5.x" \
    WM_OPTIONS="linux64GccDPInt32Opt" \
    WM_LINK_LANGUAGE="c++" \
    WM_OSTYPE="POSIX" \
    WM_PROJECT="OpenFOAM" \
    WM_CFLAGS="-m64 -fPIC" \
    WM_ARCH="linux64" \
    WM_COMPILER_LIB_ARCH="64" \
    WM_COMPILER="Gcc" \
    WM_DIR="/usr/local/OpenFOAM/OpenFOAM-5.x/wmake" \
    WM_LABEL_SIZE="32" \
    WM_ARCH_OPTION="64" \
    WM_PROJECT_VERSION="5.x" \ 
    WM_LABEL_OPTION="Int32" \ 
    WM_MPLIB="SYSTEMOPENMPI" \
    WM_COMPILE_OPTION="Opt" \
    WM_CXX="g++" \
    WM_PROJECT_DIR="/usr/local/OpenFOAM/OpenFOAM-5.x" \
    MPI_ARCH_PATH="/usr/local" \
    MPI_BUFFER_SIZE="20000000" \
    FOAM_TUTORIALS="/usr/local/OpenFOAM/OpenFOAM-5.x/tutorials" \
    FOAM_RUN="/home/dock-user/OpenFOAM-5.x/run" \
    FOAM_APP="/usr/local/OpenFOAM/OpenFOAM-5.x/applications" \
    FOAM_UTILITIES="/usr/local/OpenFOAM/OpenFOAM-5.x/applications/utilities" \
    FOAM_APPBIN="/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/bin" \
    ParaView_DIR="/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64Gcc/ParaView-5.4.0" \
    FOAM_SOLVERS="/usr/local/OpenFOAM/OpenFOAM-5.x/applications/solvers" \
    FOAM_EXT_LIBBIN="/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64GccDPInt32/lib" \
    FOAM_USER_APPBIN="/home/dock-user/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/bin" \
    FOAM_SIGFPE= \
    FOAM_LIBBIN="/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib" \
    FOAM_SRC="/usr/local/OpenFOAM/OpenFOAM-5.x/src" \
    FOAM_ETC="/usr/local/OpenFOAM/OpenFOAM-5.x/etc" \
    FOAM_SETTINGS= \
    FOAM_SITE_APPBIN="/usr/local/OpenFOAM/site/5.x/platforms/linux64GccDPInt32Opt/bin" \
    FOAM_SITE_LIBBIN="/usr/local/OpenFOAM/site/5.x/platforms/linux64GccDPInt32Opt/lib" \
    FOAM_INST_DIR="/usr/local/OpenFOAM" \
    FOAM_USER_LIBBIN="/home/dock-user/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib" \
    FOAM_MPI="openmpi-system" \
    FOAM_JOB_DIR="/usr/local/OpenFOAM/jobControl" \
    PATH="/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64Gcc/gperftools-svn/bin:/usr/local/OpenFOAM/site/5.x/platforms/linux64GccDPInt32Opt/bin:/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/bin:/usr/local/OpenFOAM/OpenFOAM-5.x/bin:/usr/local/OpenFOAM/OpenFOAM-5.x/wmake:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64Gcc/gperftools-svn/lib:/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib/openmpi-system:/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64GccDPInt32/lib/openmpi-system:/usr/lib/x86_64-linux-gnu/openmpi/lib:/usr/local/OpenFOAM/site/5.x/platforms/linux64GccDPInt32Opt/lib:/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib:/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64GccDPInt32/lib:/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib/dummy:${LD_LIBRARY_PATH}"
RUN bash -c "export WM_NCOMPPROCS=`grep -c ^processor /proc/cpuinfo` && ./Allwmake"

WORKDIR /usr/local/LIGGGHTS
RUN git clone https://github.com/CFDEMproject/LIGGGHTS-PUBLIC.git && git clone https://github.com/CFDEMproject/LPP.git lpp

ENV CFDEM_VERSION="PUBLIC" \
    CFDEM_PROJECT_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC" \
    CFDEM_PROJECT_USER_DIR="/home/docker-user/CFDEM/cfdemlogs" \
    CFDEM_BASHRC="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/bashrc" \
    CFDEM_LIGGGHTS_SRC_DIR="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src" \
    CFDEM_LIGGGHTS_MAKEFILE_NAME="auto" \
    CFDEM_LPP_DIR="/usr/local/LIGGGHTS/lpp/src" \
    CFDEM_USER_APP_DIR="/usr/local/CFDEM/cfdemlogs-PUBLIC/platforms/linux64GccDPInt32Opt/bin" \
    CFDEM_TUT_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/tutorials" \
    CFDEM_POEMSLIB_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/poems" \
    CFDEM_M2MMSLIB_PATH="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/M2M/library" \
    CFDEM_ADD_LIBS_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/addLibs_universal" \
    CFDEM_LIB_NAME="lagrangianCFDEM-PUBLIC-5.x" \
    CFDEM_VERBOSE="false" \
    CFDEM_LIGGGHTS_EXEC="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/lmp_auto" \
    CFDEM_LIB_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms/linux64GccDPInt32Opt/lib" \
    CFDEM_LIGGGHTS_LIB_NAME="lmp_auto" \
    CFDEM_LIGGGHTS_MAKEFILE_POSTIFX= \
    CFDEM_WM_PROJECT_VERSION="50" \
    CFDEM_LPP_NPROCS="1" \
    CFDEM_Many2ManyLIB_PATH="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/twoWayMany2Many/library" \
    CFDEM_DOC_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/doc" \
    CFDEM_LIGGGHTS_LIB_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src" \
    CFDEM_OFVERSION_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/OFversion" \
    CFDEM_M2MLIB_PATH="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/M2M/library" \
    CFDEM_USER_LIB_DIR="/usr/local/CFDEM/cfdemlogs-PUBLIC/platforms/linux64GccDPInt32Opt/lib" \
    CFDEM_M2MMSLIB_MAKEFILENAME="auto" \
    CFDEM_SOLVER_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/applications/solvers" \
    CFDEM_LAMMPS_LIB_DIR="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib" \
    CFDEM_TEST_HARNESS_PATH="/usr/local/CFDEM/cfdemlogs-PUBLIC/log/logFilesCFDEM-PUBLIC-5.x" \
    CFDEM_M2MLIB_MAKEFILENAME="auto" \
    CFDEM_LIB_COMP_NAME="lagrangianCFDEMcomp-PUBLIC-5.x" \
    CFDEM_SRC_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src" \
    CFDEM_APP_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms/linux64GccDPInt32Opt/bin" \
    CFDEM_UT_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/applications/utilities" \
    CFDEM_Many2ManyLIB_MAKEFILENAME="auto" \
    PATH="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms/linux64GccDPInt32Opt/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib:/usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms/linux64GccDPInt32Opt/lib:${LD_LIBRARY_PATH}" \
    LIBRARY_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib" \
    CFDEM_ADD_LIBS_NAME="additionalLibs_5.x" \
    CFDEM_LPP_CHUNKSIZE="1"
WORKDIR /usr/local/CFDEM
RUN git clone https://github.com/CFDEMproject/CFDEMcoupling-PUBLIC.git
WORKDIR /usr/local/CFDEM/CFDEMcoupling-PUBLIC
COPY cfdem-funcs/* /usr/local/bin
RUN bash -c "export WM_NCOMPPROCS=`grep -c ^processor /proc/cpuinfo` && sed -i 's@AUTOINSTALL_VTK ?= \"OFF\"@AUTOINSTALL_VTK ?= \"ON\"@' /usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/MAKE/Makefile.auto && /usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/compileLIGGGHTS.sh"
RUN bash -c "export WM_NCOMPPROCS=`grep -c ^processor /proc/cpuinfo` && /usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/compileCFDEMcoupling.sh"

# 2nd stage
FROM ubuntu:18.04

# install cfdem dependencies
ARG LC_ALL=en_AU.UTF-8
ARG LANGUAGE=en_AU.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y locales && locale-gen en_AU.UTF-8 && apt-get install -y openssh-server lsb-release binutils
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
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/share /usr/local/share
COPY --from=builder /usr/local/etc /usr/local/etc
COPY --from=builder /usr/local/man /usr/local/man

# OMPI libs
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# OF vars and libs
ENV WM_PROJECT_INST_DIR="/usr/local/OpenFOAM" \
    WM_THIRD_PARTY_DIR="/usr/local/OpenFOAM/ThirdParty-5.x" \
    WM_LDFLAGS=-m64 WM_CXXFLAGS="-m64 -fPIC -std=c++0x" \
    WM_PRECISION_OPTION="DP" \
    WM_CC="gcc" \
    WM_PROJECT_USER_DIR="/home/dock-user/OpenFOAM-5.x" \
    WM_OPTIONS="linux64GccDPInt32Opt" \
    WM_LINK_LANGUAGE="c++" \
    WM_OSTYPE="POSIX" \
    WM_PROJECT="OpenFOAM" \
    WM_CFLAGS="-m64 -fPIC" \
    WM_ARCH="linux64" \
    WM_COMPILER_LIB_ARCH="64" \
    WM_COMPILER="Gcc" \
    WM_DIR="/usr/local/OpenFOAM/OpenFOAM-5.x/wmake" \
    WM_LABEL_SIZE="32" \
    WM_ARCH_OPTION="64" \
    WM_PROJECT_VERSION="5.x" \ 
    WM_LABEL_OPTION="Int32" \ 
    WM_MPLIB="SYSTEMOPENMPI" \
    WM_COMPILE_OPTION="Opt" \
    WM_CXX="g++" \
    WM_PROJECT_DIR="/usr/local/OpenFOAM/OpenFOAM-5.x" \
    MPI_ARCH_PATH="/usr/local" \
    MPI_BUFFER_SIZE="20000000" \
    FOAM_TUTORIALS="/usr/local/OpenFOAM/OpenFOAM-5.x/tutorials" \
    FOAM_RUN="/home/dock-user/OpenFOAM-5.x/run" \
    FOAM_APP="/usr/local/OpenFOAM/OpenFOAM-5.x/applications" \
    FOAM_UTILITIES="/usr/local/OpenFOAM/OpenFOAM-5.x/applications/utilities" \
    FOAM_APPBIN="/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/bin" \
    ParaView_DIR="/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64Gcc/ParaView-5.4.0" \
    FOAM_SOLVERS="/usr/local/OpenFOAM/OpenFOAM-5.x/applications/solvers" \
    FOAM_EXT_LIBBIN="/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64GccDPInt32/lib" \
    FOAM_USER_APPBIN="/home/dock-user/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/bin" \
    FOAM_SIGFPE= \
    FOAM_LIBBIN="/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib" \
    FOAM_SRC="/usr/local/OpenFOAM/OpenFOAM-5.x/src" \
    FOAM_ETC="/usr/local/OpenFOAM/OpenFOAM-5.x/etc" \
    FOAM_SETTINGS= \
    FOAM_SITE_APPBIN="/usr/local/OpenFOAM/site/5.x/platforms/linux64GccDPInt32Opt/bin" \
    FOAM_SITE_LIBBIN="/usr/local/OpenFOAM/site/5.x/platforms/linux64GccDPInt32Opt/lib" \
    FOAM_INST_DIR="/usr/local/OpenFOAM" \
    FOAM_USER_LIBBIN="/home/dock-user/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib" \
    FOAM_MPI="openmpi-system" \
    FOAM_JOB_DIR="/usr/local/OpenFOAM/jobControl" \
    PATH="/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64Gcc/gperftools-svn/bin:/usr/local/OpenFOAM/site/5.x/platforms/linux64GccDPInt32Opt/bin:/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/bin:/usr/local/OpenFOAM/OpenFOAM-5.x/bin:/usr/local/OpenFOAM/OpenFOAM-5.x/wmake:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64Gcc/gperftools-svn/lib:/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib/openmpi-system:/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64GccDPInt32/lib/openmpi-system:/usr/lib/x86_64-linux-gnu/openmpi/lib:/usr/local/OpenFOAM/site/5.x/platforms/linux64GccDPInt32Opt/lib:/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib:/usr/local/OpenFOAM/ThirdParty-5.x/platforms/linux64GccDPInt32/lib:/usr/local/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib/dummy:${LD_LIBRARY_PATH}"

# CFDEM vars and libs
ENV CFDEM_VERSION="PUBLIC" \
    CFDEM_PROJECT_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC" \
    CFDEM_PROJECT_USER_DIR="/home/docker-user/CFDEM/cfdemlogs" \
    CFDEM_BASHRC="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/bashrc" \
    CFDEM_LIGGGHTS_SRC_DIR="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src" \
    CFDEM_LIGGGHTS_MAKEFILE_NAME="auto" \
    CFDEM_LPP_DIR="/usr/local/LIGGGHTS/lpp/src" \
    CFDEM_USER_APP_DIR="/usr/local/CFDEM/cfdemlogs-PUBLIC/platforms/linux64GccDPInt32Opt/bin" \
    CFDEM_TUT_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/tutorials" \
    CFDEM_POEMSLIB_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/poems" \
    CFDEM_M2MMSLIB_PATH="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/M2M/library" \
    CFDEM_ADD_LIBS_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/addLibs_universal" \
    CFDEM_LIB_NAME="lagrangianCFDEM-PUBLIC-5.x" \
    CFDEM_VERBOSE="false" \
    CFDEM_LIGGGHTS_EXEC="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/lmp_auto" \
    CFDEM_LIB_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms/linux64GccDPInt32Opt/lib" \
    CFDEM_LIGGGHTS_LIB_NAME="lmp_auto" \
    CFDEM_LIGGGHTS_MAKEFILE_POSTIFX= \
    CFDEM_WM_PROJECT_VERSION="50" \
    CFDEM_LPP_NPROCS="1" \
    CFDEM_Many2ManyLIB_PATH="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/twoWayMany2Many/library" \
    CFDEM_DOC_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/doc" \
    CFDEM_LIGGGHTS_LIB_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src" \
    CFDEM_OFVERSION_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/OFversion" \
    CFDEM_M2MLIB_PATH="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/M2M/library" \
    CFDEM_USER_LIB_DIR="/usr/local/CFDEM/cfdemlogs-PUBLIC/platforms/linux64GccDPInt32Opt/lib" \
    CFDEM_M2MMSLIB_MAKEFILENAME="auto" \
    CFDEM_SOLVER_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/applications/solvers" \
    CFDEM_LAMMPS_LIB_DIR="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib" \
    CFDEM_TEST_HARNESS_PATH="/usr/local/CFDEM/cfdemlogs-PUBLIC/log/logFilesCFDEM-PUBLIC-5.x" \
    CFDEM_M2MLIB_MAKEFILENAME="auto" \
    CFDEM_LIB_COMP_NAME="lagrangianCFDEMcomp-PUBLIC-5.x" \
    CFDEM_SRC_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/src" \
    CFDEM_APP_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms/linux64GccDPInt32Opt/bin" \
    CFDEM_UT_DIR="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/applications/utilities" \
    CFDEM_Many2ManyLIB_MAKEFILENAME="auto" \
    PATH="/usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms/linux64GccDPInt32Opt/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib:/usr/local/CFDEM/CFDEMcoupling-PUBLIC/platforms/linux64GccDPInt32Opt/lib:${LD_LIBRARY_PATH}" \
    LIBRARY_PATH="/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/lib/vtk/install/lib" \
    CFDEM_ADD_LIBS_NAME="additionalLibs_5.x" \
    CFDEM_LPP_CHUNKSIZE="1"

RUN useradd -d /home/docker-user docker-user && mkdir /work && chown docker-user:docker-user /work
USER docker-user
WORKDIR /work
CMD ["/bin/bash"]

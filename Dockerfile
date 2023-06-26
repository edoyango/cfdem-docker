FROM ubuntu:18.04 AS builder

# install cfdem dependencies
ARG LC_ALL=en_AU.UTF-8
ARG LANGUAGE=en_AU.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y locales && locale-gen en_AU.UTF-8 && apt-get install -y wget git build-essential flex bison cmake zlib1g-dev libboost-system-dev libboost-thread-dev gnuplot libreadline-dev libncurses-dev libxt-dev python-numpy

RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor > /usr/share/keyrings/oneapi-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" > /etc/apt/sources.list.d/oneAPI.list
RUN apt-get update && apt-get install -y intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic
ENV LD_LIBRARY_PATH="/opt/intel/oneapi/tbb/2021.9.0/lib/intel64/gcc4.8:/opt/intel/oneapi/debugger/2023.1.0/gdb/intel64/lib:/opt/intel/oneapi/debugger/2023.1.0/libipt/intel64/lib:/opt/intel/oneapi/debugger/2023.1.0/dep/lib:/opt/intel/oneapi/compiler/2023.1.0/linux/lib:/opt/intel/oneapi/compiler/2023.1.0/linux/lib/x64:/opt/intel/oneapi/compiler/2023.1.0/linux/lib/oclfpga/host/linux64/lib:/opt/intel/oneapi/compiler/2023.1.0/linux/compiler/lib/intel64_lin:${LD_LIBRARY_PATH}" \
    INTEL_PYTHONHOME="/opt/intel/oneapi/debugger/2023.1.0/dep" \
    CMPLR_ROOT="/opt/intel/oneapi/compiler/2023.1.0" \
    GDB_INFO="/opt/intel/oneapi/debugger/2023.1.0/documentation/info/" \
    CMAKE_PREFIX_PATH="/opt/intel/oneapi/tbb/2021.9.0/:/opt/intel/oneapi/compiler/2023.1.0/linux/IntelDPCPP" \
    CPATH="/opt/intel/oneapi/tbb/2021.9.0/include:/opt/intel/oneapi/dpl/2022.1.0/linux/include:/opt/intel/oneapi/dev-utilities/2021.9.0/include" \
    INTELFPGAOCLSDKROOT="/opt/intel/oneapi/compiler/2023.1.0/linux/lib/oclfpga" \
    DPL_ROOT="/opt/intel/oneapi/dpl/2022.1.0" \
    LIBRARY_PATH="/opt/intel/oneapi/tbb/2021.9.0/lib/intel64/gcc4.8:/opt/intel/oneapi/compiler/2023.1.0/linux/compiler/lib/intel64_lin:/opt/intel/oneapi/compiler/2023.1.0/linux/lib" \
    DIAGUTIL_PATH="/opt/intel/oneapi/debugger/2023.1.0/sys_check/debugger_sys_check.py:/opt/intel/oneapi/compiler/2023.1.0/sys_check/sys_check.sh" \
    MANPATH="/opt/intel/oneapi/debugger/2023.1.0/documentation/man:/opt/intel/oneapi/compiler/2023.1.0/documentation/en/man/common:${MANPATH}" \
    ONEAPI_ROOT="/opt/intel/oneapi" \
    PATH="/opt/intel/oneapi/dev-utilities/2021.9.0/bin:/opt/intel/oneapi/debugger/2023.1.0/gdb/intel64/bin:/opt/intel/oneapi/compiler/2023.1.0/linux/lib/oclfpga/bin:/opt/intel/oneapi/compiler/2023.1.0/linux/bin/intel64:/opt/intel/oneapi/compiler/2023.1.0/linux/bin:${PATH}" \
    TBBROOT="/opt/intel/oneapi/tbb/2021.9.0" \
    PKG_CONFIG_PATH="/opt/intel/oneapi/tbb/2021.9.0/lib/pkgconfig:/opt/intel/oneapi/dpl/2022.1.0/lib/pkgconfig:/opt/intel/oneapi/compiler/2023.1.0/lib/pkgconfig" \
    INFOPATH="/opt/intel/oneapi/debugger/2023.1.0/gdb/intel64/lib"

# OMPI libs
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"


# building MPI
WORKDIR /usr/local
RUN wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.0.tar.bz2 && tar xjf openmpi-3.1.0.tar.bz2 && rm openmpi-3.1.0.tar.bz2 && cd openmpi-3.1.0 && CC=icc FC=ifort CXX=icpc ./configure --enable-mpi-thread-multiple --enable-static --enable-mpi-cxx --enable-mpi-fortran=no --disable-oshmem && make -j && make install && cd .. && rm -rf openmpi-3.1.0

# OF vars and libs
ENV WM_PROJECT_INST_DIR="/usr/local" \
    WM_THIRD_PARTY_DIR="/usr/local/ThirdParty-5.x" \
    WM_LDFLAGS=-m64 WM_CXXFLAGS="-m64 -fPIC -std=c++0x" \
    WM_PRECISION_OPTION="DP" \
    WM_CC="icc" \
    WM_OPTIONS="linux64IccDPInt32Opt" \
    WM_LINK_LANGUAGE="c++" \
    WM_OSTYPE="POSIX" \
    WM_PROJECT="OpenFOAM" \
    WM_CFLAGS="-m64 -fPIC" \
    WM_ARCH="linux64" \
    WM_COMPILER_LIB_ARCH="64" \
    WM_COMPILER="Icc" \
    WM_DIR="/usr/local/OpenFOAM-5.x/wmake" \
    WM_LABEL_SIZE="32" \
    WM_ARCH_OPTION="64" \
    WM_PROJECT_VERSION="5.x" \ 
    WM_LABEL_OPTION="Int32" \ 
    WM_MPLIB="SYSTEMOPENMPI" \
    WM_COMPILE_OPTION="Opt" \
    WM_CXX="icpx" \
    WM_PROJECT_DIR="/usr/local/OpenFOAM-5.x" \
    MPI_ARCH_PATH="/usr/local" \
    MPI_BUFFER_SIZE="20000000" \
    FOAM_TUTORIALS="/usr/local/OpenFOAM-5.x/tutorials" \
    FOAM_RUN="/home/dock-user/OpenFOAM-5.x/run" \
    FOAM_APP="/usr/local/OpenFOAM-5.x/applications" \
    FOAM_UTILITIES="/usr/local/OpenFOAM-5.x/applications/utilities" \
    FOAM_APPBIN="/usr/local/OpenFOAM-5.x/platforms/linux64IccDPInt32Opt/bin" \
    ParaView_DIR="/usr/local/ThirdParty-5.x/platforms/linux64Icc/ParaView-5.4.0" \
    FOAM_SOLVERS="/usr/local/OpenFOAM-5.x/applications/solvers" \
    FOAM_EXT_LIBBIN="/usr/local/ThirdParty-5.x/platforms/linux64IccDPInt32/lib" \
    FOAM_SIGFPE= \
    FOAM_LIBBIN="/usr/local/OpenFOAM-5.x/platforms/linux64IccDPInt32Opt/lib" \
    FOAM_SRC="/usr/local/OpenFOAM-5.x/src" \
    FOAM_ETC="/usr/local/OpenFOAM-5.x/etc" \
    FOAM_SETTINGS= \
    FOAM_INST_DIR="/usr/local" \
    FOAM_MPI="openmpi-system" \
    FOAM_JOB_DIR="/usr/local/OpenFOAM/jobControl"
ENV PATH="${WM_THIRD_PARTY_DIR}/platforms/linux64Icc/gperftools-svn/bin:${FOAM_APPBIN}:${WM_PROJECT_DIR}/bin:${WM_DIR}:${PATH}" \
    LD_LIBRARY_PATH="${WM_THIRD_PARTY_DIR}/platforms/linux64Icc/gperftools-svn/lib:${FOAM_LIBBIN}/openmpi-system:${FOAM_EXT_LIBBIN}/openmpi-system:${FOAM_LIBBIN}:${FOAM_EXT_LIBBIN}:${FOAM_LIBBIN}/dummy:${LD_LIBRARY_PATH}"

RUN git clone https://github.com/OpenFOAM/OpenFOAM-5.x.git && git clone https://github.com/OpenFOAM/ThirdParty-5.x.git

WORKDIR /usr/local/OpenFOAM-5.x
RUN git checkout 538044ac05c4672b37c7df607dca1116fa88df88

RUN bash -c "export WM_NCOMPPROCS=`grep -c ^processor /proc/cpuinfo` && ./Allwmake"

# CFDEM vars and libs
ENV CFDEM_VERSION="PUBLIC" \
    CFDEM_PROJECT_DIR="/usr/local/CFDEMcoupling-PUBLIC" \
    CFDEM_BASHRC="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/bashrc" \
    CFDEM_LIGGGHTS_SRC_DIR="/usr/local/LIGGGHTS-PUBLIC/src" \
    CFDEM_LIGGGHTS_MAKEFILE_NAME="auto" \
    CFDEM_LPP_DIR="/usr/local/lpp/src" \
    CFDEM_TUT_DIR="/usr/local/CFDEMcoupling-PUBLIC/tutorials" \
    CFDEM_POEMSLIB_PATH="/usr/local/LIGGGHTS-PUBLIC/lib/poems" \
    CFDEM_M2MMSLIB_PATH="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/M2M/library" \
    CFDEM_ADD_LIBS_DIR="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/addLibs_universal" \
    CFDEM_LIB_NAME="lagrangianCFDEM-PUBLIC-5.x" \
    CFDEM_VERBOSE="false" \
    CFDEM_LIGGGHTS_EXEC="/usr/local/LIGGGHTS-PUBLIC/src/lmp_auto" \
    CFDEM_LIB_DIR="/usr/local/CFDEMcoupling-PUBLIC/platforms/linux64IccDPInt32Opt/lib" \
    CFDEM_LIGGGHTS_LIB_NAME="lmp_auto" \
    CFDEM_LIGGGHTS_MAKEFILE_POSTIFX= \
    CFDEM_WM_PROJECT_VERSION="50" \
    CFDEM_LPP_NPROCS="1" \
    CFDEM_Many2ManyLIB_PATH="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/twoWayMany2Many/library" \
    CFDEM_DOC_DIR="/usr/local/CFDEMcoupling-PUBLIC/doc" \
    CFDEM_LIGGGHTS_LIB_PATH="/usr/local/LIGGGHTS-PUBLIC/src" \
    CFDEM_OFVERSION_DIR="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/OFversion" \
    CFDEM_M2MLIB_PATH="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/M2M/library" \
    CFDEM_M2MMSLIB_MAKEFILENAME="auto" \
    CFDEM_SOLVER_DIR="/usr/local/CFDEMcoupling-PUBLIC/applications/solvers" \
    CFDEM_LAMMPS_LIB_DIR="/usr/local/LIGGGHTS-PUBLIC/lib" \
    CFDEM_TEST_HARNESS_PATH="/usr/local/cfdemlogs-PUBLIC/log/logFilesCFDEM-PUBLIC-5.x" \
    CFDEM_M2MLIB_MAKEFILENAME="auto" \
    CFDEM_LIB_COMP_NAME="lagrangianCFDEMcomp-PUBLIC-5.x" \
    CFDEM_SRC_DIR="/usr/local/CFDEMcoupling-PUBLIC/src" \
    CFDEM_APP_DIR="/usr/local/CFDEMcoupling-PUBLIC/platforms/linux64IccDPInt32Opt/bin" \
    CFDEM_UT_DIR="/usr/local/CFDEMcoupling-PUBLIC/applications/utilities" \
    CFDEM_Many2ManyLIB_MAKEFILENAME="auto" \
    LIBRARY_PATH="/usr/local/LIGGGHTS-PUBLIC/lib/vtk/install/lib" \
    CFDEM_ADD_LIBS_NAME="additionalLibs_5.x" \
    CFDEM_LPP_CHUNKSIZE="1"
ENV PATH="${CFDEM_APP_DIR}:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/LIGGGHTS-PUBLIC/lib/vtk/install/lib:${CFDEM_LIB_DIR}:${LD_LIBRARY_PATH}"

WORKDIR /usr/local
RUN git clone https://github.com/CFDEMproject/LIGGGHTS-PUBLIC.git && git clone https://github.com/CFDEMproject/LPP.git lpp

WORKDIR /usr/local
RUN git clone https://github.com/CFDEMproject/CFDEMcoupling-PUBLIC.git
WORKDIR /usr/local/CFDEMcoupling-PUBLIC
COPY cfdem-funcs/* /usr/local/bin
RUN bash -c "export WM_NCOMPPROCS=`grep -c ^processor /proc/cpuinfo` && sed -i 's@AUTOINSTALL_VTK ?= \"OFF\"@AUTOINSTALL_VTK ?= \"ON\"@' /usr/local/LIGGGHTS-PUBLIC/src/MAKE/Makefile.auto && CXX=/opt/intel/oneapi/compiler/2023.1.0/linux/bin/intel64/icpc /usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/compileLIGGGHTS.sh"
RUN bash -c "export WM_NCOMPPROCS=`grep -c ^processor /proc/cpuinfo` && /usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/compileCFDEMcoupling.sh"

# 2nd stage
FROM ubuntu:18.04

# install cfdem dependencies
ARG LC_ALL=en_AU.UTF-8
ARG LANGUAGE=en_AU.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y locales && locale-gen en_AU.UTF-8 && apt-get install -y openssh-server lsb-release binutils curl gnupg2
# programs needed to visualise tutorial results
#RUN apt-get install -y eog evince octave
RUN curl https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor > /usr/share/keyrings/oneapi-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" > /etc/apt/sources.list.d/oneAPI.list
RUN apt-get update && apt-get install -y intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic
ENV LD_LIBRARY_PATH="/opt/intel/oneapi/tbb/2021.9.0/lib/intel64/gcc4.8:/opt/intel/oneapi/debugger/2023.1.0/gdb/intel64/lib:/opt/intel/oneapi/debugger/2023.1.0/libipt/intel64/lib:/opt/intel/oneapi/debugger/2023.1.0/dep/lib:/opt/intel/oneapi/compiler/2023.1.0/linux/lib:/opt/intel/oneapi/compiler/2023.1.0/linux/lib/x64:/opt/intel/oneapi/compiler/2023.1.0/linux/lib/oclfpga/host/linux64/lib:/opt/intel/oneapi/compiler/2023.1.0/linux/compiler/lib/intel64_lin:${LD_LIBRARY_PATH}" \
    INTEL_PYTHONHOME="/opt/intel/oneapi/debugger/2023.1.0/dep" \
    CMPLR_ROOT="/opt/intel/oneapi/compiler/2023.1.0" \
    GDB_INFO="/opt/intel/oneapi/debugger/2023.1.0/documentation/info/" \
    CMAKE_PREFIX_PATH="/opt/intel/oneapi/tbb/2021.9.0/:/opt/intel/oneapi/compiler/2023.1.0/linux/IntelDPCPP" \
    CPATH="/opt/intel/oneapi/tbb/2021.9.0/include:/opt/intel/oneapi/dpl/2022.1.0/linux/include:/opt/intel/oneapi/dev-utilities/2021.9.0/include" \
    INTELFPGAOCLSDKROOT="/opt/intel/oneapi/compiler/2023.1.0/linux/lib/oclfpga" \
    DPL_ROOT="/opt/intel/oneapi/dpl/2022.1.0" \
    LIBRARY_PATH="/opt/intel/oneapi/tbb/2021.9.0/lib/intel64/gcc4.8:/opt/intel/oneapi/compiler/2023.1.0/linux/compiler/lib/intel64_lin:/opt/intel/oneapi/compiler/2023.1.0/linux/lib" \
    DIAGUTIL_PATH="/opt/intel/oneapi/debugger/2023.1.0/sys_check/debugger_sys_check.py:/opt/intel/oneapi/compiler/2023.1.0/sys_check/sys_check.sh" \
    MANPATH="/opt/intel/oneapi/debugger/2023.1.0/documentation/man:/opt/intel/oneapi/compiler/2023.1.0/documentation/en/man/common:${MANPATH}" \
    ONEAPI_ROOT="/opt/intel/oneapi" \
    PATH="/opt/intel/oneapi/dev-utilities/2021.9.0/bin:/opt/intel/oneapi/debugger/2023.1.0/gdb/intel64/bin:/opt/intel/oneapi/compiler/2023.1.0/linux/lib/oclfpga/bin:/opt/intel/oneapi/compiler/2023.1.0/linux/bin/intel64:/opt/intel/oneapi/compiler/2023.1.0/linux/bin:${PATH}" \
    TBBROOT="/opt/intel/oneapi/tbb/2021.9.0" \
    PKG_CONFIG_PATH="/opt/intel/oneapi/tbb/2021.9.0/lib/pkgconfig:/opt/intel/oneapi/dpl/2022.1.0/lib/pkgconfig:/opt/intel/oneapi/compiler/2023.1.0/lib/pkgconfig" \
    INFOPATH="/opt/intel/oneapi/debugger/2023.1.0/gdb/intel64/lib"

# OMPI libs
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# OF vars and libs
ENV WM_PROJECT_INST_DIR="/usr/local" \
    WM_THIRD_PARTY_DIR="/usr/local/ThirdParty-5.x" \
    WM_LDFLAGS=-m64 WM_CXXFLAGS="-m64 -fPIC -std=c++0x" \
    WM_PRECISION_OPTION="DP" \
    WM_CC="icc" \
    WM_OPTIONS="linux64IccDPInt32Opt" \
    WM_LINK_LANGUAGE="c++" \
    WM_OSTYPE="POSIX" \
    WM_PROJECT="OpenFOAM" \
    WM_CFLAGS="-m64 -fPIC" \
    WM_ARCH="linux64" \
    WM_COMPILER_LIB_ARCH="64" \
    WM_COMPILER="Icc" \
    WM_DIR="/usr/local/OpenFOAM-5.x/wmake" \
    WM_LABEL_SIZE="32" \
    WM_ARCH_OPTION="64" \
    WM_PROJECT_VERSION="5.x" \ 
    WM_LABEL_OPTION="Int32" \ 
    WM_MPLIB="SYSTEMOPENMPI" \
    WM_COMPILE_OPTION="Opt" \
    WM_CXX="icpx" \
    WM_PROJECT_DIR="/usr/local/OpenFOAM-5.x" \
    MPI_ARCH_PATH="/usr/local" \
    MPI_BUFFER_SIZE="20000000" \
    FOAM_TUTORIALS="/usr/local/OpenFOAM-5.x/tutorials" \
    FOAM_RUN="/home/dock-user/OpenFOAM-5.x/run" \
    FOAM_APP="/usr/local/OpenFOAM-5.x/applications" \
    FOAM_UTILITIES="/usr/local/OpenFOAM-5.x/applications/utilities" \
    FOAM_APPBIN="/usr/local/OpenFOAM-5.x/platforms/linux64IccDPInt32Opt/bin" \
    ParaView_DIR="/usr/local/ThirdParty-5.x/platforms/linux64Icc/ParaView-5.4.0" \
    FOAM_SOLVERS="/usr/local/OpenFOAM-5.x/applications/solvers" \
    FOAM_EXT_LIBBIN="/usr/local/ThirdParty-5.x/platforms/linux64IccDPInt32/lib" \
    FOAM_SIGFPE= \
    FOAM_LIBBIN="/usr/local/OpenFOAM-5.x/platforms/linux64IccDPInt32Opt/lib" \
    FOAM_SRC="/usr/local/OpenFOAM-5.x/src" \
    FOAM_ETC="/usr/local/OpenFOAM-5.x/etc" \
    FOAM_SETTINGS= \
    FOAM_INST_DIR="/usr/local" \
    FOAM_MPI="openmpi-system" \
    FOAM_JOB_DIR="/usr/local/OpenFOAM/jobControl"
ENV PATH="${WM_THIRD_PARTY_DIR}/platforms/linux64Icc/gperftools-svn/bin:${FOAM_APPBIN}:${WM_PROJECT_DIR}/bin:${WM_DIR}:${PATH}" \
    LD_LIBRARY_PATH="${WM_THIRD_PARTY_DIR}/platforms/linux64Icc/gperftools-svn/lib:${FOAM_LIBBIN}/openmpi-system:${FOAM_EXT_LIBBIN}/openmpi-system:${FOAM_LIBBIN}:${FOAM_EXT_LIBBIN}:${FOAM_LIBBIN}/dummy:${LD_LIBRARY_PATH}"

# CFDEM vars and libs
ENV CFDEM_VERSION="PUBLIC" \
    CFDEM_PROJECT_DIR="/usr/local/CFDEMcoupling-PUBLIC" \
    CFDEM_BASHRC="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/bashrc" \
    CFDEM_LIGGGHTS_SRC_DIR="/usr/local/LIGGGHTS-PUBLIC/src" \
    CFDEM_LIGGGHTS_MAKEFILE_NAME="auto" \
    CFDEM_LPP_DIR="/usr/local/lpp/src" \
    CFDEM_TUT_DIR="/usr/local/CFDEMcoupling-PUBLIC/tutorials" \
    CFDEM_POEMSLIB_PATH="/usr/local/LIGGGHTS-PUBLIC/lib/poems" \
    CFDEM_M2MMSLIB_PATH="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/M2M/library" \
    CFDEM_ADD_LIBS_DIR="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/addLibs_universal" \
    CFDEM_LIB_NAME="lagrangianCFDEM-PUBLIC-5.x" \
    CFDEM_VERBOSE="false" \
    CFDEM_LIGGGHTS_EXEC="/usr/local/LIGGGHTS-PUBLIC/src/lmp_auto" \
    CFDEM_LIB_DIR="/usr/local/CFDEMcoupling-PUBLIC/platforms/linux64IccDPInt32Opt/lib" \
    CFDEM_LIGGGHTS_LIB_NAME="lmp_auto" \
    CFDEM_LIGGGHTS_MAKEFILE_POSTIFX= \
    CFDEM_WM_PROJECT_VERSION="50" \
    CFDEM_LPP_NPROCS="1" \
    CFDEM_Many2ManyLIB_PATH="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/twoWayMany2Many/library" \
    CFDEM_DOC_DIR="/usr/local/CFDEMcoupling-PUBLIC/doc" \
    CFDEM_LIGGGHTS_LIB_PATH="/usr/local/LIGGGHTS-PUBLIC/src" \
    CFDEM_OFVERSION_DIR="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/OFversion" \
    CFDEM_M2MLIB_PATH="/usr/local/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/subModels/dataExchangeModel/M2M/library" \
    CFDEM_M2MMSLIB_MAKEFILENAME="auto" \
    CFDEM_SOLVER_DIR="/usr/local/CFDEMcoupling-PUBLIC/applications/solvers" \
    CFDEM_LAMMPS_LIB_DIR="/usr/local/LIGGGHTS-PUBLIC/lib" \
    CFDEM_TEST_HARNESS_PATH="/usr/local/cfdemlogs-PUBLIC/log/logFilesCFDEM-PUBLIC-5.x" \
    CFDEM_M2MLIB_MAKEFILENAME="auto" \
    CFDEM_LIB_COMP_NAME="lagrangianCFDEMcomp-PUBLIC-5.x" \
    CFDEM_SRC_DIR="/usr/local/CFDEMcoupling-PUBLIC/src" \
    CFDEM_APP_DIR="/usr/local/CFDEMcoupling-PUBLIC/platforms/linux64IccDPInt32Opt/bin" \
    CFDEM_UT_DIR="/usr/local/CFDEMcoupling-PUBLIC/applications/utilities" \
    CFDEM_Many2ManyLIB_MAKEFILENAME="auto" \
    LIBRARY_PATH="/usr/local/LIGGGHTS-PUBLIC/lib/vtk/install/lib" \
    CFDEM_ADD_LIBS_NAME="additionalLibs_5.x" \
    CFDEM_LPP_CHUNKSIZE="1"
ENV PATH="${CFDEM_APP_DIR}:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/LIGGGHTS-PUBLIC/lib/vtk/install/lib:${CFDEM_LIB_DIR}:${LD_LIBRARY_PATH}"

# OpenFOAM binaries
COPY --from=builder ${WM_PROJECT_DIR}/bin ${WM_PROJECT_DIR}/bin
COPY --from=builder ${FOAM_APPBIN} ${FOAM_APPBIN}
# OpenFOAM libraries (needed by binaries)
COPY --from=builder ${FOAM_LIBBIN} ${FOAM_LIBBIN}
COPY --from=builder ${FOAM_ETC} ${FOAM_ETC}

# OpenFOAM ThirdParty binaries
COPY --from=builder ${WM_THIRD_PARTY_DIR}/platforms ${WM_THIRD_PARTY_DIR}/platforms

# LIGGGHTS exe
COPY --from=builder ${CFDEM_LIGGGHTS_EXEC} ${CFDEM_LIGGGHTS_EXEC}
# LIGGGHTS lib
COPY --from=builder ${CFDEM_LIGGGHTS_SRC_DIR}/liblmp_auto.so ${CFDEM_LIGGGHTS_SRC_DIR}/liblmp_auto.so
RUN ln -s ${CFDEM_LIGGGHTS_SRC_DIR}/liblmp_auto.so  ${CFDEM_LIGGGHTS_SRC_DIR}/libliggghts.so

# VTK install (built with liggghts)
COPY --from=builder ${CFDEM_LAMMPS_LIB_DIR}/vtk/install ${CFDEM_LAMMPS_LIB_DIR}/vtk/install

# LIGGGHTS post processing
COPY --from=builder /usr/local/lpp /usr/local/lpp

# CFDEM stuff
COPY --from=builder ${CFDEM_SRC_DIR}/lagrangian/cfdemParticle/etc ${CFDEM_SRC_DIR}/lagrangian/cfdemParticle/etc
COPY --from=builder ${CFDEM_PROJECT_DIR}/platforms ${CFDEM_PROJECT_DIR}/platforms
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/share /usr/local/share
COPY --from=builder /usr/local/etc /usr/local/etc
COPY --from=builder /usr/local/man /usr/local/man

WORKDIR /work
CMD ["/bin/bash"]

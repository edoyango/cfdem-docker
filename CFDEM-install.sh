#!/bin/bash
# CFDEM-install.sh

cfdembashrc=src/lagrangian/cfdemParticle/etc/bashrc
liggghtsmakefile=/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/MAKE/Makefile.auto
sed -i 's@AUTOINSTALL_VTK ?= "OFF"@AUTOINSTALL_VTK ?= "ON"@' $liggghtsmakefile
sed -i 's@read YN@YN=y@' $cfdembashrc
. /usr/local/OpenFOAM/OpenFOAM-5.x/etc/bashrc
. src/lagrangian/cfdemParticle/etc/bashrc
export WM_NCOMPPROCS=`grep -c ^processor /proc/cpuinfo`
#cfdemCompCFDEMall
bash $CFDEM_SRC_DIR/lagrangian/cfdemParticle/etc/compileCFDEMcoupling_all.sh

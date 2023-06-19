#!/bin/bash
# CFDEM-install.sh

cfdembashrc=src/lagrangian/cfdemParticle/etc/bashrc
liggghtsmakefile=/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src/MAKE/Makefile.mpi
sed -i 's@-6.2@-6.3@g' $liggghtsmakefile
sed -i 's@#-L/usr/lib/x86_64-linux-gnu@-L/usr/lib/x86_64-linux-gnu@' $liggghtsmakefile
sed -i 's@read YN@YN=y@' $cfdembashrc
. /usr/local/OpenFOAM/OpenFOAM-5.x/etc/bashrc
. src/lagrangian/cfdemParticle/etc/bashrc
export WM_NCOMPPROCS=`grep -c ^processor /proc/cpuinfo`
#cfdemCompCFDEMall
bash $CFDEM_SRC_DIR/lagrangian/cfdemParticle/etc/compileCFDEMcoupling_all.sh

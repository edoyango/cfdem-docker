#!/bin/bash
# CFDEM-install.sh

sed -i 's@#export CFDEM_VERSION=PUBLIC@export CFDEM_VERSION=PUBLIC@' src/lagrangian/cfdemParticle/etc/bashrc
sed -i 's@#export CFDEM_PROJECT_DIR=$HOME/CFDEM/CFDEMcoupling-$CFDEM_VERSION-$WM_PROJECT_VERSION@export CFDEM_PROJECT_DIR=/usr/local/CFDEM/CFDEMcoupling-$CFDEM_VERSION@' src/lagrangian/cfdemParticle/etc/bashrc
sed -i 's@#export CFDEM_PROJECT_USER_DIR=$HOME/CFDEM/$LOGNAME-$CFDEM_VERSION-$WM_PROJECT_VERSION@export CFDEM_PROJECT_USER_DIR=/home/CFDEM/CFDEMcoupling-$CFDEM_VERSION-logs@' src/lagrangian/cfdemParticle/etc/bashrc
sed -i 's@#export CFDEM_bashrc=$CFDEM_PROJECT_DIR/src/lagrangian/cfdemParticle/etc/bashrc@export CFDEM_bashrc=$CFDEM_PROJECT_DIR/src/lagrangian/cfdemParticle/etc/bashrc@' src/lagrangian/cfdemParticle/etc/bashrc
sed -i 's@#export CFDEM_LIGGGHTS_SRC_DIR=$HOME/LIGGGHTS/LIGGGHTS-PUBLIC/src@export CFDEM_LIGGGHTS_SRC_DIR=/usr/local/LIGGGHTS/LIGGGHTS-PUBLIC/src@' src/lagrangian/cfdemParticle/etc/bashrc
sed -i 's@#export CFDEM_LIGGGHTS_MAKEFILE_NAME=auto@export CFDEM_LIGGGHTS_MAKEFILE_NAME=auto@' src/lagrangian/cfdemParticle/etc/bashrc
sed -i 's@#export CFDEM_LPP_DIR=$HOME/LIGGGHTS/mylpp/src@export CFDEM_LPP_DIR=/usr/local/LIGGGHTS/lpp/src@' src/lagrangian/cfdemParticle/etc/bashrc
. /usr/local/OpenFOAM/OpenFOAM-5.x/etc/bashrc
yes n | . src/lagrangian/cfdemParticle/etc/bashrc
export WM_NCOMPPROCS=`grep -c ^processor /proc/cpuinfo`
cfdemCompCFDEMall
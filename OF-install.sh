#!/bin/bash
# OF-install.sh
# assumed cwd is in OpenFOAM dir

sed -i 's@export FOAM_INST_DIR=$HOME/$WM_PROJECT@#export FOAM_INST_DIR=$HOME/$WM_PROJECT@' etc/bashrc
. etc/bashrc
export WM_NCOMPPROCS=`grep -c ^processor /proc/cpuinfo`
./Allwmake
wmRefresh

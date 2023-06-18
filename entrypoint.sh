#!/bin/bash
# entrypoint.sh

. /usr/local/OpenFOAM/OpenFOAM-5.x/etc/bashrc
. /usr/local/CFDEM/CFDEMcoupling-PUBLIC/src/lagrangian/cfdemParticle/etc/bashrc
exec $@

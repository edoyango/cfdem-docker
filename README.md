# cfdem-docker
Docker recipe to build CFDEM into a docker container. Works with Apptainer/Singularity too.
Add a GitHub issue if you have issues or want to suggest some improvements.

## Get the container

### Docker

```bash
docker pull fishchicken/cfdem:3.8.1
```

### Apptainer/Singularity

NOTE: The conversion from docker to apptainer/singularity only works for newer versions of apptainer/singularity.
This is due to issues where the container is pulled without its environment.

```bash
apptainer pull fishchicken/cfdem:3.8.1
```

## Usage

### Running the CFDEM tutorials

#### Setup

Get the CFDEM tutorials and go to a case directory

```bash
git clone https://github.com/CFDEMproject/CFDEMcoupling-PUBLIC.git
cd CFDEMcoupling-PUBLIC/tutorials/cfdemSolverIB/twoSpheresGlowinskiMPI
```

#### Docker

```bash
docker run \
    -v $(pwd):/work \              # mounts the current working directory as /work in the container
    -v $(HOME):/home/docker-user \ # mounts your home directory as /home/docker-user in the container
    -v /etc/passwd:/etc/passwd -u `id -u`:`id -g` # run container as you
    fishchicken/cfdem:3.8.1 \      # the container
    bash /work/Allrun.sh           # the run command. This should execute the entire example pipeline.
```

#### Apptainer/Singularity

```bash
apptainer run \
    -B $(pwd):/work \                  # mounts the current working ddirectory as /work in the container
    -B ${HOME}:/home/docker-user \     # mounts your home directory as /home/docker-user in the container
    docker://fishchicken/cfdem:3.8.1 \ # the container
    bash /work/Allrun.sh               # the command to be run inside the container. This should execute the entire example pipeline
```

## Deviations from CFDEM install instructions

The instructions that the container was originally built with is from here:

`https://www.cfdem.com/media/CFDEM/docu/CFDEMcoupling_Manual.html#installation`

These instructions are quite basic and seem to be written to optimise for convenience

### Built OpenMPI from source

This was required so that executing the container with Apptainer can work across nodes. the APT packages do not allow for this.

### Build VTK using the LIGGGHTS scripts

VTK has a lot of functionality that isn't used by LIGGGHTS. the APT VTK packages and their dependencies add about 500MB to the Docker image size. Installing VTK from source (using the LIGGGHTS makefile)
only installs the necessary features, which adds about 50MB only to the container (approx. 10x smaller than the APT packages).

### Not keeping source code and built object files

Source code and object files aren't necessary to run CFDEM and its subprograms. These are ommitted from the final image by using staged builds of the Docker image.
Only executables and shared libraries are kept.

### Excluding visualisation software

`eog`, `evince`, and `octave` APT packages are all needed to visualise the tutorials' results. These packages are ommitted from the container to reduce size.

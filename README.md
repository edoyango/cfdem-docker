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



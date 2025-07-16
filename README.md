# Load packages from spack

```
# spack env
. /cvmfs/larsoft.opensciencegrid.org/spack-v0.22.0-fermi/setup-env.sh

# root
# - hljl7gy root@6.28.12%gcc@12.2.0 arch=linux-almalinux9-x86_64_v3
spack load /hljl7gy

# gcc
spack load gcc@12.2.0

# ifdhc
# - b2vqwgc ifdhc@2.8.0%gcc@12.2.0 arch=linux-almalinux9-x86_64_v3
spack load /b2vqwgc

# xrootd
spack load xrootd@5.6.9%gcc@12.2.0
```

# Build GUNDAM

```
# Build and install GUNDAM under "GUNDAM-1.9.X" directory
mkdir GUNDAM-1.9.X
cd GUNDAM-1.9.X

# GUNDAM base directory
export GUNDAM_DIR=$PWD

# Directories
# - REPO_DIR: sources
# - BUILD_DIR: build
# - INSTALL_DIR: package will be installed here
export REPO_DIR=${GUNDAM_DIR}/Repositories/
export BUILD_DIR=${GUNDAM_DIR}/Build/
export INSTALL_DIR=${GUNDAM_DIR}/Install/

mkdir -p ${INSTALL_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${REPO_DIR}

mkdir -p ${BUILD_DIR}/json
mkdir -p ${BUILD_DIR}/yaml-cpp
mkdir -p ${BUILD_DIR}/gundam

mkdir -p ${INSTALL_DIR}/json
mkdir -p ${INSTALL_DIR}/yaml-cpp
mkdir -p ${INSTALL_DIR}/gundam

# Checkout source files  
cd ${REPO_DIR}

git clone https://github.com/nlohmann/json.git
git clone https://github.com/jbeder/yaml-cpp.git
git clone https://github.com/gundam-organization/gundam.git

# For gundam, we will use a specific feature branch
cd ${REPO_DIR}/gundam/
# Checking out jskim/ICARUSNuMIXSec/1.9.0_Main
# - Add Jaesung's repo
git remote add jskim git@github.com:jedori0228/gundam.git
# Checking out jskim/ICARUSNuMIXSec/1.9.0_Main
git fetch jskim
git checkout jskim/ICARUSNuMIXSec/1.9.0_Main
# Also checkout submodules
git submodule update --init --remote --recursive
git submodule update --init --recursive

# Now build
# - json
cd $BUILD_DIR/json/
cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR/json $REPO_DIR/json/.
make -j4 install
# - YAML
cd $BUILD_DIR/yaml-cpp/
cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR/yaml-cpp -DYAML_BUILD_SHARED_LIBS=on $REPO_DIR/yaml-cpp/.
make -j4 install
# - gundam
cd $BUILD_DIR/gundam/
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:${INSTALL_DIR}/yaml-cpp/
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:${INSTALL_DIR}/json/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${INSTALL_DIR}/yaml-cpp/lib64/
export LIBRARY_PATH=$LIBRARY_PATH:${INSTALL_DIR}/yaml-cpp/lib64/
cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR/gundam -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON $REPO_DIR/gundam/.
make -j4 install

# Finalize
export PATH="$INSTALL_DIR/gundam/bin:$PATH"
export LD_LIBRARY_PATH="$INSTALL_DIR/gundam/lib:$LD_LIBRARY_PATH"
```

If the build was succesful, your shell should be able to locate gundamFitter executable, and can run it
```
$ gundamFitter
2025.07.15 22:00:25  INFO GundamGreetings: ────────────────────────────────────────────────────────
2025.07.15 22:00:25  INFO GundamGreetings: Welcome to GUNDAM main fitter v1.9.0f+720-ga4e7b452/HEAD
2025.07.15 22:00:25  INFO GundamGreetings: ────────────────────────────────────────────────────────
2025.07.15 22:00:25  INFO gundamFitter: > gundamFitter is the main interface for the fitter.
2025.07.15 22:00:25  INFO gundamFitter: > 
2025.07.15 22:00:25  INFO gundamFitter: > It takes a set of inputs through config files and command line argument,
2025.07.15 22:00:25  INFO gundamFitter: > and initialize the fitter engine.
2025.07.15 22:00:25  INFO gundamFitter: > Once ready, the fitter minimize the likelihood function and
2025.07.15 22:00:25  INFO gundamFitter: > produce a set of plot saved in the output ROOT file.
...
2025.07.15 22:00:25 ERROR gundamFitter: (int main(int, char**)): No option was provided.
terminate called after throwing an instance of 'std::runtime_error'
  what():  exception thrown by the logger at gundamFitter.cxx:96: clParser.isNoOptionTriggered(): "No option was provided."
Aborted (core dumped)
```
This will fail because we did not give any necessary options, but if you see this messages, the build was successful.
Note that if you open a new shell after this, you need to set environment variables again.
Or you can just run below after changing directory to `GUNDAM-1.9.X`:
```
cd GUNDAM-1.9.X
source setup_GUNDAM.sh
```

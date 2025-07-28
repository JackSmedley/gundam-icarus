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

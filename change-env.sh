
source /opt/intel/bin/compilervars.sh -arch intel64 -platform linux
export SeisSolHome=~/SeisSolHome
# User specific aliases and functions
export PATH=$SeisSolHome/bin:$PATH
export LD_LIBRARY_PATH=$SeisSolHome/lib:$SeisSolHome/lib64:$LD_LIBRARY_PATH
export EDITOR=vim
export SCONS_LIB_DIR=$SeisSolHome/lib64/scons-2.2.0/
export PATH=$SeisSolHome/../libxsmm/bin:$PATH
#This 2 lines have been suggested by @yzs981130 (not sure they are really necessary)
export C_INCLUDE_PATH=$SeisSolHome/include:$C_INCLUDE_PATH 
export CPLUS_INCLUDE_PATH=$SeisSolHome/include:$CPLUS_INCLUDE_PATH


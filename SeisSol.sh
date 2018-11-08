# install intel suit with mpi, c++/fortran compiler and c++/fortran mkl is prerequired
# seems necessary on nectar
sudo locale-gen UTF-8
echo LC_ALL="en_AU.UTF-8" | sudo tee -a /etc/environment
echo LC_ALL="en_AU.UTF-8" | sudo tee -a /etc/environment

# update package
sudo apt update
sudo apt -y full-upgrade
sudo apt install -y git build-essential cmake m4 vim zlib1g-dev python-pip

# these package were used in final compilation, but wasn't mentioned in wiki page
sudo pip install numpy
sudo pip install scipy
sudo pip install lxml

# this is where all dependency installed
mkdir ~/SeisSolHome

# update the environment variables
wget https://raw.githubusercontent.com/AUsername000/build-SeisSol/master/change-env.sh
source change-env.sh
rm change-env.sh

# install metis
cd
wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz
gunzip metis-5.1.0.tar.gz
tar -xvf metis-5.1.0.tar
rm metis-5.1.0.tar
cd metis-5.1.0/include
rm metis.h
wget https://raw.githubusercontent.com/AUsername000/build-SeisSol/master/metis.h
cd ..
make config cc=mpiicc cxx=mpiicpc prefix=$SeisSolHome
make install
cd ..
rm -r metis-5.1.0/
cd

# install parmetis
cd
wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/parmetis-4.0.3.tar.gz
tar -xvf parmetis-4.0.3.tar.gz
rm parmetis-4.0.3.tar.gz
cd parmetis-4.0.3/metis/include
rm metis.h
wget https://raw.githubusercontent.com/AUsername000/build-SeisSol/master/metis.h
cd ../..
make config cc=mpiicc cxx=mpiicpc prefix=$SeisSolHome
make install
cd ..
rm -r parmetis-4.0.3
cd

# install scons
cd
wget http://prdownloads.sourceforge.net/scons/scons-2.2.0.tar.gz
tar -xaf scons-2.2.0.tar.gz
rm scons-2.2.0.tar.gz
cd scons-2.2.0
python setup.py install --prefix=$SeisSolHome
cd ..
rm -r scons-2.2.0

# install hdf5
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.11/src/hdf5-1.8.11.tar.bz2
tar -xaf hdf5-1.8.11.tar.bz2
rm hdf5-1.8.11.tar.bz2
cd hdf5-1.8.11
CC=mpiicc FC=mpiifort ./configure --enable-parallel --prefix=$SeisSolHome --with-zlib --disable-shared --enable-fortran
make
make install
cd ..
rm -r hdf5-1.8.11

# install netcdf
cd
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.4.1.1.tar.gz
tar -xaf netcdf-4.4.1.1.tar.gz
rm netcdf-4.4.1.1.tar.gz
cd netcdf-4.4.1.1/
CPPFLAGS=-I$SeisSolHome/include LDFLAGS=-L$SeisSolHome/lib CC=mpiicc ./configure --enable-shared=no --prefix=$SeisSolHome
make
make install
cd ..
rm -r netcdf-4.4.1.1
cd

# install libxsmm, libxsmm is installed saperately in $HOME, the bin path is already included in change_env.sh
cd
git clone https://github.com/hfp/libxsmm
cd libxsmm
make generator
export PATH=$(pwd)/bin:$PATH
cd

# build seissol
cd
git clone --recursive https://github.com/SeisSol/SeisSol.git
cd SeisSol
git checkout scc18
cd build/option
rm supermuc_mac_cluster.py
wget https://raw.githubusercontent.com/AUsername000/build-SeisSol/master/supermuc_mac_cluster.py
cd ../..

# refer to the email on 02/09/2018 4:29
git submodule update

scons -j 32 buildVariablesFile=build/options/supermuc_mac_cluster.py

# test run
cd ~/SeisSol
mkdir launch_SeisSol
cp build/SeisSol* launch_SeisSol/
echo $PWD/Maple/ > launch_SeisSol/DGPATH
cd launch_SeisSol
# download setup files


# for rank one, need to edit the MeshFile to use rank four
wget https://raw.githubusercontent.com/AUsername000/build-SeisSol/master/parameters_tpv33_hardcoded_ini.par
# wget https://raw.githubusercontent.com/SeisSol/Examples/master/tpv33/parameters_tpv33_hardcoded_ini.par


wget https://raw.githubusercontent.com/SeisSol/Examples/master/tpv33/parameters_tpv33_master.par # not capable with our sc18 version
wget https://raw.githubusercontent.com/SeisSol/Examples/master/tpv33/tpv33_faultreceivers.dat
wget https://raw.githubusercontent.com/SeisSol/Examples/master/tpv33/tpv33_initial_stress.yaml
wget https://raw.githubusercontent.com/SeisSol/Examples/master/tpv33/tpv33_material.yaml
wget https://raw.githubusercontent.com/SeisSol/Examples/master/tpv33/tpv33_receivers.dat
# newer version binary files
# wget https://syncandshare.lrz.de/dl/fi72mQiszp6vSs7qN8tdZJf9/tpv33_gmsh

# sc17 version binary
wget https://syncandshare.lrz.de/dl/fiEk3AtTvtfKPGEzPFHj2dmS # single rank
mv fiEk3AtTvtfKPGEzPFHj2dmS tpv33_gmsh.1.nc
# wget https://syncandshare.lrz.de/dl/fiPw7T4wbzc2Wtf1UXB8yWaT # rank four

# download xml files
wget https://syncandshare.lrz.de/dl/fiEi52Xiwwqkf2sNpTrCHjhw/tpv33_gmsh.xdmf

mkdir launch_SeisSol/output

# execute
# OMP_NUM_THREADS=<threads> mpiexec -np <n> ./SeisSol_<configuration> parameters_<branch>.par
OMP_NUM_THREADS=1 mpiexec -np 1 ./SeisSol_release_generatedKernels_dsnb_hybrid_none_9_5 parameters_tpv33_hardcoded_ini.par

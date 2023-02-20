CMAKEVERSION=2.8.12.1
OPENBABELVERSION=2.3.2
EIGENVERSION=6b38706d90a9

export qctopdir=/home/maho/all/pubchemqc
export PATH=$qctopdir/pkg_host/bin:$PATH:$qctopdir/pkg/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$qctopdir/pkg/lib:$qctopdir/pkg_host/lib

rm -rf cmake-$CMAKEVERSION/
tar xvfz ../archives/cmake-$CMAKEVERSION.tar.gz
cd cmake-$CMAKEVERSION
./bootstrap --prefix=$qctopdir/pkg_host
make 
make install
cd ..

rm -rf eigen-eigen-$EIGENVERSION
tar xvfz ../archives/eigen-eigen-$EIGENVERSION.tar.gz
mkdir eigen-eigen-$EIGENVERSION-build
cd eigen-eigen-$EIGENVERSION-build
cmake -DCMAKE_INSTALL_PREFIX=$qctopdir/pkg_host ../eigen-eigen-$EIGENVERSION
make -j2
make install
cd ..

rm -rf openbabel-$OPENBABELVERSION
tar xvfz ../archives/openbabel-$OPENBABELVERSION.tar.gz
rm -rf openbabel-$OPENBABELVERSION-build
mkdir openbabel-$OPENBABELVERSION-build
cd openbabel-$OPENBABELVERSION-build
cmake -DCMAKE_INSTALL_PREFIX=$qctopdir/pkg_host ../openbabel-$OPENBABELVERSION
make -j2
make install

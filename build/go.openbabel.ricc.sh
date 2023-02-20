CMAKEVERSION=2.8.12.1
OPENBABELVERSION=2.3.2
EIGENVERSION=6b38706d90a9

if [ x"$qctopdir" = x"" ]; then
echo "Do 'source pubchemqc.sh'" 
exit
fi

export CC=gcc
export CXX=g++
export CLTK_TARGET_MACHINE=pc
export CLTK_COMPILER_PC=gcc
export PATH=$qctopdir/openbabel/bin:$PATH

rm -rf cmake-$CMAKEVERSION/
tar xvfz ../archives/cmake-$CMAKEVERSION.tar.gz
cd cmake-$CMAKEVERSION
./bootstrap --prefix=$qctopdir/openbabel
make 
make install
cd ..

export PATH=/usr/bin:$PATH
rm -rf eigen-eigen-$EIGENVERSION
tar xvfz ../archives/eigen-eigen-$EIGENVERSION.tar.gz
mkdir eigen-eigen-$EIGENVERSION-build
cd eigen-eigen-$EIGENVERSION-build
cmake -DCMAKE_INSTALL_PREFIX=$qctopdir/openbabel ../eigen-eigen-$EIGENVERSION
make -j2
make install
cd ..

rm -rf openbabel-$OPENBABELVERSION
tar xvfz ../archives/openbabel-$OPENBABELVERSION.tar.gz
rm -rf openbabel-$OPENBABELVERSION-build
mkdir openbabel-$OPENBABELVERSION-build
cd openbabel-$OPENBABELVERSION-build
cmake -DCMAKE_INSTALL_PREFIX=$qctopdir/openbabel ../openbabel-$OPENBABELVERSION
make -j2
make install

CMAKEVERSION=2.8.12.1
OPENBABELVERSION=2.4.1
EIGENVERSION=6b38706d90a9

#export CXXFLAGS+=-stdlib=libstdc++
WRKDIR=$PUBCHEMQCSETUPDIR/work_openbabel
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
rm -rf cmake-$CMAKEVERSION/
tar xvfz $PUBCHEMQCARCHIVESDIR/cmake-$CMAKEVERSION.tar.gz
cd cmake-$CMAKEVERSION
./bootstrap --prefix=$PUBCHEMQCPKGDIR/openbabel
make 
make install

cd $WRKDIR
rm -rf eigen-eigen-$EIGENVERSION
tar xvfz $PUBCHEMQCARCHIVESDIR/eigen-eigen-$EIGENVERSION.tar.gz
mkdir eigen-eigen-$EIGENVERSION-build
cd eigen-eigen-$EIGENVERSION-build
cmake -DCMAKE_INSTALL_PREFIX=$PUBCHEMQCPKGDIR/openbabel ../eigen-eigen-$EIGENVERSION
make -j2
make install

cd $WRKDIR
rm -rf openbabel
rm -rf openbabel-build
mkdir openbabel-build
tar xvfz $PUBCHEMQCARCHIVESDIR/openbabel-${OPENBABELVERSION}.tar.gz
mv openbabel-${OPENBABELVERSION} openbabel
cd openbabel
patch -p1 < ../../../archives/patch-openbabel-multfix
cd ../openbabel-build
cmake -DCMAKE_INSTALL_PREFIX=$PUBCHEMQCPKGDIR/openbabel -DRUN_SWIG=ON -DPYTHON_BINDINGS=ON ../openbabel
make -j4
make install

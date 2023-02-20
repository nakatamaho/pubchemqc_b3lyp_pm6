CMAKEVERSION=2.8.12.1
OPENBABELVERSION=2.4.0rc
EIGENVERSION=6b38706d90a9

#export CXXFLAGS+=-stdlib=libstdc++
WRKDIR=$PUBCHEMQCSETUPDIR/work_openbabel
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
rm -rf cmake-$CMAKEVERSION/
tar xvfz $PUBCHEMQCARCHIVESDIR/cmake-$CMAKEVERSION.tar.gz
cd cmake-$CMAKEVERSION
./bootstrap --prefix=$PUBCHEMQCPKGDIR
make 
make install

cd $WRKDIR
rm -rf eigen-eigen-$EIGENVERSION
tar xvfz $PUBCHEMQCARCHIVESDIR/eigen-eigen-$EIGENVERSION.tar.gz
mkdir eigen-eigen-$EIGENVERSION-build
cd eigen-eigen-$EIGENVERSION-build
cmake -DCMAKE_INSTALL_PREFIX=$PUBCHEMQCPKGDIR ../eigen-eigen-$EIGENVERSION
make -j2
make install

cd $WRKDIR
rm -rf openbabel
rm -rf openbabel-$OPENBABELVERSION-build
mkdir openbabel-$OPENBABELVERSION-build

git clone git://github.com/openbabel/openbabel.git
cd openbabel-$OPENBABELVERSION-build
cmake -DCMAKE_INSTALL_PREFIX=/work/pubchemqc/pm6/setup/obdevel -DRUN_SWIG=ON -DPYTHON_BINDINGS=ON ../openbabel
make -j12
make install

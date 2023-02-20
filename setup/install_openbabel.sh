CMAKEVERSION=2.8.12.1
OPENBABELVERSION=2.4.1
EIGENVERSION=6b38706d90a9

NAME=OPENBABEL-${OPENBABELVERSION}

if [ -e "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}" ]; then
    echo "already installed"
    exit
fi

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
make
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
cmake -DCMAKE_INSTALL_PREFIX=$PUBCHEMQCPKGDIR -DRUN_SWIG=ON -DPYTHON_BINDINGS=ON ../openbabel
make
make install

touch "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}"



SWIGVERSION=3.0.10

WRKDIR=$PUBCHEMQCSETUPDIR/work_swig
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfz $PUBCHEMQCARCHIVESDIR/swig-$SWIGVERSION.tar.gz
cd swig-$SWIGVERSION
./configure --prefix=$PUBCHEMQCPKGDIR
make 
make install

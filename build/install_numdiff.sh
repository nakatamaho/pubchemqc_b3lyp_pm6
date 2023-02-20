NUMDIFFVERSION=5.9.0

WRKDIR=$PUBCHEMQCSETUPDIR/work_numdiff
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfz $PUBCHEMQCARCHIVESDIR/numdiff-$NUMDIFFVERSION.tar.gz
cd numdiff-$NUMDIFFVERSION
./configure --prefix=$PUBCHEMQCPKGDIR/numdiff
make 
make install

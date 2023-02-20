XZVERSION=5.2.2

WRKDIR=$PUBCHEMQCSETUPDIR/work_xz
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfz  $PUBCHEMQCARCHIVESDIR/xz-$XZVERSION.tar.gz
cd xz-$XZVERSION
./configure --prefix=$PUBCHEMQCPKGDIR
make 
make install

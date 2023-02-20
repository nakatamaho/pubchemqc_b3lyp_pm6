COREUTILSVERSION=8.25

WRKDIR=$PUBCHEMQCSETUPDIR/work_coreutils
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
cat $PUBCHEMQCARCHIVESDIR/coreutils-$COREUTILSVERSION.tar.xz | unxz | tar xvf -
cd coreutils-$COREUTILSVERSION
./configure --prefix=$PUBCHEMQCPKGDIR
make 
make install

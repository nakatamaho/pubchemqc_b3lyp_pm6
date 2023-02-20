TARVERSION=1.29

export CLTK_TARGET_MACHINE=pc
export CLTK_COMPILER_PC=gcc

WRKDIR=$PUBCHEMQCSETUPDIR/work_tar
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfz  $PUBCHEMQCARCHIVESDIR/tar-$TARVERSION.tar.gz
cd tar-$TARVERSION
./configure --prefix=$PUBCHEMQCPKGDIR
make 
make install

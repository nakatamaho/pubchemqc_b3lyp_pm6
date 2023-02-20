TARVERSION=1.29
NAME=TAR-${TARVERSION}

if [ -e "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}" ]; then
    echo "already installed"
    exit
fi

WRKDIR=$PUBCHEMQCSETUPDIR/work_tar
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfz $PUBCHEMQCARCHIVESDIR/tar-$TARVERSION.tar.gz
cd tar-$TARVERSION
./configure --prefix=$PUBCHEMQCPKGDIR
make
make install

touch "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}"



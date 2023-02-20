PARALLELVERSION=20160822

NAME=PARALLEL-${PARALLELVERSION}

if [ -e "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}" ]; then
    echo "already installed"
    exit
fi

WRKDIR=$PUBCHEMQCSETUPDIR/work_parallel
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfj $PUBCHEMQCARCHIVESDIR/parallel-$PARALLELVERSION.tar.bz2
cd parallel-$PARALLELVERSION
./configure --prefix=$PUBCHEMQCPKGDIR
make 
make install

touch "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}"

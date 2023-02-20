NUMDIFFVERSION=5.9.0

NAME=NUMDIFF-${NUMDIFFVERSION}
if [ -e "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}" ]; then
    echo "already installed"
    exit
fi

WRKDIR=$PUBCHEMQCSETUPDIR/work_numdiff
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfz $PUBCHEMQCARCHIVESDIR/numdiff-$NUMDIFFVERSION.tar.gz
cd numdiff-$NUMDIFFVERSION
./configure --prefix=$PUBCHEMQCPKGDIR
make 
make install

touch "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}"

